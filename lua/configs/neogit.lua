local neogit = require "neogit"

neogit.setup {
  mappings = {
    finder = {
      ["<cr>"] = "Select",
      ["<c-c>"] = "Close",
      ["<esc>"] = "Close",
      ["<c-j>"] = "Next",
      ["<c-k>"] = "Previous",
      ["<down>"] = "Next",
      ["<up>"] = "Previous",
      ["<tab>"] = "InsertCompletion",
      ["<c-y>"] = "CopySelection",
      ["<space>"] = "MultiselectToggleNext",
      ["<s-space>"] = "MultiselectTogglePrevious",
      -- ["<c-j>"] = "NOP",
      ["<ScrollWheelDown>"] = "ScrollWheelDown",
      ["<ScrollWheelUp>"] = "ScrollWheelUp",
      ["<ScrollWheelLeft>"] = "NOP",
      ["<ScrollWheelRight>"] = "NOP",
      ["<LeftMouse>"] = "MouseClick",
      ["<2-LeftMouse>"] = "NOP",
    },
  },
}

-- Set textwidth to 72 for gitcommit filetypes
vim.api.nvim_create_autocmd("FileType", {
  -- The patterns it should match (just 'gitcommit' in this case)
  pattern = "gitcommit",
  -- The command to execute when the event fires
  callback = function()
    -- Set the 'textwidth' option locally for the current buffer to 72
    vim.opt_local.textwidth = 72
  end,
  -- Set group for management (optional but good practice)
  group = vim.api.nvim_create_augroup("GitCommitSettings", { clear = true }),
})
