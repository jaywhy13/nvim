-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Lua
      null_ls.builtins.formatting.stylua,

      -- Python
      null_ls.builtins.formatting.isort,
      null_ls.builtins.formatting.black,

      -- JavaScript / TypeScript / JSON
      null_ls.builtins.formatting.prettierd,

      -- Terraform
      null_ls.builtins.formatting.terraform_fmt,
    })
  end,
}
