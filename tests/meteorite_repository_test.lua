package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path

local repository = require("user.meteorite.repository")

local function run(arguments)
	local result = vim.system(arguments, { text = true }):wait()
	assert(result.code == 0, result.stderr)
end

local test_root = vim.fn.tempname()
local unrelated_repository = test_root .. "/workctl"
local world_repository = test_root .. "/world"
vim.fn.mkdir(unrelated_repository .. "/src", "p")
vim.fn.mkdir(world_repository .. "/areas/example", "p")

run({ "git", "-C", unrelated_repository, "init", "--quiet" })
run({ "git", "-C", unrelated_repository, "remote", "add", "origin", "git@github.com:example/workctl.git" })
run({ "git", "-C", world_repository, "init", "--quiet" })
run({ "git", "-C", world_repository, "remote", "add", "origin", "https://gitstream.shopify.io/shop/world.git" })

local selected_repository = repository.find({
	unrelated_repository .. "/src",
	world_repository .. "/areas/example",
})

assert(selected_repository == world_repository, "the active shop/world worktree must win over unrelated repositories")
assert(repository.find({ unrelated_repository }) == nil, "unrelated repositories must be rejected")
run({ "git", "-C", unrelated_repository, "remote", "set-url", "origin", "https://example.invalid/shop/world.git" })
assert(repository.find({ unrelated_repository }) == nil, "a matching path on a different host is not shop/world")
run({ "git", "-C", world_repository, "remote", "set-url", "origin", "git@github.com:shop/world.git" })
assert(repository.find({ world_repository }) == world_repository, "GitHub mirror checkouts remain supported")
vim.fn.delete(test_root, "rf")
print("meteorite_repository_test: ok")
