local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- Use a sub-list to run only the first available formatter
    javascript = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
  },
  format_on_save = {
    timeout_ms = 1200,
    lsp_fallback = true,
    stop_after_first = true,
  },
  notify_on_error = false,
}

require("conform").setup(options)
