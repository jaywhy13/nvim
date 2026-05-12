-- Customize Mason: ensure language servers/tools we rely on are installed.

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- Ruby: ruby-lsp powers go-to-definition, completion, hover, references
        -- in any Ruby project (Sorbet stays as the type-checker for Sorbet repos).
        "ruby-lsp",
      },
    },
  },
}
