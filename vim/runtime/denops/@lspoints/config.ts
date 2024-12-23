import type { Denops } from "jsr:@denops/std@~7.4.0";
import { BaseExtension, type Lspoints } from "jsr:@kuuote/lspoints@~0.1.0";
import { assert as assertType } from "jsr:@core/unknownutil@~4.3.0/assert";
import { is } from "jsr:@core/unknownutil@~4.3.0/is";
import type { PredicateType } from "jsr:@core/unknownutil@~4.3.0/type";
import { assert } from "jsr:@std/assert@~1.0.0/assert";
import { dirname } from "jsr:@std/path@~1.0.0/dirname";
import { join } from "jsr:@std/path@~1.0.0/join";
import { isAbsolute } from "jsr:@std/path@~1.0.0/is-absolute";
import { exists } from "jsr:@std/fs@~1.0.0/exists";
import { which } from "jsr:@david/which@~0.4.1";
import { echo } from "jsr:@mityu/lspoints-toolkit@~0.1.2/echo";

const isAttachLspParams = is.ObjectOf({
  bufnr: is.Number,
  bufname: is.String,
  filetype: is.String,
  pwd: is.String,
});

type AttachLspParams = PredicateType<typeof isAttachLspParams>;

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

async function findMarkerDir(
  marker: string,
  dir: string,
): Promise<string | undefined> {
  for (;;) {
    const options = marker.endsWith("/")
      ? { isDirectory: true }
      : { isFile: true };

    if (await exists(join(dir, marker.replace(/\/$/, "")), options)) {
      return dir;
    }

    const upperDir = dirname(dir);
    if (upperDir === dir) {
      return undefined;
    }
    dir = upperDir;
  }
}

async function findFile(
  marker: string,
  dir: string,
): Promise<string | undefined> {
  const markerDir = await findMarkerDir(marker, dir);
  if (markerDir) {
    return join(markerDir, marker.replace(/\/$/, ""));
  }
  return undefined;
}

async function findProjectRoot(
  markers: string[],
  pwd: string,
): Promise<string | undefined> {
  assert(isAbsolute(pwd), `Not an absolute path: ${pwd}`);

  for (const marker of markers) {
    const dir = await findMarkerDir(marker, pwd);
    if (dir) {
      return dir;
    }
  }
  return undefined;
}

async function attachLsp(
  denops: Denops,
  lspoints: Lspoints,
  ctx: AttachLspParams,
) {
  if (ctx.bufname === "" || URL.canParse(ctx.bufname)) {
    return;
  }

  const attach = async (lsp: string, opts: Record<string, unknown>) => {
    const clients = lspoints.getClients(ctx.bufnr).filter((client) =>
      client.name === lsp
    );
    if (clients.length !== 0) {
      return; // Lsp seems to be already attached.
    }

    const cmd = lspoints.settings.get().startOptions[lsp].cmd?.at(0);
    if (!cmd) {
      await echo(denops, `Command is not specified: ${lsp}`, {
        highlight: "WarningMsg",
      });
      return;
    } else if (!await isExecutable(cmd)) {
      await echo(denops, `Executable not found: ${cmd}`, {
        highlight: "WarningMsg",
      });
      return;
    }

    await denops.dispatch("lspoints", "start", lsp, opts);
    await denops.dispatch("lspoints", "attach", lsp, ctx.bufnr);
    await echo(
      denops,
      `lspoints#attach: ${ctx.bufnr}: ${lsp}: ${JSON.stringify(opts)}`,
      { record: true, prefix: "" },
    );
  };

  const matchFiletype = (filetypes: string[]) => {
    return filetypes.indexOf(ctx.filetype) !== -1;
  };

  const workDir = dirname(ctx.bufname);
  const genericMarkers = [".git/"];

  if (matchFiletype(["c", "cpp", "objc", "objcpp"])) {
    const markers = [
      "compile_flags.txt",
      ...genericMarkers,
      "Makefile",
    ];
    await attach("clangd", {
      rootPath: await findProjectRoot(markers, workDir),
    });
  } else if (matchFiletype(["typescript", "typescriptreact"])) {
    const markers = [
      "deno.json",
      "deno.jsonc",
      ...genericMarkers,
      "denops/",
    ];
    await attach("denols", {
      rootPath: await findProjectRoot(markers, workDir),
      settings: {
        deno: {
          importMap: await findFile("import_map.json", workDir),
          config: await findFile("deno.json", workDir),
        },
      },
    });
  } else if (matchFiletype(["ocaml"])) {
    const markers = [
      "dune-project",
      ...genericMarkers,
    ];
    await attach("ocamllsp", {
      rootPath: await findProjectRoot(markers, workDir),
    });
  } else if (matchFiletype(["rust"])) {
    const markers = [
      "Cargo.toml",
      ...genericMarkers,
    ];
    await attach("rust-analyzer", {
      rootPath: await findProjectRoot(markers, workDir),
    });
  } else if (matchFiletype(["go"])) {
    const markers = [
      "go.mod",
      "go.sum",
      ...genericMarkers,
    ];
    await attach("gopls", {
      rootPath: await findProjectRoot(markers, workDir),
    });
  } else if (matchFiletype(["tex", "plaintex"])) {
    await attach("texlab", {
      rootPath: await findProjectRoot(genericMarkers, workDir),
      workspace_config: {
        texlab: { build: { executable: "latexmk", "args": [] } },
      },
    });
  } else if (matchFiletype(["typst"])) {
    await attach("tinymist", {
      rootPath: await findProjectRoot(genericMarkers, workDir),
    });
  }
}

export class Extension extends BaseExtension {
  override async initialize(denops: Denops, lspoints: Lspoints) {
    await lspoints.executeCommand("diagnostics", "enableAutoHighlight");
    await lspoints.executeCommand("diagnostics", "enableAutoVirtualText");
    await lspoints.executeCommand("diagnostics", "enableAutoSign");
    await lspoints.executeCommand("diagnostics", "enableAutoLoclist");

    lspoints.defineCommands("config", {
      attachLsp: async (ctx: unknown) => {
        assertType(ctx, isAttachLspParams);
        await attachLsp(denops, lspoints, ctx);
      },
    });

    lspoints.settings.patch({
      // tracePath: "/tmp",
      startOptions: {
        denols: {
          cmd: [Deno.execPath(), "lsp"],
          settings: {
            deno: {
              enable: true,
              lint: true,
              unstable: true,
              codeLens: {
                implementations: true,
                references: true,
                referencesAllFunctions: true,
                test: true,
                testArgs: ["--allow-all"],
              },
              suggest: {
                autoImports: true,
                completeFunctionCalls: true,
                names: true,
                paths: true,
                imports: {
                  autoDiscover: false,
                  hosts: {
                    "https://deno.land/": true,
                  },
                },
              },
            },
            typescript: {
              inlayHints: {
                parameterNames: {
                  enabled: "all",
                  suppressWhenArgumentMatchesName: true,
                },
                parameterTypes: {
                  enabled: true,
                },
                variableTypes: {
                  enabled: true,
                  suppressWhenTypeMatchesName: true,
                },
                propertyDeclarationTypes: {
                  enabled: true,
                },
                functionLikeReturnTypes: {
                  enabled: true,
                },
                enumMemberValues: {
                  enabled: true,
                },
              },
            },
          },
        },
        clangd: {
          cmd: ["clangd"],
        },
        ocamllsp: {
          cmd: ["ocamllsp"],
        },
        gopls: {
          cmd: ["gopls"],
        },
        "rust-analyzer": {
          cmd: ["rust-analyzer"],
        },
        texlab: {
          cmd: ["texlab"],
        },
        tinymist: {
          cmd: ["tinymist"],
        },
      },
    });
    await denops.cmd(
      [
        "if exists('#User#VimrcLoadLspointsConfigPost')",
        "doautocmd <nomodeline> User VimrcLoadLspointsConfigPost",
        "endif",
      ].join("|"),
    );
  }
}
