-- LSP-adjacent UI plugins. Both aerial and snacks are AstroNvim defaults;
-- this file extends their configuration without reinstalling them.
return {
  -- Symbol outline / code structure sidebar
  {
    "stevearc/aerial.nvim",
    -- AstroNvim v5 pins plugins to a tested set, which held aerial at v2.7.0.
    -- That release calls `iter_matches({ all = false })`, an option Neovim 0.12
    -- removed. iter_matches now always yields a list of nodes per capture, so
    -- aerial's treesitter backend crashed with "attempt to call method 'type'
    -- (a nil value)" whenever it built an outline. Markdown is where this shows
    -- up, because Markdown has no language server and therefore falls back to
    -- the treesitter backend. Upstream fixed it in f93dcee.
    --
    -- `version = false` opts this plugin out of the AstroNvim pin so it tracks
    -- master. Revert once the AstroNvim pin includes the fix.
    version = false,
    keys = {
      { "<Leader>ls", "<cmd>AerialToggle<cr>", desc = "Symbol outline" },
    },
    opts = {
      layout = {
        min_width = 40,
      },
      -- Jump between symbols in the outline with { and }
      on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Previous symbol" })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next symbol" })
      end,
    },
  },

  -- Diagnostics viewer — snacks.picker.diagnostics() replaces trouble.nvim
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<Leader>ldd",
        function() Snacks.picker.diagnostics() end,
        desc = "Browse diagnostics",
      },
    },
  },
}
