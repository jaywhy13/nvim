-- Change the cursor line background color
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2d313b" }) -- Change to a lighter background
-- Change the Telescope selection so its easier to see
vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#2d313b" }) -- Change to a darker background

-- Make diffs easier to read
vim.api.nvim_set_hl(0, "NeogitDiffDelete", { fg = "#4b5466" })
vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { fg = "#4b5466" })
vim.api.nvim_set_hl(0, "NeogitDiffDeleteCursor", { fg = "#4b5466" })
