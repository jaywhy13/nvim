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
    { "<Leader>sT", function() Snacks.picker.grep({ hidden = true }) end,              desc = "Search hidden text (grep)" },
    {
      "<Leader>sc",
      function() Snacks.picker.grep({ search = "class ", live = true, exclude = { "*test*" } }) end,
      mode = { "n" },
      desc = "Class search (grep prefilled with 'class ', excludes *test*)",
    },
    {
      "<Leader>sc",
      function()
        -- Yank the visual selection into register "z" without clobbering the unnamed register.
        vim.cmd('noautocmd normal! "zy')
        local selection = vim.fn.getreg("z") or ""
        -- Collapse newlines so multi-line selections still produce a single grep query.
        selection = selection:gsub("[\r\n]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        Snacks.picker.grep({ search = "class " .. selection, live = true, exclude = { "*test*" } })
      end,
      mode = { "v" },
      desc = "Class search for visual selection (grep, excludes *test*)",
    },
    { "<Leader>sw", function() Snacks.picker.grep_word() end, mode = { "n" },         desc = "Search word under cursor" },
    { "<Leader>sw", function() Snacks.picker.grep_word() end, mode = { "v" },         desc = "Search visual selection" },

    -- buffers / jumplist / quickfix
    { "<Leader>sb", function() Snacks.picker.buffers() end,                           desc = "Find buffers" },
    { "<Leader>sj", function() Snacks.picker.jumps() end,                             desc = "Search jumplist" },
    { "<Leader>sq", function() Snacks.picker.qflist() end,                            desc = "Search quickfix list" },

    -- scratchpad / cmux tasks
    { "<Leader>tt", function() require("user.cmux_tasks").pick() end,                  desc = "Find scratchpad tasks" },
  },
}
