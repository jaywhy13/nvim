local Client = require("user.meteorite.client")
local repository = require("user.meteorite.repository")
local review_view = require("user.meteorite.view")

local M = {}

local client = Client.new()

local function repository_root()
	local candidate_paths = {
		vim.api.nvim_buf_get_name(0),
		vim.fn.getcwd(),
	}
	for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
		table.insert(candidate_paths, vim.api.nvim_buf_get_name(buffer))
	end

	return repository.find(candidate_paths)
end

---@param stack MeteoriteStack
---@return string
local function stack_range(stack)
	local first_pull_request = stack.pull_requests[1]
	local last_pull_request = stack.pull_requests[#stack.pull_requests]
	if first_pull_request.number == last_pull_request.number then
		return "#" .. tostring(first_pull_request.number)
	end

	return string.format("#%d–#%d", first_pull_request.number, last_pull_request.number)
end

---@param stack MeteoriteStack
---@return string
local function stack_title(stack)
	local last_pull_request = stack.pull_requests[#stack.pull_requests]
	return string.format("%s · %d PRs · %s", stack_range(stack), #stack.pull_requests, last_pull_request.title)
end

---@param root string
---@param stack MeteoriteStack
local function open_stack(root, stack)
	vim.notify("Loading changed files…", vim.log.levels.INFO, { title = "Meteorite" })
	client:files_for_stack(root, stack, function(error_message, files_by_pull_request)
		if error_message then
			vim.notify(error_message, vim.log.levels.ERROR, { title = "Meteorite" })
			return
		end

		review_view.open(root, stack, files_by_pull_request, client)
	end)
end

---@param root string
---@param stacks MeteoriteStack[]
local function pick_stack(root, stacks)
	local Snacks = _G.Snacks or require("snacks")
	local picker_items = vim.tbl_map(function(stack)
		local titles = vim.tbl_map(function(pull_request)
			return pull_request.title
		end, stack.pull_requests)

		return {
			text = stack_range(stack) .. " " .. table.concat(titles, " "),
			title = stack_title(stack),
			stack = stack,
		}
	end, stacks)

	Snacks.picker.pick({
		source = "meteorite_stacks",
		title = "Meteorite stacks relevant to me",
		finder = function()
			return picker_items
		end,
		format = function(item)
			return {
				{ "  ", "Special" },
				{ item.title, "Title" },
			}
		end,
		layout = { preset = "telescope" },
		matcher = {
			fuzzy = true,
			sort_empty = false,
		},
		confirm = function(picker, item)
			picker:close()
			open_stack(root, item.stack)
		end,
	})
end

function M.open()
	if vim.fn.executable("gs") ~= 1 then
		vim.notify("The gs command is required for Meteorite reviews", vim.log.levels.ERROR, { title = "Meteorite" })
		return
	end
	if vim.fn.executable("difft") ~= 1 then
		vim.notify("Difftastic is required. Install it with: brew install difftastic", vim.log.levels.ERROR, {
			title = "Meteorite",
		})
		return
	end

	local root = repository_root()
	if not root then
		vim.notify("Open Neovim inside a shop/world checkout", vim.log.levels.ERROR, { title = "Meteorite" })
		return
	end

	vim.notify("Loading relevant Meteorite stacks…", vim.log.levels.INFO, { title = "Meteorite" })
	client:find_relevant_stacks(root, function(error_message, stacks)
		if error_message then
			vim.notify(error_message, vim.log.levels.ERROR, { title = "Meteorite" })
			return
		end
		if #stacks == 0 then
			vim.notify("No relevant open Meteorite stacks found", vim.log.levels.INFO, { title = "Meteorite" })
			return
		end

		pick_stack(root, stacks)
	end)
end

return M
