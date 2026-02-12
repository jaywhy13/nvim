require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<C-c>", "<ESC>", { desc = "Escape" })
map("i", "jk", "<ESC>")
map("n", "<C-s>", ":w!<CR>", { desc = "Save" })
map("i", "<C-s>", "<ESC>:w!<CR>", { desc = "Save" })

map("n", "<C-S-s>", "<cmd>noautocmd w<cr>", { desc = "save without triggering auto-commands" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>q", ":qa!<CR>") -- Close faster

-- window size
map("n", "<M-up>", "<C-w>+", { desc = "Increase window height" })
map("n", "<M-down>", "<C-w>-", { desc = "Decrease window height" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })
map("n", "<leader>wq", "<C-w>q", { desc = "Close window" })

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

-- Wrap words with brackets
map("v", "<leader>(", "<esc>bi(<esc>wwhi)<esc>", { desc = "wrap with brackets" })

-- Telescope bindings
map("n", "<leader>sb", function()
  require("search").open { tab_name = "Buffers" }
end, { desc = "telescope find buffers" })
map("n", "<leader>sf", function()
  require("search").open { tab_name = "Files" }
end, { desc = "search find files" })
map("n", "<leader>st", function()
  require("search").open { tab_name = "Text" }
end, { desc = "telescope find in files" })
map("n", "<leader>sw", function()
  require("telescope-live-grep-args.shortcuts").grep_word_under_cursor()
end, { desc = "search find word" })
map("v", "<leader>sw", function()
  require("telescope-live-grep-args.shortcuts").grep_visual_selection()
end, { desc = "search find word" })
-- This was buggy for search so I took it out
map("n", "<leader>sq", "<cmd>Telescope quickfix<CR>", { desc = "search quickfix" })
map("n", "<leader>sj", function()
  require("search").open { tab_name = "Jumplist" }
end, { desc = "search jumplist" })
-- Search for the word under the cursor. Copy the word to register z, then paste it in the prompt
map(
  "v",
  "<leader>st",
  '"zy:Telescope live_grep default_text=<C-r>z<cr>',
  { desc = "telescope find in files with visual selection" }
)
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
map("n", "<leader>lf", function()
  -- Our LSP servers don't do formatting. Conform is the one that does it.
  -- We've configured Conform in conform.lua to fallback to LSP formatting
  -- if it's available. However, Conform is the one that should be called
  -- to do the formatting.
  -- If we call lsp.buf.format() directly, then we're bypassing Conform,
  -- and if the LSP server doesn't support formatting (e.g. Pyright)
  -- then we get the error "no matching language servers"
  -- PS: We can always use :LspInfo to see what servers are attached to the buffer
  require("conform").format { async = true }
end, { desc = "format" })
map("n", "<leader>la", "i<cmd>lua vim.lsp.buf.completion()<cr>", { desc = "autocomplete" })
map("n", "<leader>ldd", "<cmd>Trouble diagnostics toggle focus=true<cr>", { desc = "open document diagnostics" })
-- map("n", "<leader>ldd", function()
--   require("trouble").toggle "document_diagnostics"
-- end, { desc = "open document diagnostics" })
map("n", "<leader>ldk", function()
  vim.diagnostic.goto_next()
end, { desc = "next diagnostic" })
map("n", "<leader>ldj", function()
  vim.diagnostic.goto_prev()
end, { desc = "previous diagnostic" })
map("n", "<leader>ls", "<cmd>AerialToggle<CR>", { desc = "symbol outline" })
map("n", "<leader>ldt", function()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end, { desc = "Toggle Diagnostics" })
map(
  "n",
  "<leader>lpp",
  "<cmd>PyrightSetPythonPath('/Users/jmwright/Library/Caches/pypoetry/virtualenvs/monitor-audit-kJQRyopa-py3.12')<CR>",
  { desc = "Set Python Path" }
)

-- Nvim Tree bindings
map("n", "<leader>tt", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Tree find file toggle" })

map("n", "<leader>tf", "<cmd>NvimTreeFindFile<cr>", { desc = "Tree find file" })

-- Nvim Ufo (Folds) bindings
-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "zO", require("ufo").openAllFolds)
vim.keymap.set("n", "zC", require("ufo").closeAllFolds)

-- AI bindings
-- CodeCompanion
map({ "n", "v" }, "<leader>aic", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Code Companion Chat Toggle" })
map({ "v" }, "<leader>aii", "<cmd>CodeCompanion<cr>", { desc = "Code Companion Inline" })
map({ "n", "v" }, "<leader>ain", "<cmd>CodeCompanionChat<cr>", { desc = "Code Companion Chat" })
map("n", "<leader>aia", "<cmd>CodeCompanionActions<cr>", { desc = "Code Companion Actions" })
map("n", "<leader>aim", "<cmd>MCPHub<cr>", { desc = "MCP Hub" })
map({ "n", "v" }, "<leader>aid", "<cmd>Copilot disable<cr>", { desc = "Copilot Disable" })

-- terminal bindings
map({ "n", "t" }, "<A-h>", function()
  local count = vim.v.count
  local terminal_id = "htoggleTerm" .. count
  local last_opened_terminal_id = vim.g.last_opened_terminal_id

  if not last_opened_terminal_id then
    -- No terminal is currently opened
    vim.g.last_opened_terminal_id = terminal_id
    require("nvchad.term").toggle { pos = "sp", id = terminal_id, size = 0.7 }
  else
    -- a terminal is open
    if terminal_id == last_opened_terminal_id then
      -- toggle the same terminal
      require("nvchad.term").toggle { pos = "sp", id = terminal_id, size = 0.7 }
      vim.g.last_opened_terminal_id = nil
    else
      -- close the last opened terminal
      require("nvchad.term").toggle { id = last_opened_terminal_id }
      -- open the new terminal
      vim.g.last_opened_terminal_id = terminal_id
      require("nvchad.term").toggle { pos = "sp", id = terminal_id, size = 0.7 }
    end
  end
end, { desc = "terminal toggleable horizontal term" })

-- Wave terminal bindings
map("n", "<leader>Wou", function()
  require("nvchad.term").runner {
    pos = "sp",
    id = "htoggleTerm",
    cmd = "okteto up",
    size = 0.7,
  }
end, { desc = "Okteto Up" })

map("n", "<leader>Wds", function()
  require("nvchad.term").runner {
    pos = "sp",
    id = "htoggleTerm",
    cmd = "source ~/aws/bin/activate && wave app:deploy scylla",
    size = 0.7,
  }
end, { desc = "wave:app deploy scylla" })

map("n", "<leader>Wdp", function()
  require("nvchad.term").runner {
    pos = "sp",
    id = "htoggleTerm",
    cmd = "source ~/aws/bin/activate && wave app:deploy proteus",
    size = 0.7,
  }
end, { desc = "wave:app deploy proteus" })

-- Other miscellaneous things
map("n", "<leader>h", "<cmd>noh<cr>", { desc = "clear highlights" })

map("n", "<leader>trc", "<cmd>RunPytestTestUnderCursor<cmd><CR>", { desc = "Run test under cursor" })

map({ "n" }, "<M-t>", function()
  require("nvchad.term").toggle {
    pos = "sp",
    id = "pytest",
    size = 0.7,
  }
end, { desc = "Toggle Test Terminal Window" })

map("n", "<leader>cf", function()
  local current_filename = vim.api.nvim_buf_get_name(0)
  local relative_filename = string.gsub(current_filename, vim.loop.cwd() .. "/", "")

  -- Copy to cliopboard
  vim.fn.setreg("+", relative_filename)
end, { desc = "Copy file path" })

-- Makefile bindings
map("n", "<leader>mr", "<cmd>MakeitOpen<CR>", { desc = "Run Makefile command" })
map("n", "<leader>mf", "<cmd>MakeitOpen<CR><cmd>normal! iformat<CR>", { desc = "Run Makefile format" })

-- Spectre bindings
map("n", "<leader>srt", "<cmd>lua require('spectre').toggle()<CR>", { desc = "Spectre Toggle" })
map("n", "<leader>srw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
  desc = "Search current word",
})
map("v", "<leader>srw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
  desc = "Search current word",
})

-- Neogit bindings
map("n", "<leader>gg", function()
  require("neogit").open()
end, { desc = "Neogit" })

-- Git signs bindings
map("n", "<leader>gdp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git Preview Hunk" })
map("n", "<leader>gdi", "<cmd>Gitsigns preview_hunk_inline<CR>", { desc = "Git Preview Hunk Inline" })
--
-- Octo bindings
map("n", "<leader>gpl", "<cmd>Octo pr list<CR>", { desc = "List" })
map("n", "<leader>gpc", "<cmd>Octo pr create<CR>", { desc = "Create" })
map("n", "<leader>gpo", "<cmd>Octo pr checkout<CR>", { desc = "Checkout" })
map("n", "<leader>gpf", "<cmd>Octo pr changes<CR>", { desc = "Changes (Files)" })
map("n", "<leader>gpr", "<cmd>Octo pr ready<CR>", { desc = "Ready" })
map("n", "<leader>gpd", "<cmd>Octo pr draft<CR>", { desc = "Draft" })
map("n", "<leader>gpb", "<cmd>Octo pr browser<CR>", { desc = "Browser" })
map("n", "<leader>gpa", "<cmd>Octo comment add<CR>", { desc = "Add Comment" })
-- Disable mappings
local nomap = vim.keymap.del

-- This mapping triggers an error during Save
-- because I have <leader>w mapped to save,
-- but Neovim still waits for another command
-- to see if I'm going to do <leader>wk.
-- Remove it so it's clear that nothing
-- comes after.
nomap("n", "<leader>wk")
-- nomap("n", "tab")
