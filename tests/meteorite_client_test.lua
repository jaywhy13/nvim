package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path

local Client = require("user.meteorite.client")

local function assert_equal(actual, expected, message)
	if vim.deep_equal(actual, expected) then
		return
	end

	error(
		(message or "values differ") .. "\nexpected: " .. vim.inspect(expected) .. "\nactual: " .. vim.inspect(actual)
	)
end

local FakeRunner = {}
FakeRunner.__index = FakeRunner

function FakeRunner.new(responses)
	return setmetatable({ responses = responses, calls = {} }, FakeRunner)
end

function FakeRunner:run(arguments, _, callback)
	local command = table.concat(arguments, " ")
	table.insert(self.calls, command)
	local configured_response = self.responses[command]
	assert(configured_response, "unexpected command: " .. command)
	local response = configured_response[1] and table.remove(configured_response, 1) or configured_response
	callback(response.error, response.output)
end

local pull_request_10 = {
	number = 10,
	title = "Foundation",
	updatedAt = "2026-08-27T10:00:00Z",
	baseRef = "main",
	headRef = "foundation",
	baseSha = "base10",
	headSha = "head10",
}
local pull_request_11 = {
	number = 11,
	title = "Feature",
	updatedAt = "2026-08-28T10:00:00Z",
	baseRef = "foundation",
	headRef = "feature",
	baseSha = "base11",
	headSha = "head11",
}
local stack_json = vim.json.encode({
	{ pullRequest = pull_request_10 },
	{ pullRequest = pull_request_11, parentPrNumber = 10 },
})

local runner = FakeRunner.new({
	["gs pr list --author @me --json --limit 100"] = { output = vim.json.encode({ pull_request_10 }) },
	["gs pr list --assignee @me --json --limit 100"] = { output = vim.json.encode({ pull_request_11 }) },
	["gs pr list --review-requested @me --json --limit 100"] = { output = vim.json.encode({ pull_request_10 }) },
	["gs pr stack 10 --json"] = { output = stack_json },
	["gs pr stack 11 --json"] = { output = stack_json },
	["gs pr diff 10 --name-only"] = { output = "one.lua\ntwo.lua\n" },
	["gs pr diff 11 --name-only"] = { output = "three.lua\n" },
	["git cat-file -e base10^{commit}"] = {
		{ error = "missing" },
		{ output = "" },
	},
	["git fetch --quiet origin main foundation"] = { output = "" },
	["git cat-file -e head10^{commit}"] = { output = "" },
})

local client = Client.new(runner)
local callback_result
client:find_relevant_stacks("/world", function(error_message, stacks)
	assert_equal(error_message, nil, "relevant stacks load without an error")
	callback_result = stacks
end)

assert_equal(#callback_result, 1, "pull requests from all relevant scopes are deduplicated into one stack")
assert_equal(callback_result[1].key, "10:11", "the client returns the server-projected stack")

local files_result
client:files_for_stack("/world", callback_result[1], function(error_message, files_by_pull_request)
	assert_equal(error_message, nil, "changed files load without an error")
	files_result = files_by_pull_request
end)

assert_equal(files_result[10], { "one.lua", "two.lua" }, "files stay attached to their pull request")
assert_equal(files_result[11], { "three.lua" }, "every pull request in the stack is loaded")

local revisions_error
client:ensure_revisions("/world", pull_request_10, function(error_message)
	revisions_error = error_message or false
end)

assert_equal(revisions_error, false, "missing revisions are fetched without changing branches")
for _, command in ipairs(runner.calls) do
	assert(not command:find("checkout", 1, true), "review setup must not check out a branch")
end

print("meteorite_client_test: ok")
