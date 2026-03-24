return {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "BufRead",
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup {
        config = vim.fn.expand "~/.config/nvim/mcpservers.json",
        log = {
          level = vim.log.levels.WARN, -- Adjust verbosity (DEBUG, INFO, WARN, ERROR)
          to_file = true, -- Log to ~/.local/state/nvim/mcphub.log
        },
        on_ready = function()
          vim.notify("MCP Hub backend server is initialized and ready.", vim.log.levels.INFO)
        end,
      }
    end,
  }
