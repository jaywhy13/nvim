-- LSP-adjacent UI plugins. Both aerial and snacks are AstroNvim defaults;
-- this file extends their configuration without reinstalling them.
return {
  -- Symbol outline / code structure sidebar
  {
    "stevearc/aerial.nvim",
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
