import {
  BaseFilter,
  DduItem,
  type Denops,
  SourceOptions,
} from "jsr:@shougo/ddu-vim@~5.0.0/types";
import { SEPARATOR_PATTERN } from "jsr:@std/path@~1.0.2"

type Params = {
  hlGroup: string;
};

function getPackagePlace(path: string): string {
  const elems = path.split(SEPARATOR_PATTERN);
  const idx = elems.findLastIndex((e: string) => e === "start" || e === "opt");
  if (idx <= 0) {
    return "no-information";
  }
  return elems.slice(idx - 1, idx + 1).join("/");
}

export class Filter extends BaseFilter<Params> {
  override filter(args: {
    denops: Denops;
    sourceOptions: SourceOptions;
    filterParams: Params;
    items: DduItem[];
  }): Promise<DduItem[]> {
    const packpath = getPackagePlace(args.sourceOptions.path as string);
    const hintLength = (new TextEncoder()).encode(`(${packpath})`).length;

    return Promise.resolve(args.items.map((item) => {
      const { word, display = word, highlights = [] } = item;
      highlights.forEach((hl) => {
        hl.col += hintLength + 1;
      });
      highlights.push({
        name: "package_path_hint",
        col: 1,
        width: hintLength,
        hl_group: args.filterParams.hlGroup,
      });
      item.display = `(${packpath}) ${display}`;
      item.highlights = highlights;
      return item;
    }));
  }

  override params(): Params {
    return {
      hlGroup: "Directory",
    };
  }
}
