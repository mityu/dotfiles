import { defineSource, type Source } from "jsr:@vim-fall/std@^0.11.0/source";
import { enumerate } from "jsr:@core/iterutil@^0.9.0/enumerate";

export type Detail = {
  path: string;
  mr: { type: "mru" };
};

export function mruw(): Source<Detail> {
  return defineSource(async function* (denops, _params, { signal }) {
    const mruw = await denops.call("vimrc#mruw#list") as string[];
    signal?.throwIfAborted();

    for (const [id, path] of enumerate(mruw)) {
      signal?.throwIfAborted();
      yield {
        id,
        value: path,
        detail: { path, mr: { type: "mru" } },
      };
    }
  });
}
