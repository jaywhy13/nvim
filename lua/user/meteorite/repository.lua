local M = {}

---@param repository_root string
---@return boolean
local function is_world_repository(repository_root)
	local command_result = vim.system({ "git", "remote", "get-url", "origin" }, {
		cwd = repository_root,
		text = true,
		timeout = 2000,
	}):wait()
	if command_result.code ~= 0 then
		return false
	end

	local remote_url = vim.trim(command_result.stdout or "")
	local host, path = remote_url:match("^https://([^/]+)/(.+)$")
	if not host then
		host, path = remote_url:match("^git@([^:]+):(.+)$")
	end
	if not host then
		host, path = remote_url:match("^ssh://git@([^/]+)/(.+)$")
	end
	if host ~= "gitstream.shopify.io" and host ~= "github.com" then
		return false
	end
	return path == "shop/world.git" or path == "shop/world"
end

---@param candidate_paths string[]
---@return string|nil
function M.find(candidate_paths)
	local checked_roots = {}

	for _, candidate_path in ipairs(candidate_paths) do
		if candidate_path ~= "" then
			local repository_root = vim.fs.root(candidate_path, ".git")
			if repository_root and not checked_roots[repository_root] then
				checked_roots[repository_root] = true
				if is_world_repository(repository_root) then
					return repository_root
				end
			end
		end
	end

	return nil
end

return M
