-- Run with: nvim --headless -u init.lua -l tests/meteorite_keymap_test.lua
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")

local function git(...)
	local arguments = { "git", "-C", root }
	vim.list_extend(arguments, { ... })
	local result = vim.system(arguments, { text = true }):wait()
	assert(result.code == 0, result.stderr)
end

local success, failure = xpcall(function()
	git("init", "--quiet")
	vim.fn.writefile({ "original" }, root .. "/tracked.txt")
	git("add", "tracked.txt")
	git(
		"-c",
		"user.name=Test",
		"-c",
		"user.email=test@example.invalid",
		"-c",
		"commit.gpgsign=false",
		"commit",
		"--quiet",
		"-m",
		"fixture"
	)
	vim.cmd.edit(vim.fn.fnameescape(root .. "/tracked.txt"))
	require("lazy").load({ plugins = { "gitsigns.nvim" } })
	require("gitsigns").attach()
	assert(
		vim.wait(5000, function()
			return vim.b.gitsigns_status_dict ~= nil
		end, 20),
		"Gitsigns did not attach"
	)
	local mapping = vim.fn.maparg("<Leader>gs", "n", false, true)
	assert(mapping.desc == "Review Meteorite stacks", "Gitsigns replaced Meteorite: " .. vim.inspect(mapping))
	assert(vim.fn.maparg("<Leader>gS", "n", false, true).desc == "Stage Git buffer", "other Git mappings must remain")
	assert(vim.fn.maparg("<Leader>gs", "x", false, true).desc == "Stage Git hunk", "visual hunk staging must remain")
end, debug.traceback)
vim.fn.delete(root, "rf")
assert(success, failure)
print("meteorite_keymap_test: ok")
