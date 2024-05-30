local actions = require "telescope.actions"
-- NvChad configures Telescope as well, so I need
-- to merge their changes with mine.
-- Their changes are https://github.com/nvchad/nvchad/blob/v2.5/lua/nvchad/configs/telescope.lua
-- One caveat of this approach is that we're calling
-- setup for Telescope twice.
local nvchad_options = require "nvchad.configs.telescope"
local my_options = {
  defaults = {
    -- Ensure the following folders don't show up in Telescope
    file_ignore_patterns = { "node_modules", ".git/" },
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<C-n>"] = require("telescope.actions").cycle_history_next,
        ["<C-p>"] = require("telescope.actions").cycle_history_prev,
        -- Go back to normal mode
        -- This is done by simulating pressing Esc
        ["<C-l>"] = function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", true)
        end,
      },
      n = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
      },
    },
  },
}

local options = vim.tbl_deep_extend("force", nvchad_options, my_options)
require("telescope").setup(options)
