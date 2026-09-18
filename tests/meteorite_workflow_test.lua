-- Run with: nvim --headless -u NONE -l tests/meteorite_workflow_test.lua
package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path
vim.o.columns = 180
vim.o.lines = 50
for _, plugin in ipairs({ "difft.nvim", "nvim-web-devicons" }) do
	vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/" .. plugin)
end
local specification = dofile("lua/plugins/meteorite.lua")[1]
specification.config(nil, specification.opts)
local repository = require("user.meteorite.repository")
local Client = require("user.meteorite.client")
local view = require("user.meteorite.view")

local test_root = vim.fn.tempname()
local world = test_root .. "/world"
local unrelated = test_root .. "/other"
vim.fn.mkdir(world .. "/source", "p")
vim.fn.mkdir(unrelated, "p")

local function git(root, ...)
	local arguments = { "git", "-C", root }
	vim.list_extend(arguments, { ... })
	local result = vim.system(arguments, { text = true }):wait()
	assert(result.code == 0, result.stderr)
	return vim.trim(result.stdout)
end

local function press(key)
	local mapping = vim.fn.maparg(key, "n", false, true)
	assert(type(mapping.callback) == "function", "missing key: " .. key)
	mapping.callback()
end

local original_tab = vim.api.nvim_get_current_tabpage()
local success, failure = xpcall(function()
	git(world, "init", "--quiet")
	git(world, "remote", "add", "origin", "https://gitstream.shopify.io/shop/world.git")
	git(unrelated, "init", "--quiet")
	git(unrelated, "remote", "add", "origin", "https://github.com/example/other.git")
	local source = {}
	for index = 1, 45 do
		source[index] = "local value_" .. index .. " = " .. index
	end
	vim.fn.writefile(source, world .. "/source/example.lua")
	vim.fn.writefile({ 'fn main() { println!("before"); }' }, world .. "/source/example.rs")
	git(world, "add", ".")
	git(
		world,
		"-c",
		"user.name=Test",
		"-c",
		"user.email=test@example.invalid",
		"-c",
		"commit.gpgsign=false",
		"commit",
		"--quiet",
		"-m",
		"before"
	)
	local base = git(world, "rev-parse", "HEAD")
	source[2] = 'local value_2 = "changed_first"'
	source[40] = 'local value_40 = "changed_last"'
	vim.fn.writefile(source, world .. "/source/example.lua")
	vim.fn.writefile({ 'fn main() { println!("after"); }' }, world .. "/source/example.rs")
	git(world, "add", ".")
	git(
		world,
		"-c",
		"user.name=Test",
		"-c",
		"user.email=test@example.invalid",
		"-c",
		"commit.gpgsign=false",
		"commit",
		"--quiet",
		"-m",
		"after"
	)
	local head = git(world, "rev-parse", "HEAD")
	local branch = git(world, "branch", "--show-current")
	vim.fn.writefile({ "keep these local edits" }, world .. "/source/example.rs")
	local status = git(world, "status", "--porcelain")

	vim.fn.writefile({ "Unrelated project notes" }, unrelated .. "/notes.txt")
	vim.cmd.edit(vim.fn.fnameescape(unrelated .. "/notes.txt"))
	local root = repository.find({ unrelated, world .. "/source" })
	assert(root == world, "revision loading must use shop/world, not the unrelated repository")
	local pull_request = { number = 10, title = "Fixture", baseSha = base, headSha = head }
	view.open(root, { key = "10", pull_requests = { pull_request } }, {
		[10] = { "source/example.lua", "source/example.rs" },
	}, Client.new())
	local sidebar = vim.api.nvim_get_current_win()
	local sidebar_buffer = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(sidebar_buffer, 0, -1, false)
	assert(lines[1]:find("", 1, true), "pull request icon missing")
	local lua_icon = require("nvim-web-devicons").get_icon("example.lua", nil, { default = true })
	local rust_icon = require("nvim-web-devicons").get_icon("example.rs", nil, { default = true })
	assert(lines[3]:find(lua_icon, 1, true) and lines[4]:find(rust_icon, 1, true), "file-type icons missing")
	assert(lua_icon ~= rust_icon, "fixture must exercise distinct file types")
	local namespace = vim.api.nvim_get_namespaces().meteorite_sidebar
	assert(#vim.api.nvim_buf_get_extmarks(sidebar_buffer, namespace, 0, -1, {}) >= 4, "sidebar highlights missing")

	vim.api.nvim_win_set_cursor(sidebar, { 2, 0 })
	press("<CR>")
	assert(vim.api.nvim_buf_line_count(sidebar_buffer) == 2, "folder should collapse")
	press("f")
	vim.api.nvim_win_set_cursor(sidebar, { 2, 0 })
	press("f")
	assert(
		vim.api.nvim_buf_line_count(sidebar_buffer) == 4,
		"returning to the tree must reveal a previously folded file"
	)
	assert(vim.api.nvim_win_get_cursor(sidebar)[1] == 3, "tree toggle must reveal the focused file")
	press("f")
	local flat_lines = vim.api.nvim_buf_get_lines(sidebar_buffer, 0, -1, false)
	assert(#flat_lines == 3, "flat view must omit directory rows")
	assert(flat_lines[2]:find("source/example.lua", 1, true), "flat view must show full paths")
	assert(flat_lines[2]:find(lua_icon, 1, true), "flat view must retain file-type icons")
	assert(vim.api.nvim_win_get_cursor(sidebar)[1] == 2, "toggle must retain the file under the cursor")
	press("<CR>")
	local function rendered()
		return vim.bo.filetype == "difft"
			and table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):find("changed_last", 1, true) ~= nil
	end
	assert(
		vim.wait(5000, rendered, 20),
		"selected file did not render its committed Difftastic content: "
			.. vim.inspect(vim.api.nvim_buf_get_lines(0, 0, -1, false))
	)
	local diff_buffer = vim.api.nvim_get_current_buf()
	press("f")
	assert(vim.api.nvim_get_current_buf() == diff_buffer, "changing the file list must not replace the diff")
	assert(vim.api.nvim_buf_line_count(sidebar_buffer) == 4, "toggle from diff must restore the tree")
	assert(vim.api.nvim_win_get_cursor(sidebar)[1] == 3, "tree toggle must keep the selected file")
	local first_hunk = vim.api.nvim_win_get_cursor(0)[1]
	press("]")
	assert(vim.api.nvim_win_get_cursor(0)[1] > first_hunk, "next hunk must move forward")
	press("[")
	assert(vim.api.nvim_win_get_cursor(0)[1] == first_hunk, "previous hunk must return")
	local original_line_count = vim.api.nvim_buf_line_count(0)
	press("+")
	assert(vim.wait(5000, rendered, 20), "context redraw did not finish")
	assert(vim.api.nvim_buf_line_count(0) > original_line_count, "more context must reveal actual source lines")
	press("q")
	assert(vim.api.nvim_get_current_tabpage() == original_tab, "closing review must restore the original tab")
	assert(
		git(world, "rev-parse", "HEAD") == head and git(world, "branch", "--show-current") == branch,
		"review changed checkout"
	)
	assert(git(world, "status", "--porcelain") == status, "review changed local edits")
end, debug.traceback)
vim.fn.delete(test_root, "rf")
assert(success, failure)
print("meteorite_workflow_test: ok")
