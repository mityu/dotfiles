import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddu-vim@~5.0.0/config";
import {
  type ActionArguments,
  ActionFlags,
} from "jsr:@shougo/ddu-vim@~5.0.0/types";
import { Params as FFParams } from "jsr:@shougo/ddu-ui-ff@~1.2.0";
import { type ActionData as FileActionData } from "jsr:@shougo/ddu-kind-file@~0.8.0";
import { exists as vimFnExists } from "jsr:@denops/std@~7.0.0/function";
import { is } from "jsr:@core/unknownutil@~4.3.0/is";
import { as } from "jsr:@core/unknownutil@~4.3.0/as";
import { assert } from "jsr:@core/unknownutil@~4.3.0/assert";
import { ensure } from "jsr:@core/unknownutil@~4.3.0/ensure";
import { type PredicateType } from "jsr:@core/unknownutil@~4.3.0/type";
import { assertType, Has } from "jsr:@std/testing@~1.0.0/types";
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
      ui: "ff",
      uiParams: {
        ff: {
          split: "no",
          prompt: "> ",
          highlights: {
            selected: "Number",
          },
        } satisfies Partial<FFParams>,
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
          ignoreDirectories: ["node_modules", ".git", "dist", ".vscode"],
        },
        rg: {
          args: ["--json"],
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
      uiParams: { ff: { displayTree: true } },
    });
    args.contextBuilder.patchLocal("lsp-callHierarchy", {
      sources: [{
        name: "lsp_callHierarchy",
        params: { method: "callHierarchy/outgoingCalls" },
      }],
      uiParams: { ff: { displayTree: true } },
    });

    if (await vimFnExists(args.denops, "#User#vimrc:dduConfigPost")) {
      await args.denops.cmd("doautocmd User vimrc:dduConfigPost");
    }

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
