-- Extend snacks.nvim (AstroNvim default) with picker keybindings.
-- snacks.picker replaces Telescope + search.nvim from the NvChad config.
-- No new plugins are installed here.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      -- ignore common noise directories in all pickers
      ignored_patterns = { "node_modules", ".git/" },
    },
  },
  keys = {
    -- files
    { "<Leader>sf", function() Snacks.picker.files() end,                             desc = "Find files" },

    -- text / grep
    { "<Leader>st", function() Snacks.picker.grep() end,                              desc = "Search text (grep)" },
    { "<Leader>sw", function() Snacks.picker.grep_word() end, mode = { "n" },         desc = "Search word under cursor" },
    { "<Leader>sw", function() Snacks.picker.grep_word() end, mode = { "v" },         desc = "Search visual selection" },

    -- buffers / jumplist / quickfix
    { "<Leader>sb", function() Snacks.picker.buffers() end,                           desc = "Find buffers" },
    { "<Leader>sj", function() Snacks.picker.jumps() end,                             desc = "Search jumplist" },
    { "<Leader>sq", function() Snacks.picker.qflist() end,                            desc = "Search quickfix list" },
  },
}
