local function new()
  local M = { _locked = false }

  M.lock = function(self)
    self._locked = true
  end

  M.unlock = function(self)
    self._locked = false
  end

  M.run_if_free = function(self, fn)
    if not self._locked then
      self:lock()
      fn()
    end
  end

  return M
end

return {
  new = new,
}
