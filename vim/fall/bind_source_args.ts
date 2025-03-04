import type { Denops } from "jsr:@denops/std@^7.4.0";
import type { Source } from "jsr:@vim-fall/core@^0.3.0/source";
import type { Detail } from "jsr:@vim-fall/core@^0.3.0/item";
import type { Derivable } from "jsr:@vim-fall/custom@^0.1.0/derivable";
import { defineSource } from "jsr:@vim-fall/std@^0.11.0/source";

export type BindArgumentsProvider =
  | string[]
  | ((denops: Denops) => string[] | Promise<string[]>);

export function bindSourceArguments<T extends Detail = Detail>(
  baseSource: Derivable<Source<T>>,
  args: BindArgumentsProvider,
): Source<T> {
  const source = ((): Source<T> => {
    if (typeof baseSource === "function") {
      return baseSource();
    } else {
      return baseSource;
    }
  })();

  return defineSource(async function* (denops, params, options) {
    const bindArgs = await (async (): Promise<string[]> => {
      if (typeof args === "function") {
        return await args(denops);
      } else {
        return args;
      }
    })();
    const iter = source.collect(
      denops,
      { ...params, args: [...bindArgs, ...params.args] },
      options,
    );
    for await (const item of iter) {
      yield item;
    }
  });
}
