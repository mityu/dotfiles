import type { Denops } from "jsr:@denops/std@^7.4.0";
import { OpenOptions } from "jsr:@vim-fall/std@^0.11.0/builtin/action/open";
import { type Action, defineAction } from "jsr:@vim-fall/std@^0.11.0/action";
import { ensure } from "jsr:@core/unknownutil@4.3.0/ensure";
import { isString } from "jsr:@core/unknownutil@4.3.0/is/string";
import { open as openBuffer } from "jsr:@denops/std@^7.4.0/buffer";

type Detail = {
  path: string;
};

async function searchProjectRoot(
  denops: Denops,
  path: string,
): Promise<string> {
  const fn = denops.meta.host === "vim"
    ? "vimrc#SearchProjectRoot"
    : "vimrc#fall#searchProjectRoot";
  return ensure(await denops.call(fn, path), isString);
}

export function actionOpenProjectRoot(
  options: OpenOptions = {},
): Action<Detail> {
  const bang = options.bang ?? false;
  const mods = options.mods ?? "";
  const cmdarg = options.cmdarg ?? "";
  const opener = options.opener ?? "edit";
  const splitter = options.splitter ?? opener;

  return defineAction<Detail>(
    async (denops, { item, selectedItems }, { signal }) => {
      const items = selectedItems ?? [item];
      let currentOpener = opener;

      for (const item of items.filter((v) => !!v)) {
        const root = await searchProjectRoot(denops, item.detail.path);
        if (root === "") {
          continue;
        }

        await openBuffer(denops, root, {
          bang,
          mods,
          cmdarg,
          opener: currentOpener,
        });
        signal?.throwIfAborted();

        currentOpener = splitter;
      }
    },
  );
}

export function actionSearchProjectRoot(command: string): Action<Detail> {
  return defineAction<Detail>(
    async (denops, { item, selectedItems }, { signal }) => {
      const target = selectedItems?.at(0) ?? item;
      if (!target) {
        return;
      }

      const root = await searchProjectRoot(denops, target.detail.path);
      signal?.throwIfAborted();

      await denops.dispatch(denops.name, "picker:command", [command, root]);
    },
  );
}
