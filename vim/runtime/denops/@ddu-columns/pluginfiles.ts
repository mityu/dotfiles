import {
  BaseColumn,
  DduItem,
  ItemHighlight,
} from "https://deno.land/x/ddu_vim@v3.4.3/types.ts";
import { GetTextResult } from "https://deno.land/x/ddu_vim@v3.4.3/base/column.ts";
import { Denops, fn } from "https://deno.land/x/ddu_vim@v3.4.3/deps.ts";
import { SEP_PATTERN } from "https://deno.land/std@0.210.0/path/mod.ts";
import { is } from "https://deno.land/x/unknownutil@v3.11.0/mod.ts";

type Params = {
  hlGroup: string;
};

// This function is from here. Thanks!
// https://github.com/kyoh86/ddu-filter-converter_hl_dir/blob/541c4e9aa496424b33e09ac636cea5871c47c8dd/denops/%40ddu-filters/converter_hl_dir.ts#L15-L19
function getPath(item: DduItem): string | undefined {
  if (is.ObjectOf({ action: is.ObjectOf({ path: is.String }) })(item)) {
    return item.action.path;
  }
}

function getPackagePlace(path: string | undefined): string {
  if (!path) {
    return "no-information";
  }
  const elems = path.split(SEP_PATTERN);
  const idx = elems.findLastIndex((e: string) => e === "start" || e === "opt");
  if (idx <= 0) {
    return "no-information";
  }
  return elems.slice(idx - 1, idx + 1).join("/");
}

export class Column extends BaseColumn<Params> {
  override async getLength(args: {
    denops: Denops;
    columnParams: Params;
    items: DduItem[];
  }): Promise<number> {
    const widths = await Promise.all(args.items.map(
      async (item) => {
        const path = getPath(item);
        const place = getPackagePlace(path);
        return await fn.strwidth(args.denops, `(${place})`);
      },
    )) as number[];
    return Math.max(...widths) + 1;
  }

  override async getText(args: {
    denops: Denops;
    columnParams: Params;
    startCol: number;
    endCol: number;
    item: DduItem;
  }): Promise<GetTextResult> {
    const path = getPath(args.item);
    const place = getPackagePlace(path);
    const hint = `(${place})`;
    const width = await fn.strwidth(args.denops, hint);
    const padding = " ".repeat(args.endCol - args.startCol - width);

    const itemHighlight: ItemHighlight = {
      name: "ddu_column_pluginfiles_place_hint",
      hl_group: args.columnParams.hlGroup,
      col: args.startCol,
      width: width,
    };

    return Promise.resolve({
      text: hint + padding + args.item.word,
      highlights: [itemHighlight],
    });
  }

  override params(): Params {
    return {
      hlGroup: "Directory",
    };
  }
}
