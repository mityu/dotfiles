import type { Denops } from "jsr:@denops/std@^7.4.0";
import { RawString, rawString as r } from "jsr:@denops/std@^7.5.0/eval/string";
import { enumerate } from "jsr:@core/iterutil@^0.9.0/enumerate";
import { defineSource, type Source } from "jsr:@vim-fall/std@^0.11.0/source";

export type Detail = {
  fern: { actionKey: RawString };
};

async function listFernMaps(denops: Denops) {
  return await denops.eval(
    "maplist()->filter({_, v -> stridx(v.lhs, '<Plug>(fern-action-') == 0})->map({_, v -> v.lhs})",
  ) as string[];
}

export function fernAction(): Source<Detail> {
  return defineSource(async function* (denops, _params, { signal }) {
    const maps = await listFernMaps(denops);
    signal?.throwIfAborted();

    console.log(maps);
    const actions = maps.map((v) => v.match(/^<Plug>\(fern-action-(.*)\)/)![1]);

    for (const [id, action] of enumerate(actions)) {
      signal?.throwIfAborted();
      yield {
        id,
        value: action,
        detail: { fern: { actionKey: r`\<Plug>(fern-action-${action})` } },
      };
    }
  });
}
