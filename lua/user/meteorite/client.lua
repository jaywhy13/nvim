local model = require("user.meteorite.model")

local Client = {}
Client.__index = Client

local SystemRunner = {}
SystemRunner.__index = SystemRunner

---@param arguments string[]
---@param repository_root string
---@param callback fun(error_message: string|nil, output: string|nil)
function SystemRunner:run(arguments, repository_root, callback)
	vim.system(arguments, { cwd = repository_root, text = true }, function(command_result)
		vim.schedule(function()
			if command_result.code ~= 0 then
				local error_message = vim.trim(command_result.stderr or "")
				callback(error_message ~= "" and error_message or "Command failed", nil)
				return
			end

			callback(nil, command_result.stdout or "")
		end)
	end)
end

---@param runner table|nil
---@return table
function Client.new(runner)
	return setmetatable({
		runner = runner or setmetatable({}, SystemRunner),
		available_revision_ranges = {},
	}, Client)
end

---@param arguments string[]
---@param repository_root string
---@param callback fun(error_message: string|nil, decoded: any|nil)
function Client:run_json(arguments, repository_root, callback)
	self.runner:run(arguments, repository_root, function(error_message, output)
		if error_message then
			callback(error_message, nil)
			return
		end

		local decoded_successfully, decoded = pcall(vim.json.decode, output)
		if not decoded_successfully then
			callback("Gitstream returned invalid JSON", nil)
			return
		end

		callback(nil, decoded)
	end)
end

---@param commands string[][]
---@param repository_root string
---@param callback fun(error_message: string|nil, outputs: any[]|nil)
function Client:run_json_commands(commands, repository_root, callback)
	local remaining_commands = #commands
	local outputs = {}
	local finished = false

	for command_index, command in ipairs(commands) do
		self:run_json(command, repository_root, function(error_message, output)
			if finished then
				return
			end
			if error_message then
				finished = true
				callback(error_message, nil)
				return
			end

			outputs[command_index] = output
			remaining_commands = remaining_commands - 1
			if remaining_commands == 0 then
				finished = true
				callback(nil, outputs)
			end
		end)
	end
end

---@param repository_root string
---@param callback fun(error_message: string|nil, stacks: MeteoriteStack[]|nil)
function Client:find_relevant_stacks(repository_root, callback)
	local list_commands = {
		{ "gs", "pr", "list", "--author", "@me", "--json", "--limit", "100" },
		{ "gs", "pr", "list", "--assignee", "@me", "--json", "--limit", "100" },
		{ "gs", "pr", "list", "--review-requested", "@me", "--json", "--limit", "100" },
	}

	self:run_json_commands(list_commands, repository_root, function(list_error, pull_request_lists)
		if list_error then
			callback(list_error, nil)
			return
		end

		local pull_requests_by_number = {}
		for _, pull_request_list in ipairs(pull_request_lists) do
			for _, value in ipairs(pull_request_list) do
				local pull_request = value.pullRequest or value
				pull_requests_by_number[pull_request.number] = pull_request
			end
		end

		local stack_commands = {}
		for pull_request_number in pairs(pull_requests_by_number) do
			table.insert(stack_commands, { "gs", "pr", "stack", tostring(pull_request_number), "--json" })
		end

		if #stack_commands == 0 then
			callback(nil, {})
			return
		end

		self:run_json_commands(stack_commands, repository_root, function(stack_error, stack_responses)
			if stack_error then
				callback(stack_error, nil)
				return
			end

			callback(nil, model.deduplicate_stacks(stack_responses))
		end)
	end)
end

---@param repository_root string
---@param stack MeteoriteStack
---@param callback fun(error_message: string|nil, files_by_pull_request: table<integer, string[]>|nil)
function Client:files_for_stack(repository_root, stack, callback)
	local remaining_pull_requests = #stack.pull_requests
	local files_by_pull_request = {}
	local finished = false

	if remaining_pull_requests == 0 then
		callback(nil, files_by_pull_request)
		return
	end

	for _, pull_request in ipairs(stack.pull_requests) do
		local command = { "gs", "pr", "diff", tostring(pull_request.number), "--name-only" }
		self.runner:run(command, repository_root, function(error_message, output)
			if finished then
				return
			end
			if error_message then
				finished = true
				callback(error_message, nil)
				return
			end

			files_by_pull_request[pull_request.number] = vim.split(vim.trim(output or ""), "\n", { trimempty = true })
			remaining_pull_requests = remaining_pull_requests - 1
			if remaining_pull_requests == 0 then
				finished = true
				callback(nil, files_by_pull_request)
			end
		end)
	end
end

---@param repository_root string
---@param pull_request MeteoritePullRequest
---@param callback fun(revisions_exist: boolean)
function Client:revisions_exist(repository_root, pull_request, callback)
	local base_revision = pull_request.baseSha .. "^{commit}"
	self.runner:run({ "git", "cat-file", "-e", base_revision }, repository_root, function(base_error)
		if base_error then
			callback(false)
			return
		end

		local head_revision = pull_request.headSha .. "^{commit}"
		self.runner:run({ "git", "cat-file", "-e", head_revision }, repository_root, function(head_error)
			callback(head_error == nil)
		end)
	end)
end

---@param repository_root string
---@param pull_request MeteoritePullRequest
---@param callback fun(error_message: string|nil)
function Client:ensure_revisions(repository_root, pull_request, callback)
	local revision_range = pull_request.baseSha .. ":" .. pull_request.headSha
	if self.available_revision_ranges[revision_range] then
		callback(nil)
		return
	end

	self:revisions_exist(repository_root, pull_request, function(revisions_exist)
		if revisions_exist then
			self.available_revision_ranges[revision_range] = true
			callback(nil)
			return
		end

		if not pull_request.baseRef or not pull_request.headRef then
			callback("Gitstream did not provide the pull request branch references")
			return
		end

		local fetch_command = {
			"git",
			"fetch",
			"--quiet",
			"origin",
			pull_request.baseRef,
			pull_request.headRef,
		}
		self.runner:run(fetch_command, repository_root, function(fetch_error)
			if fetch_error then
				callback("Could not fetch the pull request revisions: " .. fetch_error)
				return
			end

			self:revisions_exist(repository_root, pull_request, function(fetched_revisions_exist)
				if not fetched_revisions_exist then
					callback("The pull request changed while its revisions were being fetched")
					return
				end

				self.available_revision_ranges[revision_range] = true
				callback(nil)
			end)
		end)
	end)
end

return Client
