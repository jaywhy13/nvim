return {
  "ravitemer/mcphub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "BufRead",
  build = "npm install -g mcp-hub@latest",
  keys = {
    { "<Leader>aim", "<cmd>MCPHub<cr>", desc = "MCP Hub" },
  },
  config = function()
    require("mcphub").setup {
      config = vim.fn.expand "~/.config/nvim/mcpservers.json",
      log = {
        level = vim.log.levels.WARN,
        to_file = true,
      },
      on_ready = function()
        vim.notify("MCP Hub backend server is initialized and ready.", vim.log.levels.INFO)
      end,
    }
  end,
}
