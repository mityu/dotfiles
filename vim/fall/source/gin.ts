import type { Denops } from "jsr:@denops/std@^7.4.0";
import { RawString, rawString as r } from "jsr:@denops/std@^7.5.0/eval/string";
import { enumerate } from "jsr:@core/iterutil@^0.9.0/enumerate";
import { defineSource, type Source } from "jsr:@vim-fall/std@^0.11.0/source";

export type Detail = {
  gin: { actionKey: RawString };
};

async function listGinMaps(denops: Denops) {
  return await denops.eval(
    "maplist()->filter({_, v -> stridx(v.lhs, '<Plug>(gin-action-') == 0})->map({_, v -> v.lhs})",
  ) as string[];
}

export function ginAction(): Source<Detail> {
  return defineSource(async function* (denops, _params, { signal }) {
    const maps = await listGinMaps(denops);
    signal?.throwIfAborted();

    const actions = maps.map((v) => v.match(/^<Plug>\(gin-action-(.*)\)/)![1]);

    for (const [id, action] of enumerate(actions)) {
      signal?.throwIfAborted();
      yield {
        id,
        value: action,
        detail: { gin: { actionKey: r`\<Plug>(gin-action-${action})` } },
      };
    }
  });
}
