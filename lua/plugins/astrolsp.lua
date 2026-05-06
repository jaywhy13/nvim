-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
      },
      timeout_ms = 1000,
    },
    servers = { "sorbet" },
    -- customize language server configuration options passed to `lspconfig`
    -- NOTE: Do NOT add rust_analyzer here. rustaceanvim (via astrocommunity.pack.rust)
    -- manages rust-analyzer directly and bypasses lspconfig entirely. Adding it here
    -- would cause two LSP clients to attach to Rust buffers simultaneously.
    ---@diagnostic disable: missing-fields
    config = {
      ts_ls = {
        initializationOptions = {
          hostInfo = "neovim",
          preferences = {
            disableSuggestions = true,
            quotePreference = "single",
          },
        },
      },
      sorbet = {
        cmd = { "bundle", "exec", "srb", "tc", "--lsp", "--disable-watchman" },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern("sorbet/config", "Gemfile", ".git")(fname)
        end,
      },
    },
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings set up on attaching of a language server
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },

        -- hover / info
        ["<Leader>lh"] = { function() vim.lsp.buf.hover() end, desc = "Hover documentation" },
        ["<Leader>ll"] = {
          function()
            vim.diagnostic.open_float(0, { scope = "line" })
          end,
          desc = "Show line diagnostics",
        },

        -- navigation
        ["<Leader>lgd"] = { function() vim.lsp.buf.definition() end, desc = "Go to definition" },
        ["<Leader>lgD"] = { function() vim.lsp.buf.declaration() end, desc = "Go to declaration" },
        ["<Leader>lgr"] = { function() vim.lsp.buf.references() end, desc = "Go to references" },

        -- actions
        ["<Leader>lr"] = { function() vim.lsp.buf.rename() end, desc = "Rename symbol" },
        ["<Leader>lf"] = { function() vim.lsp.buf.format { async = true } end, desc = "Format buffer" },
        ["<Leader>la"] = { function() vim.lsp.buf.code_action() end, desc = "Code actions" },

        -- diagnostics navigation
        ["<Leader>ldk"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" },
        ["<Leader>ldj"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" },
        ["<Leader>ldt"] = {
          function()
            if vim.diagnostic.is_enabled() then
              vim.diagnostic.enable(false)
            else
              vim.diagnostic.enable()
            end
          end,
          desc = "Toggle diagnostics",
        },
      },
    },
    on_attach = function(client, bufnr) end,
  },
}
