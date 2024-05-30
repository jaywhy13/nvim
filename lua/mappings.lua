require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")
map("i", "<C-l>", "<ESC>l")
map({ "i", "n" }, "<C-s>", ":w!<CR>", { desc = "Save" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>q", ":xa!<CR>") -- Close faster

-- Change tabs using <S-h> and <S-l>
map("n", "<S-h>", function()
  require("nvchad.tabufline").prev()
end, { desc = "go to previous tab" })

map("n", "<S-l>", function()
  require("nvchad.tabufline").next()
end, { desc = "go to next tab" })

-- Close buffer using <S-x>
map("n", "<S-x>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "buffer close" })

-- Telescope bindings
map("n", "<leader>sb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>ss", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map("n", "<leader>st", "<cmd>Telescope live_grep<cr>:", { desc = "telescope find in files" })
map("n", "<leader>sq", "<cmd>Telescope quickfix<cr>:", { desc = "telescope quickfix" })
--
-- LSP bindings
map("n", "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<cr>", { desc = "show hover information" })
map("n", "<leader>ll", function()
  local config = vim.lsp.diagnostics.float
  config.scope = "line"
  vim.diagnostic.open_float(0, config)
end, { desc = "show line diagnostics" })
map("n", "<leader>lgd", "<cmd>lua vim.lsp.buf.definition()<cr>", { desc = "goto definition" })
map("n", "<leader>lgD", "<cmd>lua vim.lsp.buf.declaration()<cr>", { desc = "goto declaration" })
map("n", "<leader>lgr", "<cmd>lua vim.lsp.buf.references()<cr>", { desc = "goto references" })
map("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "rename" })
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "format" })
map("i", "<C-space>", "<cmd>lua vim.lsp.buf.completion()<cr>", { desc = "autocomplete" })
map("n", "<leader>ldd", function()
  require("trouble").toggle "document_diagnostics"
end, { desc = "open document diagnostics" })
map("n", "<leader>ldk", function()
  vim.diagnostic.goto_next()
end, { desc = "next diagnostic" })
map("n", "<leader>ldj", function()
  vim.diagnostic.goto_prev()
end, { desc = "previous diagnostic" })
map("n", "<leader>ls", "<cmd>SymbolsOutline<CR>", { desc = "symbol outline" })

-- Nvim Tree bindings
map("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "toggle find file in tree" })

-- Nvim Ufo (Folds) bindings
-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "zO", require("ufo").openAllFolds)
vim.keymap.set("n", "zC", require("ufo").closeAllFolds)

-- ChatGPT bindings

map("n", "<leader>aic", "<cmd>ChatGPT<CR>", { desc = "ChatGPT" })
map("n", "<leader>aie", "<cmd>ChatGPTEditWithInstruction<CR>", { desc = "ChatGPT Edit with Instruction" })
map("n", "<leader>aig", "<cmd>ChatGPTRun grammar_correction<CR>", { desc = "ChatGPT Grammar Correction" })
map("n", "<leader>ait", "<cmd>ChatGPTRun translate<CR>", { desc = "ChatGPT Translate" })
map("n", "<leader>aik", "<cmd>ChatGPTRun keywords<CR>", { desc = "ChatGPT Keywords" })
map("n", "<leader>aid", "<cmd>ChatGPTRun docstring<CR>", { desc = "ChatGPT Docstring" })
map("n", "<leader>aia", "<cmd>ChatGPTRun add_tests<CR>", { desc = "ChatGPT Add Tests" })
map("n", "<leader>aio", "<cmd>ChatGPTRun optimize_code<CR>", { desc = "ChatGPT Optimize Code" })
map("n", "<leader>ais", "<cmd>ChatGPTRun summarize<CR>", { desc = "ChatGPT Summarize" })
map("n", "<leader>aif", "<cmd>ChatGPTRun fix_bugs<CR>", { desc = "ChatGPT Fix Bugs" })
map("n", "<leader>aix", "<cmd>ChatGPTRun explain_code<CR>", { desc = "ChatGPT Explain Code" })
map("n", "<leader>air", "<cmd>ChatGPTRun roxygen_edit<CR>", { desc = "ChatGPT Roxygen Edit" })
map("n", "<leader>ail", "<cmd>ChatGPTRun code_readability_analysis<CR>", { desc = "ChatGPT Code Readability Analysis" })

-- Other miscellaneous things
map("n", "<leader>h", "<cmd>noh<cr>", { desc = "clear highlights" })

-- Disable mappings
local nomap = vim.keymap.del

-- This mapping triggers an error during Save
-- because I have <leader>w mapped to save,
-- but Neovim still waits for another command
-- to see if I'm going to do <leader>wk.
-- Remove it so it's clear that nothing
-- comes after.
nomap("n", "<leader>wk")
