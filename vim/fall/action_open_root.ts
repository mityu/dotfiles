import { OpenOptions } from "jsr:@vim-fall/std@^0.10.0/builtin/action/open";
import { type Action, defineAction } from "jsr:@vim-fall/std@^0.10.0/action";
import { ensure } from "jsr:@core/unknownutil@4.3.0/ensure";
import { isString } from "jsr:@core/unknownutil@4.3.0/is/string";
import { open as openBuffer } from "jsr:@denops/std@7.4.0/buffer";

type Detail = {
  path: string;
};

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
        const root = ensure(
          await denops.call("vimrc#FindProjectRoot", item.detail.path),
          isString,
        );
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
