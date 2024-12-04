import type { Denops } from "jsr:@denops/std@~7.4.0";
import {
  DduItem,
  SourceOptions,
} from "jsr:@shougo/ddu-vim@~9.0.0/types";
import { BaseFilter } from "jsr:@shougo/ddu-vim@~9.0.0/filter";
import * as fn from "jsr:@denops/std@~7.4.0/function";

type Params = Record<string, never>;

export class Filter extends BaseFilter<Params> {
  override async filter(args: {
    denops: Denops;
    sourceOptions: SourceOptions;
    items: DduItem[];
  }): Promise<DduItem[]> {
    const homePath = await fn.expand(args.denops, "~") as string;
    for (const item of args.items) {
      if (item.matcherKey.startsWith(homePath)) {
        item.matcherKey = "~" + item.matcherKey.substring(homePath.length);
        (item as Record<string, unknown>)[args.sourceOptions.matcherKey] =
          item.matcherKey;
      }
    }
    return Promise.resolve(args.items);
  }

  override params(): Params {
    return {};
  }
}
