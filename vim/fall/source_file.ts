import type { Denops } from "jsr:@denops/std@^7.4.0";
import { collect } from "jsr:@denops/std@^7.4.0/batch";
import { expand, getcwd } from "jsr:@denops/std@^7.4.0/function";
import { ensure } from "jsr:@core/unknownutil@^4.3.0/ensure";
import { isString } from "jsr:@core/unknownutil@^4.3.0/is/string";
import { composeSources, defineSource } from "jsr:@vim-fall/std@^0.11.0/source";
import { bindSourceArgs } from "jsr:@vim-fall/std@^0.11.0";
import { join } from "jsr:@std/path@^1.0.0/join";
import { dirname } from "jsr:@std/path@^1.0.0/unstable-dirname";
import { exists } from "jsr:@std/fs@^1.0.0/exists";
import {
  file as fileBase,
  type FileOptions,
} from "jsr:@vim-fall/std@^0.11.0/builtin/source/file";

const callVim = async (
  denops: Denops,
  fn: string,
  ...args: unknown[]
): Promise<string> => {
  return ensure(await denops.call(fn, ...args), isString);
};

const findDir = async (name: string, basePath: string) => {
  name = name.replace(/\/$/, "");
  for (;;) {
    if (await exists(join(basePath, name), { isDirectory: true })) {
      return basePath;
    }

    const nextPath = dirname(basePath);
    if (nextPath === basePath) {
      return undefined;
    }
    basePath = nextPath;
  }
};

export const file = fileBase;

export const project = (options: FileOptions = {}) => {
  return bindSourceArgs(
    file(options),
    async (denops) => [await callVim(denops, "vimrc#FindProjectRoot", "")],
  );
};

export const runtimeFiles = (options: FileOptions = {}) => {
  return bindSourceArgs(
    file(options),
    (_) => {
      const dir = Deno.env.get("VIMRUNTIME");
      if (!dir) {
        throw Error("$VIMRUNTIME is not set");
      }
      return [dir];
    },
  );
};

export const dotfiles = (options: FileOptions = {}) => {
  return bindSourceArgs(
    file(options),
    async (denops) => [await callVim(denops, "FallGetStdpath", "dotfiles")],
  );
};

export const minpac = (options: FileOptions = {}) => {
  return bindSourceArgs(
    file(options),
    async (denops) => [await callVim(denops, "FallGetStdpath", "packpath")],
  );
};

export const localpack = (options: FileOptions = {}) => {
  return composeSources(
    bindSourceArgs(
      file(options),
      async (
        denops,
      ) => [
        join(await callVim(denops, "FallGetStdpath", "localpack"), "start"),
      ],
    ),
    bindSourceArgs(
      file(options),
      async (
        denops,
      ) => [join(await callVim(denops, "FallGetStdpath", "localpack"), "opt")],
    ),
  );
};

/**
 * Automatically find the git repository top from the current buffer's file
 * name or the current working directory, and list the files in the directory.
 */
export const gitrepo = (options: FileOptions = {}) => {
  const source = file(options);
  return defineSource(async function* (denops, { args }, options) {
    const basePath = await (async () => {
      if (args.length !== 0) {
        return args[0];
      } else {
        const [curfile, cwd] = await collect(
          denops,
          (denops) => [expand(denops, "%:p"), getcwd(denops, 0)],
        ) as [string, string];
        return curfile !== "" ? curfile : cwd;
      }
    })();

    const path = await findDir(".git", basePath);
    if (path) {
      yield* source.collect(denops, { args: [path] }, options);
    }
  });
};
