import { useEval } from "jsr:@denops/std@^7.5.0/eval/use-eval";
import { feedkeys } from "jsr:@denops/std@^7.5.0/function";
import { type Action, defineAction } from "jsr:@vim-fall/std@^0.11.0/action";
import type { Detail } from "../source/gin.ts";

export function execute(): Action<Detail> {
  return defineAction<Detail>(
    async (denops, { item, selectedItems }, { signal }) => {
      const target = selectedItems?.at(0) ?? item;
      if (target) {
        const key = target.detail.gin.actionKey;
        signal?.throwIfAborted();
        await useEval(denops, async (denops) => {
          await feedkeys(denops, key, "i");
        });
      }
    },
  );
}

export const defaultGinActions = {
  execute,
};
