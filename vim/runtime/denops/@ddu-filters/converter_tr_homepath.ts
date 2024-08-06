import {
  BaseFilter,
  DduItem,
  type Denops,
  SourceOptions,
} from "jsr:@shougo/ddu-vim@~5.0.0/types";
import * as fn from "jsr:@denops/std@~7.0.3/function";

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
