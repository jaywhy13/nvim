local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
-- Enable folding via nvim-ufo
-- See https://github.com/kevinhwang91/nvim-ufo?tab=readme-ov-file#minimal-configuration
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
local lspconfig = require "lspconfig"
-- Add language servers we want support for below
-- Note that tsserver uses the typescript-language-server (https://github.com/typescript-language-server/typescript-language-server)
-- which does formatting and has it's own configuration
local servers = { "html", "cssls", "pyright", "graphql", "terraformls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- tsserver custom setup
lspconfig.ts_ls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  initializationOptions = {
    hostInfo = "neovim",
    preferences = {
      disableSuggestions = true,
      quotePreference = "single",
    },
  },
}
