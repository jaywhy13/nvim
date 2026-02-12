local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- Use a sub-list to run only the first available formatter
    json = { "prettierd", "prettier" },
    javascript = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
    terraform = { "terraform_fmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = "fallback",
    stop_after_first = false,
  },
  notify_on_error = false,
}

require("conform").setup(options)
