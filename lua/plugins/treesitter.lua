-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "html",
      "css",
      "python",
      "typescript",
      "terraform",
      "markdown",
      "markdown_inline",
    },
  },
}
