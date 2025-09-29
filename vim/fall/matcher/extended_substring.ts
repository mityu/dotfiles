import { defineMatcher, Matcher } from "jsr:@vim-fall/std@^0.11.0/matcher";

type Tester = (
  item: string,
  query: string,
) => { column: number; length: number } | undefined;

type Matchers = {
  query: string;
  tester: Tester;
}[];

function testerSubstring(item: string, query: string): ReturnType<Tester> {
  const index = item.indexOf(query);
  if (index < 0) {
    return undefined;
  }
  return { column: index + 1, length: strlen(query) };
}

function testerStartsWith(item: string, query: string): ReturnType<Tester> {
  if (item.startsWith(query)) {
    return { column: 1, length: strlen(query) };
  }
  return undefined;
}

function testerEndsWith(item: string, query: string): ReturnType<Tester> {
  if (item.endsWith(query)) {
    const itemLen = strlen(item);
    const queryLen = strlen(query);
    return { column: itemLen - queryLen + 1, length: queryLen };
  }
  return undefined;
}

function splitUserQuery(query: string): string[] {
  const sep = /(?<!(?<=(?:^|[^\\])(?:\\\\)*)\\)\s/;
  return query.split(sep).filter((v) => v.length != 0);
}

function removeBackslashBeforeSpecialChar(input: string): string {
  return input.replace(/\\(?=\s|\^|\$|\\)/g, "");
}

function parseUserQuery(query: string): Matchers {
  const matchers = [] as Matchers;

  splitUserQuery(query).forEach((v) => {
    const tailDollar = /(?<!(?<=(?:^|[^\\])(?:\\\\)*)\\)\$$/;
    if (v.startsWith("^")) {
      matchers.push({
        query: removeBackslashBeforeSpecialChar(v.substring(1)),
        tester: testerStartsWith,
      });
    } else if (tailDollar.test(v)) {
      matchers.push({
        query: removeBackslashBeforeSpecialChar(v.substring(0, v.length - 1)),
        tester: testerEndsWith,
      });
    } else {
      matchers.push({
        query: removeBackslashBeforeSpecialChar(v),
        tester: testerSubstring,
      });
    }
  });

  return matchers;
}

function strlen(s: string): number {
  return (new TextEncoder()).encode(s).length;
}

export type ExtendedSubstringOptions = {
  ignoreCase?: boolean;
  smartCase?: boolean;
};

export const matcherExtendedSubstring = (
  opts?: ExtendedSubstringOptions,
): Matcher => {
  return defineMatcher(async function* (_denops, { query, items }, { signal }) {
    const ignoreCase = opts?.ignoreCase &&
      !(opts?.smartCase && /[A-Z]/.test(query));

    const matchers = parseUserQuery(ignoreCase ? query.toLowerCase() : query);

    if (matchers.length === 0) {
      // Query is equals to empty query.
      yield* items;
      return;
    }

    for await (const item of items) {
      signal?.throwIfAborted();

      const text = ignoreCase ? item.value.toLowerCase() : item.value;
      const matches = matchers.map(({ query, tester }) => tester(text, query));
      if (!matches.every((v) => !!v)) {
        continue;
      }

      yield {
        ...item,
        decorations: [...(item.decorations ?? []), ...matches],
      };
    }
  });
};
