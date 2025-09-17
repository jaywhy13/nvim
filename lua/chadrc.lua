-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua
-- This file is for overriding the structure that NvChad has already provided

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "ayu_dark",

  -- hl_override = {
  -- 	Comment = { italic = true },
  -- 	["@comment"] = { italic = true },
  -- },
  --
  telescope = {
    style = "borderless",
  },
}

return M
