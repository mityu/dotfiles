import { defineMatcher, Matcher } from "jsr:@vim-fall/std@^0.10.0/matcher";

function splitUserInput(input: string): string[] {
  const sep = /(?<!(?<=(?:^|[^\\])(?:\\\\)*)\\)\s/;
  return input.split(sep).filter((v) => v.length != 0);
}

function removeBackslashBeforeSpace(input: string): string {
  return input.replace(/\\(?=\s)/g, "");
}

function strlen(s: string): number {
  return (new TextEncoder()).encode(s).length;
}

export type MultiRegexpOptions = {
  ignoreCase?: boolean;
  smartCase?: boolean;
};

export const matcherMultiRegexp = (opts?: MultiRegexpOptions): Matcher => {
  return defineMatcher(async function* (_denops, { query, items }, { signal }) {
    const matchers = splitUserInput(query).map((v) =>
      removeBackslashBeforeSpace(v)
    );
    if (matchers.length === 0) {
      yield* items;
      return;
    }

    const buildRegexes = () => {
      const ignoreCase = opts?.ignoreCase &&
        !(opts?.smartCase && /[A-Z]/.test(query));
      const flags = ignoreCase ? "i" : "";
      try {
        return matchers.map((v) => new RegExp(v, flags));
      } catch (_) {
        // Ignore
      }
    };
    const regexps = buildRegexes();
    if (!regexps) {
      yield* items;
      return;
    }

    for await (const item of items) {
      signal?.throwIfAborted();

      const skip = regexps.reduce(
        (skip, re) => skip || !re.test(item.value),
        false,
      );
      if (skip) {
        continue;
      }

      // Build decorations.
      const matches = regexps.flatMap(
        (re) => {
          const matches = [];
          const r = new RegExp(re, re.flags + "g");
          let prevMatchIndex = -1;
          for (;;) { // Search for all the matches.
            const match = r.exec(item.value);
            if (!match || match.index === prevMatchIndex) {
              break;
            }
            matches.push(match);
            prevMatchIndex = match.index;
          }
          return matches;
        },
      );
      const decorations = matches.map((match) => {
        const column = strlen(item.value.slice(0, match.index)) + 1;
        const length = strlen(match[0]);

        return { column, length };
      });

      yield {
        ...item,
        decorations: item.decorations
          ? [...item.decorations, ...decorations]
          : decorations,
      };
    }
  });
};
