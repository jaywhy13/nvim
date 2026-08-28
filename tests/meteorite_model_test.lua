package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path

local model = require("user.meteorite.model")

local function assert_equal(actual, expected, message)
	if vim.deep_equal(actual, expected) then
		return
	end

	error(
		(message or "values differ") .. "\nexpected: " .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual)
	)
end

local function pull_request(number, title, updated_at)
	return {
		pullRequest = {
			number = number,
			title = title,
			updatedAt = updated_at,
			baseSha = "base" .. number,
			headSha = "head" .. number,
		},
	}
end

local shared_stack = {
	pull_request(10, "Foundation", "2026-08-27T10:00:00Z"),
	pull_request(11, "Feature", "2026-08-28T10:00:00Z"),
}

local older_stack = {
	pull_request(9, "Older", "2026-08-25T10:00:00Z"),
}

local stacks = model.deduplicate_stacks({ older_stack, shared_stack, shared_stack })

assert_equal(#stacks, 2, "the same server-projected stack is shown once")
assert_equal(stacks[1].key, "10:11", "stacks are ordered by their most recently updated pull request")
assert_equal(stacks[2].key, "9", "older stacks follow current stacks")

local tree_entries = model.stack_tree(stacks[1], {
	[10] = { "src/one.lua", "src/nested/two.lua", "root.lua" },
	[11] = { "three.lua" },
}, {
	[11] = true,
}, {})

local tree_lines = vim.tbl_map(function(entry)
	return entry.line
end, tree_entries)

assert_equal(tree_lines, {
	"▾ #10 Foundation",
	"    ▾ src/",
	"        ▾ nested/",
	"            two.lua",
	"        one.lua",
	"    root.lua",
	"▸ #11 Feature",
}, "the sidebar groups changed files into directories under expandable pull requests")
assert_equal(tree_entries[4].kind, "file", "file lines can be selected")
assert_equal(tree_entries[4].pull_request.number, 10, "a file keeps its pull request revision range")
assert_equal(tree_entries[4].path, "src/nested/two.lua", "nested file entries keep their repository path")

local diff_command = model.diff_command("/tmp/shop world", shared_stack[1].pullRequest, "path/with space.lua", 9)
assert_equal(
	diff_command,
	"DFT_CONTEXT=9 GIT_EXTERNAL_DIFF='difft --color=always --display side-by-side-show-both' git -C '/tmp/shop world' diff 'base10' 'head10' -- 'path/with space.lua'",
	"the diff command compares the exact pull request revisions and shell-escapes paths"
)

print("meteorite_model_test: ok")
