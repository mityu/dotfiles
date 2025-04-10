-- Internal awesome module to make a indicator panel with ease.
-- The appearance of the indicator panel of this module will be like this:
--
--   +------------------------------------------------------+
--   |                                                      |
--   |               +---------------------+                |
--   |               |                     |                |
--   |               |        icon         |                |
--   |               |                     |                |
--   |               +---------------------+                |
--   |                                                      |
--   |                        text                          |
--   |                                                      |
--   |            [=========indicator==========]            |
--   |                                                      |
--   +------------------------------------------------------+
--
-- Mainly for volume/brightness indicator.

local function new()
  local M = {
    _icon = nil,
    _bar = nil,
    _text = nil,
    _panel = nil,
  }

  M.set_icon = function(self, icon)
  end

  M.set_text = function(self, text)
  end

  M.set_bar_percent = function(self, percent)
  end

  M.set_visible = function(self, visible)
  end
end
