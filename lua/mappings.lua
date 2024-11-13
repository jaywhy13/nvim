require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<C-c>", "<ESC>", { desc = "Escape" })
-- map("i", "jk", "<ESC>")
map("n", "<C-s>", ":w!<CR>", { desc = "Save" })
map("i", "<C-s>", "<ESC>:w!<CR>", { desc = "Save" })

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
map("n", "<leader>sb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>ss", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>sf", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map("n", "<leader>st", "<cmd>Telescope live_grep<cr>", { desc = "telescope find in files" })
map("n", "<leader>sq", "<cmd>Telescope quickfix<cr>", { desc = "telescope quickfix" })
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
map("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "format" })
map("n", "<leader>la", "i<cmd>lua vim.lsp.buf.completion()<cr>", { desc = "autocomplete" })
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
map("n", "<leader>ldt", function()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end, { desc = "Toggle Diagnostics" })

-- Nvim Tree bindings
map("n", "<leader>e", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "toggle find file in tree" })

-- Nvim Ufo (Folds) bindings
-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "zO", require("ufo").openAllFolds)
vim.keymap.set("n", "zC", require("ufo").closeAllFolds)

-- AI bindings

map("n", "<leader>aig", "<cmd>ChatGPT<CR>", { desc = "ChatGPT" })
-- map("n", "<leader>aie", "<cmd>ChatGPTEditWithInstruction<CR>", { desc = "ChatGPT Edit with Instruction" })
-- map("n", "<leader>aig", "<cmd>ChatGPTRun grammar_correction<CR>", { desc = "ChatGPT Grammar Correction" })
-- map("n", "<leader>ait", "<cmd>ChatGPTRun translate<CR>", { desc = "ChatGPT Translate" })
-- map("n", "<leader>aik", "<cmd>ChatGPTRun keywords<CR>", { desc = "ChatGPT Keywords" })
-- map("n", "<leader>aid", "<cmd>ChatGPTRun docstring<CR>", { desc = "ChatGPT Docstring" })
-- map("n", "<leader>aia", "<cmd>ChatGPTRun add_tests<CR>", { desc = "ChatGPT Add Tests" })
-- map("n", "<leader>aio", "<cmd>ChatGPTRun optimize_code<CR>", { desc = "ChatGPT Optimize Code" })
-- map("n", "<leader>ais", "<cmd>ChatGPTRun summarize<CR>", { desc = "ChatGPT Summarize" })
-- map("n", "<leader>aif", "<cmd>ChatGPTRun fix_bugs<CR>", { desc = "ChatGPT Fix Bugs" })
-- map("n", "<leader>aix", "<cmd>ChatGPTRun explain_code<CR>", { desc = "ChatGPT Explain Code" })
-- map("n", "<leader>air", "<cmd>ChatGPTRun roxygen_edit<CR>", { desc = "ChatGPT Roxygen Edit" })
-- map("n", "<leader>ail", "<cmd>ChatGPTRun code_readability_analysis<CR>", { desc = "ChatGPT Code Readability Analysis" })

-- Copilot Chat bindings
map({ "n", "v" }, "<leader>aic", "<cmd>CopilotChatToggle<CR>", { desc = "Chat Copilot Toggle" })
map({ "n", "v" }, "<leader>aif", "<cmd>CopilotChatFix<CR>", { desc = "Copilot Fix" })
map({ "n", "v" }, "<leader>aio", "<cmd>CopilotChatOptimize<CR>", { desc = "Copilot Optimize" })
map({ "n", "v" }, "<leader>aid", "<cmd>CopilotChatDocs<CR>", { desc = "Copilot Add Docs" })
map({ "n", "v" }, "<leader>ait", "<cmd>CopilotChatTests<CR>", { desc = "Copilot Add Tests" })

map({ "n", "v" }, "<leader>aiq", function()
  local input = vim.fn.input "Quick Chat: "
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end, { desc = "Copilot Quickfix" })

-- terminal bindings
map({ "n", "t" }, "<A-h>", function()
  -- local num = vim.v.count
  local terminal_id = "htoggleTerm"
  require("nvchad.term").toggle { pos = "sp", id = terminal_id, size = 0.7 }
end, { desc = "terminal toggleable horizontal term" })

-- Other miscellaneous things
map("n", "<leader>h", "<cmd>noh<cr>", { desc = "clear highlights" })

map("n", "<leader>trc", function()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local current_pos = vim.api.nvim_win_get_cursor(0)
  -- We need to convert to 0-indexed based for the LSP server to understand
  local current_line = current_pos[1] - 1 -- convert to 0-indexed
  local current_col = current_pos[2]

  vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, result, ctx, config)
    if err then
      print("Error when finding symbols: " .. err)
    end

    -- vim.api.nvim_echo({ { "Result: " .. vim.inspect(result), "Normal" } }, false, {})

    local function symbol_contains_line(symbol, line_number)
      return symbol.range.start.line <= line_number and symbol.range["end"].line >= line_number
    end

    local function is_class_or_method_symbol(symbol)
      return symbol.kind == 5 or symbol.kind == 6
    end

    local function find_class_and_method_symbols(symbols)
      local desired_symbols = {}
      local current_symbols = symbols
      local index = 1

      while current_symbols ~= nil and index <= #current_symbols do
        local symbol = current_symbols[index]
        if symbol_contains_line(symbol, current_line) and is_class_or_method_symbol(symbol) then
          table.insert(desired_symbols, symbol)
          current_symbols = symbol.children
          index = 1
        else
          index = index + 1
        end
      end

      return desired_symbols
    end

    local class_and_method_symbols = find_class_and_method_symbols(result)
    if class_and_method_symbols then
      local symbol_names = {}
      for _, symbol in ipairs(class_and_method_symbols) do
        table.insert(symbol_names, symbol.name)
      end
      -- Construct a single symbol name for pytest
      local symbol_name = table.concat(symbol_names, "::")

      -- Get the current filename relative to project root
      local current_filename = vim.api.nvim_buf_get_name(0)

      local relative_filename = string.gsub(current_filename, vim.loop.cwd(), "")

      -- Remove the entitlements at the start
      relative_filename = string.gsub(relative_filename, "^/entitlements/", "")

      -- Construct the pytest command
      local pytest_command = "make test-unit -- " .. relative_filename .. "::" .. symbol_name .. " -v"

      -- Run command in terminal for NvChad
      require("nvchad.term").runner {
        pos = "sp",
        id = "pytest",
        cmd = pytest_command,
        size = 0.7,
      }
    end
  end)
end, { desc = "Run current test case" })
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

-- Disable mappings
local nomap = vim.keymap.del

-- This mapping triggers an error during Save
-- because I have <leader>w mapped to save,
-- but Neovim still waits for another command
-- to see if I'm going to do <leader>wk.
-- Remove it so it's clear that nothing
-- comes after.
nomap("n", "<leader>wk")
