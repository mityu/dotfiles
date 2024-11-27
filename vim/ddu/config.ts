import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddu-vim@~6.4.0/config";
import {
  type ActionArguments,
  ActionFlags,
} from "jsr:@shougo/ddu-vim@~6.4.0/types";
import { Params as FFParams } from "jsr:@shougo/ddu-ui-ff@~1.4.0";
import { type ActionData as FileActionData } from "jsr:@shougo/ddu-kind-file@~0.9.0";
import type { Denops } from "jsr:@denops/std@~7.3.0";
import { execute } from "jsr:@denops/std@~7.3.0/function";
import { go } from "jsr:@denops/std@~7.3.0/variable";
import { is } from "jsr:@core/unknownutil@~4.3.0/is";
import { as } from "jsr:@core/unknownutil@~4.3.0/as";
import { assert } from "jsr:@core/unknownutil@~4.3.0/assert";
import { ensure } from "jsr:@core/unknownutil@~4.3.0/ensure";
import type { PredicateType } from "jsr:@core/unknownutil@~4.3.0/type";
import { assertType, type Has } from "jsr:@std/testing@~1.0.0/types";
import { dirname } from "jsr:@std/path@~1.0.0/dirname";

type Params = Record<string, unknown>;

const isFileActionData = is.ObjectOf({
  path: as.Optional(is.String),
  isDirectory: as.Optional(is.Boolean),
});
assertType<Has<FileActionData, PredicateType<typeof isFileActionData>>>(true);

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    args.setAlias("source", "file_git", "file_external");

    args.contextBuilder.patchGlobal({
      ui: "ff_vim_popup",
      uiParams: {
        ff: {
          split: "no",
          prompt: "> ",
          highlights: {
            selected: "Number",
          },
        } satisfies Partial<FFParams>,
        ff_vim_popup: {
          bounds: async (denops: Denops) => {
            const scWidth = ensure(await go.get(denops, "columns"), is.Number);
            const scHeight = ensure(await go.get(denops, "lines"), is.Number);
            const width = Math.max(scWidth - 20, Math.min(50, scWidth));
            const height = Math.max(scHeight - 10, Math.min(20, scHeight));
            const finder = {
              line: Math.trunc((scHeight - height) / 3),
              col: Math.trunc((scWidth - width) / 2),
              width: Math.trunc(width * 3 / 5),
              height: height,
            };
            const preview = {
              line: finder.line,
              col: finder.col + finder.width,
              width: width - finder.width,
              height: height,
            };
            return {
              finder: finder,
              preview: preview,
            };
          },
          listerBorder: {
            mask: [1, 1, 1, 1],
            chars: [
              "\u2500",
              "\u2502",
              "\u2500",
              "\u2502",
              "\u251c",
              "\u2524",
              "\u2534",
              "\u2570",
            ],
          },
          filterBorder: {
            mask: [1, 1, 0, 1],
            chars: [
              "\u2500",
              "\u2502",
              "\u2500",
              "\u2502",
              "\u256d",
              "\u252c",
              "\u2524",
              "\u251c",
            ],
          },
          previewBorder: {
            mask: [1, 1, 1, 0],
            chars: [
              "\u2500",
              "\u2502",
              "\u2500",
              "\u2502",
              "\u252c",
              "\u256e",
              "\u256f",
              "\u2534",
            ],
          },
          highlights: {
            cursorline: "Cursorline",
            cursor: "Cursor",
            popup: "Normal",
            selected: "Number",
            previewline: "Search",
          },
          hideCursor: true,
        },
      },
      sourceOptions: {
        _: {
          matchers: ["matcher_multi_regex"],
          ignoreCase: true,
        },
        mr: {
          matchers: ["converter_tr_homepath", "matcher_multi_regex"],
          ignoreCase: true,
        },
      },
      sourceParams: {
        file_rec: {
          ignoredDirectories: [
            "node_modules",
            ".git",
            "dist",
            ".vscode",
            ".deps",
          ],
        },
        rg: {
          args: ["--json", "--no-messages"],
          highlights: {
            path: "Preproc",
            lineNr: "Normal",
            word: "Special",
          },
        },
        file_git: {
          cmd: ["git", "ls-files"],
        },
      },
      kindOptions: {
        action: { defaultAction: "do" },
        file: {
          defaultAction: "openOrNarrow",
          actions: {
            openOrNarrow: actionKindFileOpenOrNarrow,
            searchFilesInContainedProject:
              actionKindFileSearchFilesInContainedProject,
          },
        },
        help: { defaultAction: "open" },
        lsp: { defaultAction: "open" },
        lsp_codeAction: { defaultAction: "apply" },
      },
      filterParams: {
        matcher_multi_regex: {
          highlightMatched: "Special",
          highlightGreedy: true,
        },
      },
    });

    args.contextBuilder.patchLocal("file-rec", {
      sources: [{ name: "file_rec" }],
    });
    args.contextBuilder.patchLocal("buffer", {
      sources: [{ name: "buffer" }],
    });
    args.contextBuilder.patchLocal("live-grep", {
      sources: [
        {
          name: "rg",
          options: {
            matchers: [],
            volatile: true,
          },
        },
      ],
    });
    args.contextBuilder.patchLocal("lsp-workspaceSymbol", {
      sources: [{ name: "lsp_workspaceSymbol" }],
      sourceOptions: { lsp: { volatile: true } },
    });
    args.contextBuilder.patchLocal("lsp-documentSymbol", {
      sources: [{ name: "lsp_documentSymbol" }],
      uiParams: {
        ff: { displayTree: true },
        ff_vim_popup: { displayTree: true },
      },
    });
    args.contextBuilder.patchLocal("lsp-callHierarchy", {
      sources: [{
        name: "lsp_callHierarchy",
        params: { method: "callHierarchy/outgoingCalls" },
      }],
      uiParams: {
        ff: { displayTree: true },
        ff_vim_popup: { displayTree: true },
      },
    });

    await execute(args.denops, [
      "if exists('#User#vimrc:dduConfigPost')",
      "  doautocmd User vimrc:dduConfigPost",
      "endif",
    ], "");

    return Promise.resolve();
  }
}

async function actionKindFileOpenOrNarrow(
  args: ActionArguments<Params>,
): Promise<ActionFlags> {
  const action = args.items[0].action;
  assert(action, isFileActionData);
  if (is.String(action.path) && action.path !== "" && action.isDirectory) {
    await args.denops.call("ddu#start", {
      name: args.options.name,
      push: true,
      sources: [{ name: "file", options: { path: action.path } }],
    });
    return ActionFlags.None;
  }

  await args.denops.call(
    "ddu#ui_sync_action",
    args.options.name,
    "itemAction",
    {
      name: "open",
      items: args.items,
      params: args.actionParams,
    },
  );
  return ActionFlags.RestoreCursor;
}

async function actionKindFileSearchFilesInContainedProject(
  args: ActionArguments<Params>,
): Promise<ActionFlags> {
  const getRoot = async (path?: string): Promise<string | unknown> => {
    if (!path) {
      return undefined;
    }

    const root = ensure(
      await args.denops.call("vimrc#FindProjectRoot", path),
      is.String,
    );
    if (root !== "") {
      return root;
    }
    try {
      const info = await Deno.stat(path);
      if (info.isFile) {
        return dirname(path);
      } else if (info.isDirectory) {
        return path;
      }
    } catch (_: unknown) {
      // Do nothing.
    }
    return undefined;
  };

  const action = ensure(args.items[0].action, isFileActionData);
  const root = getRoot(action.path);
  if (root) {
    await args.denops.call("ddu#start", {
      name: args.options.name,
      push: true,
      sources: [
        { name: "file_rec", options: { path: root } },
      ],
    });
  }
  return ActionFlags.None;
}
