import type { Entrypoint } from "jsr:@vim-fall/custom@^0.1.0";
import {
  composeSources,
  Coordinator,
  defineRefiner,
  defineRenderer,
  Detail,
  Layout,
  refineCurator,
  Refiner,
  refineSource,
  Renderer,
  Size,
} from "jsr:@vim-fall/std@^0.11.0";
import * as builtin from "jsr:@vim-fall/std@^0.11.0/builtin";
import * as extra from "jsr:@vim-fall/extra@^0.2.0";
import { mrMixed } from "jsr:@mityu/fall-source-mr-mixed@^0.1.0";
import { SEPARATOR, SEPARATOR_PATTERN } from "jsr:@std/path@^1.0.8/constants";
import { isAbsolute } from "jsr:@std/path@^1.0.0/is-absolute";
import { which } from "jsr:@david/which@^0.4.1";
import { matcherMultiRegexp as matcherMultiRegexpBase } from "./matcher_multi_regexp.ts";
import { actionOpenProjectRoot } from "./action_open_root.ts";
import * as fileSource from "./source_file.ts";
import { ginAction } from "./source/gin.ts";
import { defaultGinActions } from "./action/gin.ts";

// NOTE:
//
// Install https://github.com/BurntSushi/ripgrep to use 'builtin.curator.rg'
// Install https://www.nerdfonts.com/ to use 'builtin.renderer.nerdfont'
// Install https://github.com/thinca/vim-qfreplace to use 'Qfreplace'
//
//

async function isExecutable(cmd: string): Promise<boolean> {
  if (isAbsolute(cmd)) {
    try {
      const info = await Deno.stat(cmd);
      if (info.mode != null) {
        return (info.mode & 0o100) !== 0;
      } else {
        // On Windows, info.mode is not available.  Only check if it is a file
        // or not.
        return info.isFile;
      }
    } catch (_) {
      return false;
    }
  } else {
    return !!await which(cmd);
  }
}

const strByteLen = (() => {
  const encoder = new TextEncoder();
  return (s: string) => encoder.encode(s).length;
})();

type CoordinateOptions = builtin.coordinator.ModernOptions;

const coordinator = (
  options?: CoordinateOptions,
): Coordinator => {
  const coordinateOptions = {
    widthMin: 60,
    heightMin: 20,
    previewRatio: 0.45,
    hidePreview: false,
    ...(options ?? {}),
  } satisfies CoordinateOptions;

  const { layout: withPreviewLayout, style } = builtin.coordinator.modern(
    { ...coordinateOptions, hidePreview: false },
  );
  const { layout: noPreviewLayout } = builtin.coordinator.modern(
    { ...coordinateOptions, hidePreview: true },
  );

  const layout = (screen: Size): Layout => {
    if (!coordinateOptions.hidePreview) {
      const layouted = withPreviewLayout(screen);
      if (layouted.list.width >= coordinateOptions.widthMin) {
        return layouted;
      }
    }
    return noPreviewLayout(screen);
  };

  return { style, layout };
};

const refinerReplaceHomepath = (): Refiner<{ path: string }> => {
  return defineRefiner(async function* (denops, { items }, { signal }) {
    const homePath = await denops.call("expand", "~") as string;
    signal?.throwIfAborted();

    for await (const item of items) {
      signal?.throwIfAborted();
      if (item.detail.path.startsWith(homePath)) {
        const path = "~" + item.detail.path.substring(homePath.length);
        const value = item.value.replace(item.detail.path, path);
        yield { ...item, value };
      } else {
        yield item;
      }
    }
  });
};

const refinerAddSourceName = (
  sourceName: string,
): Refiner<Detail & { sourceName?: string }> => {
  return defineRefiner(async function* (_denops, { items }, { signal }) {
    for await (const item of items) {
      signal?.throwIfAborted();
      yield {
        ...item,
        detail: {
          ...item.detail,
          sourceName,
        },
      };
    }
  });
};

const rendererShowSourceName = (
  highlight: string = "Normal",
): Renderer<Detail & { sourceName?: string }> => {
  return defineRenderer((_denops, { items }, { signal }) => {
    const strlen = (() => {
      const encoder = new TextEncoder();
      return (s: string) => encoder.encode(s).length;
    })();
    items.forEach((item) => {
      if (!item.detail.sourceName) {
        return;
      }
      signal?.throwIfAborted();
      const prefixLen = strlen(item.detail.sourceName) + 2;
      const decoration = {
        column: 1,
        length: prefixLen,
        highlight,
      };
      const label = item.label ?? item.value;
      item.label = `(${item.detail.sourceName}) ${label}`;
      item.decorations = [
        decoration,
        ...((item.decorations ?? []).map((v) => ({
          ...v,
          column: v.column + prefixLen + 1,
        }))),
      ];
    });
  });
};

const rendererShowPackpath = (
  highlight: string = "Normal",
): Renderer<{ path: string }> => {
  const getPackagePlace = (path: string): string => {
    const elems = path.split(SEPARATOR_PATTERN);
    const idx = elems.findIndex((e: string) => e === "start" || e === "opt");
    if (idx <= 0) {
      return "no-information";
    }
    return elems.slice(idx - 1, idx + 1).join("/");
  };

  return defineRenderer((_denops, { items }, { signal }) => {
    items.forEach((item) => {
      signal?.throwIfAborted();
      const hint = `(${getPackagePlace(item.detail.path)})`;
      const hintLength = strByteLen(hint);
      item.label = `${hint} ${item.label ?? item.value}`;
      item.decorations = [
        { column: 1, length: hintLength, highlight },
        ...((item.decorations ?? []).map((v) => ({
          ...v,
          column: v.column + hintLength + 1,
        }))),
      ];
    });
  });
};

const matcherMultiRegexp = matcherMultiRegexpBase({ ignoreCase: true });

const myPathActions = {
  ...builtin.action.defaultOpenActions,
  "open:tab": builtin.action.open({
    opener: "tab",
    splitter: "vsplit",
    mods: "botright",
  }),
  "open:project-root": actionOpenProjectRoot,
  ...builtin.action.defaultSystemopenActions,
  ...builtin.action.defaultCdActions,
};

const myQuickfixActions = {
  ...builtin.action.defaultQuickfixActions,
  "quickfix:qfreplace": builtin.action.quickfix({
    after: "Qfreplace",
  }),
};

const myMiscActions = {
  ...builtin.action.defaultEchoActions,
  ...builtin.action.defaultYankActions,
  "sub:multi-regexp": builtin.action.submatch([matcherMultiRegexp]),
  ...builtin.action.defaultSubmatchActions,
};

const myFilterFile = (path: string) => {
  const excludes = [
    ".7z",
    ".DS_Store",
    ".avi",
    ".avi",
    ".bmp",
    ".class",
    ".dll",
    ".dmg",
    ".doc",
    ".docx",
    ".dylib",
    ".ear",
    ".exe",
    ".fla",
    ".flac",
    ".flv",
    ".gif",
    ".ico",
    ".id_ed25519",
    ".id_rsa",
    ".iso",
    ".jar",
    ".jpeg",
    ".jpg",
    ".key",
    ".mkv",
    ".mov",
    ".mp3",
    ".mp4",
    ".mpeg",
    ".mpg",
    ".o",
    ".obj",
    ".ogg",
    ".pdf",
    ".png",
    ".ppt",
    ".pptx",
    ".rar",
    ".so",
    ".swf",
    ".tar.gz",
    ".war",
    ".wav",
    ".webm",
    ".wma",
    ".wmv",
    ".xls",
    ".xlsx",
    ".zip",
    "id_ed25519",
    "id_rsa",
  ];
  for (const exclude of excludes) {
    if (path.endsWith(exclude)) {
      return false;
    }
  }
  return true;
};

const myFilterDirectory = (path: string) => {
  const excludes = [
    "$RECYVLE.BIN",
    ".cache",
    ".git",
    ".hg",
    ".ssh",
    ".svn",
    "__pycache__", // Python
    // "build", // C/C++
    "node_modules", // Node.js
    "target", // Rust
    ".coverage",
    `karabiner${SEPARATOR}automatic_backups`,
  ];
  for (const exclude of excludes) {
    if (path.endsWith(`${SEPARATOR}${exclude}`)) {
      return false;
    }
  }
  return true;
};

const fileFilterOpts = {
  filterFile: myFilterFile,
  filterDirectory: myFilterDirectory,
  relativeFromBase: true,
} as const;

const filePickerParams = {
  matchers: [
    matcherMultiRegexp,
  ],
  renderers: [
    builtin.renderer.nerdfont,
  ],
  previewers: [
    builtin.previewer.file,
    builtin.previewer.noop,
  ],
  actions: {
    ...myPathActions,
    ...myQuickfixActions,
    ...myMiscActions,
  },
  defaultAction: "open",
} as const;

export const main: Entrypoint = async (
  {
    definePickerFromSource,
    definePickerFromCurator,
    refineSetting,
    refineActionPicker,
  },
) => {
  refineSetting({
    coordinator: coordinator({
      widthRatio: 0.9,
      heightRatio: 0.8,
    }),
    theme: builtin.theme.MODERN_THEME,
  });
  refineActionPicker({ matchers: [matcherMultiRegexp] });

  const grepCurator = await isExecutable("rg")
    ? builtin.curator.rg
    : builtin.curator.grep;

  definePickerFromCurator(
    "grep",
    refineCurator(
      grepCurator,
      builtin.refiner.relativePath,
    ),
    {
      renderers: [
        builtin.renderer.nerdfont,
      ],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromCurator(
    "git-grep",
    refineCurator(
      builtin.curator.gitGrep,
      builtin.refiner.relativePath,
    ),
    {
      renderers: [
        builtin.renderer.nerdfont,
      ],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
      },
      defaultAction: "open",
    },
  );

  // definePickerFromSource(
  //   "mrr",
  //   extra.source.mr({ type: "mrr" }),
  //   {
  //     matchers: [builtin.matcher.substring],
  //     renderers: [
  //       builtin.renderer.nerdfont,
  //     ],
  //     actions: {
  //       ...myPathActions,
  //       ...myQuickfixActions,
  //       ...myMiscActions,
  //       ...extra.action.defaultMrDeleteActions,
  //       "cd-and-open": composeActions(
  //         builtin.action.cd,
  //         builtin.action.open,
  //       ),
  //     },
  //     defaultAction: "cd-and-open",
  //     coordinator: coordinator({
  //       hidePreview: true,
  //     }),
  //   },
  // );

  // Search files in the parent directory.
  definePickerFromSource(
    "file",
    fileSource.file(fileFilterOpts),
    filePickerParams,
  );

  // Search files in the parent directory, but don't pre-filter files.
  definePickerFromSource(
    "file:all",
    builtin.source.file({ relativeFromBase: true }),
    filePickerParams,
  );

  // Search files in the current project directory.
  definePickerFromSource(
    "file:project",
    fileSource.project(fileFilterOpts),
    filePickerParams,
  );

  // Search files of plugins.
  definePickerFromSource(
    "file:pack",
    composeSources(
      fileSource.minpac(fileFilterOpts),
      fileSource.localpack(fileFilterOpts),
    ),
    { ...filePickerParams, renderers: [rendererShowPackpath("LineNr")] },
  );

  definePickerFromSource(
    "file:runtime",
    fileSource.runtimeFiles(fileFilterOpts),
    filePickerParams,
  );

  definePickerFromSource(
    "file:dotfiles",
    fileSource.dotfiles(fileFilterOpts),
    filePickerParams,
  );

  definePickerFromSource(
    "mru",
    composeSources(
      refineSource(
        // extra.source.mr,
        mrMixed,
        refinerReplaceHomepath,
      ),
      refineSource(
        fileSource.gitrepo(fileFilterOpts),
        refinerAddSourceName("repo"),
      ),
      refineSource(
        fileSource.dotfiles(fileFilterOpts),
        refinerAddSourceName("dotfiles"),
      ),
    ),
    {
      matchers: [matcherMultiRegexp],
      renderers: [
        rendererShowSourceName("LineNr"),
      ],
      previewers: [builtin.previewer.file],
      actions: {
        ...myPathActions,
        ...myQuickfixActions,
        ...myMiscActions,
        ...extra.action.defaultMrDeleteActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource("line", builtin.source.line, {
    matchers: [builtin.matcher.substring],
    previewers: [builtin.previewer.buffer],
    actions: {
      ...myQuickfixActions,
      ...myMiscActions,
      ...builtin.action.defaultOpenActions,
      ...builtin.action.defaultBufferActions,
    },
    defaultAction: "open",
  });

  definePickerFromSource(
    "buffer",
    builtin.source.buffer({ filter: "bufloaded" }),
    {
      matchers: [builtin.matcher.substring],
      previewers: [builtin.previewer.buffer],
      actions: {
        ...myQuickfixActions,
        ...myMiscActions,
        ...builtin.action.defaultOpenActions,
        ...builtin.action.defaultBufferActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource("help", builtin.source.helptag, {
    matchers: [builtin.matcher.substring],
    previewers: [builtin.previewer.helptag],
    actions: {
      ...myMiscActions,
      ...builtin.action.defaultHelpActions,
    },
    defaultAction: "help",
  });

  definePickerFromSource("quickfix", builtin.source.quickfix, {
    matchers: [builtin.matcher.substring],
    previewers: [builtin.previewer.buffer],
    actions: {
      ...builtin.action.defaultOpenActions,
      ...myMiscActions,
    },
    defaultAction: "open",
  });

  definePickerFromSource("gin-action", ginAction, {
    matchers: [matcherMultiRegexp],
    previewers: [],
    actions: {
      ...defaultGinActions,
    },
    defaultAction: "execute",
    coordinator: coordinator({
      heightRatio: 0.4,
      widthRatio: 0.4,
      hidePreview: true,
    }),
  });
};
