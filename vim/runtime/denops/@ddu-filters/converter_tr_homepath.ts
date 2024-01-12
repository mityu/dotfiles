import {
  BaseFilter,
  DduItem,
  SourceOptions,
} from "https://deno.land/x/ddu_vim@v3.9.0/types.ts";
import { Denops, fn } from "https://deno.land/x/ddu_vim@v3.9.0/deps.ts";

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
