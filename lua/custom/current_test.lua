local function run_test_under_cursor()
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
      -- vim.api.nvim_echo({ { "current_filename: " .. vim.inspect(current_filename), "Normal" } }, false, {})
      vim.api.nvim_echo({ { "cwd: " .. vim.inspect(vim.loop.cwd()), "Normal" } }, false, {})

      local relative_filename = string.gsub(current_filename, vim.loop.cwd(), "")

      -- Remove the entitlements at the start
      relative_filename =
        string.gsub(relative_filename, "^/Users/jmwright/wave/src/embedded-payroll/embedded_payroll/", "")

      -- Construct the pytest command
      local pytest_command = "make test-unit -- " .. relative_filename .. "::" .. symbol_name .. " -v"
      local pytest_test_name_with_file = relative_filename .. "::" .. symbol_name

      -- Copy to clibboard
      vim.fn.setreg("+", pytest_test_name_with_file)

      -- Run command in terminal for NvChad
      -- require("nvchad.term").runner {
      --   pos = "sp",
      --   id = "pytest",
      --   cmd = pytest_command,
      --   size = 0.7,
      -- }
    end
  end)
end

vim.api.nvim_create_user_command("RunPytestTestUnderCursor", function()
  run_test_under_cursor()
end, { desc = "Run pytest test under cursor" })
