return {
  -- Git status signs in the gutter (AstroNvim default — extended here with mappings)
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<Leader>gdp", "<cmd>Gitsigns preview_hunk<cr>",        desc = "Preview hunk" },
      { "<Leader>gdi", "<cmd>Gitsigns preview_hunk_inline<cr>", desc = "Preview hunk inline" },
    },
  },

  -- Full-featured Git UI inside Neovim
  {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    keys = {
      { "<Leader>gg", function() require("neogit").open() end, desc = "Neogit" },
    },
    opts = {
      mappings = {
        finder = {
          ["<cr>"]           = "Select",
          ["<c-c>"]          = "Close",
          ["<esc>"]          = "Close",
          ["<c-j>"]          = "Next",
          ["<c-k>"]          = "Previous",
          ["<down>"]         = "Next",
          ["<up>"]           = "Previous",
          ["<tab>"]          = "InsertCompletion",
          ["<c-y>"]          = "CopySelection",
          ["<space>"]        = "MultiselectToggleNext",
          ["<s-space>"]      = "MultiselectTogglePrevious",
          ["<ScrollWheelDown>"]  = "ScrollWheelDown",
          ["<ScrollWheelUp>"]    = "ScrollWheelUp",
          ["<ScrollWheelLeft>"]  = "NOP",
          ["<ScrollWheelRight>"] = "NOP",
          ["<LeftMouse>"]    = "MouseClick",
          ["<2-LeftMouse>"]  = "NOP",
        },
      },
    },
    config = function(_, opts)
      require("neogit").setup(opts)

      -- Wrap git commit messages at 72 characters (conventional commit style)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gitcommit",
        group = vim.api.nvim_create_augroup("GitCommitSettings", { clear = true }),
        callback = function() vim.opt_local.textwidth = 72 end,
      })
    end,
  },

  -- diffview: side-by-side and unified diff views, used by Neogit
  {
    "sindrets/diffview.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  },

  -- GitHub PR and issue management inside Neovim
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Octo" },
    opts = {
      picker = "snacks",
    },
    keys = {
      { "<Leader>gpl", "<cmd>Octo pr list<cr>",     desc = "PR list" },
      { "<Leader>gpc", "<cmd>Octo pr create<cr>",   desc = "PR create" },
      { "<Leader>gpo", "<cmd>Octo pr checkout<cr>", desc = "PR checkout" },
      { "<Leader>gpf", "<cmd>Octo pr changes<cr>",  desc = "PR changed files" },
      { "<Leader>gpr", "<cmd>Octo pr ready<cr>",    desc = "PR mark ready" },
      { "<Leader>gpd", "<cmd>Octo pr draft<cr>",    desc = "PR mark draft" },
      { "<Leader>gpb", "<cmd>Octo pr browser<cr>",  desc = "PR open in browser" },
      { "<Leader>gpa", "<cmd>Octo comment add<cr>", desc = "PR add comment" },
    },
  },

  -- Copy a GitHub permalink for the current line / selection to the clipboard
  { "ruanyl/vim-gh-line", event = "BufEnter" },
}
