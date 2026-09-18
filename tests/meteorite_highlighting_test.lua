-- Run with: nvim --headless -u NONE -l tests/meteorite_highlighting_test.lua
package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/difft.nvim")
local difft = require("difft")
local specification = dofile("lua/plugins/meteorite.lua")[1]
local function configure()
	if specification.config then
		specification.config(nil, specification.opts)
	else
		difft.setup(specification.opts)
	end
end
configure()
configure()

local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
local success, failure = xpcall(function()
	for _, language in ipairs({
		{
			extension = "rs",
			keyword = "let",
			lines = { "fn greet() {", "    // hello", '    let text = "greeting";', "    let count = 1;", "}" },
		},
		{ extension = "lua", keyword = "local", lines = { "-- hello", 'local text = "greeting"', "local count = 1" } },
	}) do
		local before = root .. "/before." .. language.extension
		local after = root .. "/after." .. language.extension
		vim.fn.writefile(language.lines, before)
		local changed_lines = vim.tbl_map(function(line)
			return (line:gsub("count = 1", "count = 2"))
		end, language.lines)
		vim.fn.writefile(changed_lines, after)
		local output = vim.system(
			{ "difft", "--color=always", "--syntax-highlight", "on", "--width", "160", before, after },
			{ text = true }
		):wait()
		assert(output.code == 0, output.stderr)
		local buffer = vim.api.nvim_create_buf(false, true)
		local namespace = vim.api.nvim_create_namespace("highlighting_test")
		difft.lib.buffer.setup_from_ansi_lines(
			buffer,
			vim.split(output.stdout, "\n"),
			difft.get_config(),
			namespace,
			{ navigation = false }
		)
		local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
		local highlighted = {}
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buffer, namespace, 0, -1, { details = true })) do
			local details = mark[4]
			if details.hl_group then
				local text = lines[mark[2] + 1]:sub(mark[3] + 1, details.end_col)
				highlighted[details.hl_group] = (highlighted[details.hl_group] or "") .. text
			end
		end
		assert(
			(highlighted.Keyword or ""):find(language.keyword, 1, true),
			language.extension .. " keywords lost their styling"
		)
		assert(
			(highlighted.String or ""):find("greeting", 1, true),
			language.extension .. " strings should use the theme's String colour"
		)
		assert(
			(highlighted.Comment_italic or ""):find("hello", 1, true),
			language.extension .. " comments should use the theme's Comment colour"
		)
		assert(
			highlighted.DifftAnsiAdd_bold and highlighted.DifftAnsiDelete_bold,
			"changed tokens must retain diff colours"
		)
		vim.api.nvim_buf_delete(buffer, { force = true })
	end
end, debug.traceback)
vim.fn.delete(root, "rf")
assert(success, failure)
print("meteorite_highlighting_test: ok")
