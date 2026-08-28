local M = {}

---@class MeteoritePullRequest
---@field number integer
---@field title string
---@field updatedAt string
---@field baseSha string
---@field headSha string
---@field baseRef string|nil
---@field headRef string|nil

---@class MeteoriteStackEntry
---@field pullRequest MeteoritePullRequest
---@field parentPrNumber integer|nil

---@class MeteoriteStack
---@field key string
---@field pull_requests MeteoritePullRequest[]
---@field updated_at string

---@class MeteoriteTreeEntry
---@field kind "pull_request"|"directory"|"file"
---@field line string
---@field pull_request MeteoritePullRequest
---@field path string|nil
---@field directory_key string|nil

---@param stack_responses MeteoriteStackEntry[][]
---@return MeteoriteStack[]
function M.deduplicate_stacks(stack_responses)
	local stacks_by_key = {}

	for _, stack_response in ipairs(stack_responses) do
		local pull_requests = {}
		local numbers = {}
		local updated_at = ""

		for _, stack_entry in ipairs(stack_response) do
			local pull_request = stack_entry.pullRequest
			table.insert(pull_requests, pull_request)
			table.insert(numbers, tostring(pull_request.number))
			if pull_request.updatedAt and pull_request.updatedAt > updated_at then
				updated_at = pull_request.updatedAt
			end
		end

		local key = table.concat(numbers, ":")
		if key ~= "" then
			stacks_by_key[key] = {
				key = key,
				pull_requests = pull_requests,
				updated_at = updated_at,
			}
		end
	end

	local stacks = {}
	for _, stack in pairs(stacks_by_key) do
		table.insert(stacks, stack)
	end

	table.sort(stacks, function(left, right)
		if left.updated_at == right.updated_at then
			return left.key < right.key
		end
		return left.updated_at > right.updated_at
	end)

	return stacks
end

---@param paths string[]
---@return table
local function build_file_tree(paths)
	local root = { directories = {}, files = {} }

	for _, path in ipairs(paths) do
		local path_parts = vim.split(path, "/", { plain = true })
		local file_name = table.remove(path_parts)
		local directory = root
		local directory_path = ""

		for _, directory_name in ipairs(path_parts) do
			directory_path = directory_path == "" and directory_name or directory_path .. "/" .. directory_name
			directory.directories[directory_name] = directory.directories[directory_name]
				or {
					name = directory_name,
					path = directory_path,
					directories = {},
					files = {},
				}
			directory = directory.directories[directory_name]
		end

		table.insert(directory.files, { name = file_name, path = path })
	end

	return root
end

---@param tree_entries MeteoriteTreeEntry[]
---@param directory table
---@param pull_request MeteoritePullRequest
---@param indent string
---@param collapsed_directories table<string, boolean>
local function append_file_tree_entries(tree_entries, directory, pull_request, indent, collapsed_directories)
	local directory_names = vim.tbl_keys(directory.directories)
	table.sort(directory_names)

	for _, directory_name in ipairs(directory_names) do
		local child_directory = directory.directories[directory_name]
		local directory_key = tostring(pull_request.number) .. ":" .. child_directory.path
		local is_collapsed = collapsed_directories[directory_key] == true
		table.insert(tree_entries, {
			kind = "directory",
			line = string.format("%s%s %s/", indent, is_collapsed and "▸" or "▾", directory_name),
			pull_request = pull_request,
			directory_key = directory_key,
		})

		if not is_collapsed then
			append_file_tree_entries(
				tree_entries,
				child_directory,
				pull_request,
				indent .. "    ",
				collapsed_directories
			)
		end
	end

	table.sort(directory.files, function(left, right)
		return left.name < right.name
	end)
	for _, file in ipairs(directory.files) do
		table.insert(tree_entries, {
			kind = "file",
			line = indent .. file.name,
			pull_request = pull_request,
			path = file.path,
		})
	end
end

---@param stack MeteoriteStack
---@param files_by_pull_request table<integer, string[]>
---@param collapsed_pull_requests table<integer, boolean>
---@param collapsed_directories table<string, boolean>|nil
---@return MeteoriteTreeEntry[]
function M.stack_tree(stack, files_by_pull_request, collapsed_pull_requests, collapsed_directories)
	local tree_entries = {}
	collapsed_directories = collapsed_directories or {}

	for _, pull_request in ipairs(stack.pull_requests) do
		local is_collapsed = collapsed_pull_requests[pull_request.number] == true
		table.insert(tree_entries, {
			kind = "pull_request",
			line = string.format("%s #%d %s", is_collapsed and "▸" or "▾", pull_request.number, pull_request.title),
			pull_request = pull_request,
		})

		if not is_collapsed then
			local file_tree = build_file_tree(files_by_pull_request[pull_request.number] or {})
			append_file_tree_entries(tree_entries, file_tree, pull_request, "    ", collapsed_directories)
		end
	end

	return tree_entries
end

---@param repository_root string
---@param pull_request MeteoritePullRequest
---@param path string
---@param context_lines integer
---@return string
function M.diff_command(repository_root, pull_request, path, context_lines)
	local external_diff = "difft --color=always --display side-by-side-show-both"
	local arguments = {
		"DFT_CONTEXT=" .. tostring(context_lines),
		"GIT_EXTERNAL_DIFF=" .. vim.fn.shellescape(external_diff),
		"git",
		"-C",
		vim.fn.shellescape(repository_root),
		"diff",
		vim.fn.shellescape(pull_request.baseSha),
		vim.fn.shellescape(pull_request.headSha),
		"--",
		vim.fn.shellescape(path),
	}

	return table.concat(arguments, " ")
end

return M
