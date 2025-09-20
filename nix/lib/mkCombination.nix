# Make combinated list from given attribute set.
# Example:
# ```nix
# mkCombination { x = [ 1 2 3 ]; y = [ "aaa" "bbb" ]; }
# # => [
#   { x = 1; y = "aaa" }
#   { x = 1; y = "bbb" }
#   { x = 2; y = "aaa" }
#   { x = 2; y = "bbb" }
#   { x = 3; y = "aaa" }
#   { x = 3; y = "bbb" }
# ]
# ```
{ lib, ... }:
  attrset:
    let op = acc: { name, value }:
      let additions = map (v: { ${name} = v; }) value; in
      lib.concatMap (accElem: map (v: accElem // v) additions) acc;
    in
    builtins.foldl' op [ { } ] (lib.attrsToList attrset)
