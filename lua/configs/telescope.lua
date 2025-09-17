local actions = require "telescope.actions"
local lga_actions = require "telescope-live-grep-args.actions"
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
  extensions = {
    -- Configure search that lets me filter by file types and use other rg args
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- define mappings, e.g.
      mappings = { -- extend mappings
        i = {
          ["<C-i>"] = lga_actions.quote_prompt { postfix = " --iglob " },
          -- freeze the current list and start a fuzzy search in the frozen list
          ["<C-space>"] = lga_actions.to_fuzzy_refine,
        },
      },
      -- ... also accepts theme settings, for example:
      -- theme = "dropdown", -- use dropdown theme
      -- theme = { }, -- use own theme spec
      -- layout_config = { mirror=true }, -- mirror preview pane
    },
  },
}

local options = vim.tbl_deep_extend("force", nvchad_options, my_options)
require("telescope").setup(options)

-- Load extension
require("telescope").load_extension "live_grep_args"
