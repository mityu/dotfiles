local curmodule = ...
local function load_module(table, key)
  local module = require(curmodule .. "." .. key)
  table[key] = module
  return module
end

return setmetatable({}, {__index = load_module})
