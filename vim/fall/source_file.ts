import type { Denops } from "jsr:@denops/std@^7.4.0";
import { ensure } from "jsr:@core/unknownutil@^4.3.0/ensure";
import { isString } from "jsr:@core/unknownutil@^4.3.0/is/string";
import { composeSources } from "jsr:@vim-fall/std@^0.11.0/source";
import { bindSourceArgs } from "jsr:@vim-fall/std@^0.11.0";
import { join } from "jsr:@std/path@^1.0.0/join";
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
