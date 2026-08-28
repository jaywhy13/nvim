local model = require("user.meteorite.model")

local M = {}

local DEFAULT_CONTEXT_LINES = 3
local CONTEXT_STEP = 3
local MAX_CONTEXT_LINES = 200

---@class MeteoriteReviewState
---@field repository_root string
---@field stack MeteoriteStack
---@field files_by_pull_request table<integer, string[]>
---@field collapsed_pull_requests table<integer, boolean>
---@field collapsed_directories table<string, boolean>
---@field client table
---@field tabpage integer
---@field sidebar_window integer
---@field sidebar_buffer integer
---@field right_window integer
---@field tree_entries MeteoriteTreeEntry[]
---@field selected_pull_request MeteoritePullRequest|nil
---@field selected_path string|nil
---@field context_lines integer
---@field diff_buffer integer|nil
---@field selection_generation integer

---@type MeteoriteReviewState|nil
local state

---@param buffer integer
---@param lines string[]
local function replace_buffer_lines(buffer, lines)
	vim.bo[buffer].modifiable = true
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
	vim.bo[buffer].modifiable = false
end

---@param message string
local function show_right_message(message)
	if not state or not vim.api.nvim_win_is_valid(state.right_window) then
		return
	end

	local message_buffer = vim.api.nvim_create_buf(false, true)
	vim.bo[message_buffer].buftype = "nofile"
	vim.bo[message_buffer].bufhidden = "wipe"
	vim.bo[message_buffer].filetype = "meteorite"
	replace_buffer_lines(message_buffer, { "", "  " .. message })
	vim.api.nvim_win_set_buf(state.right_window, message_buffer)
end

local function focus_sidebar()
	if state and vim.api.nvim_win_is_valid(state.sidebar_window) then
		vim.api.nvim_set_current_win(state.sidebar_window)
	end
end

local function close_review()
	if not state then
		return
	end

	local review_tabpage = state.tabpage
	state = nil
	if vim.api.nvim_tabpage_is_valid(review_tabpage) then
		vim.api.nvim_set_current_tabpage(review_tabpage)
		vim.cmd("tabclose")
	end
end

local function render_sidebar()
	if not state or not vim.api.nvim_buf_is_valid(state.sidebar_buffer) then
		return
	end

	state.tree_entries = model.stack_tree(
		state.stack,
		state.files_by_pull_request,
		state.collapsed_pull_requests,
		state.collapsed_directories
	)
	local lines = vim.tbl_map(function(tree_entry)
		return tree_entry.line
	end, state.tree_entries)
	replace_buffer_lines(state.sidebar_buffer, lines)
end

local function diff_winbar()
	if not state or not state.selected_pull_request or not state.selected_path then
		return ""
	end

	return string.format(
		" #%d · %s · context %d · [/] hunks · +/- context · <C-h> files · q close ",
		state.selected_pull_request.number,
		state.selected_path,
		state.context_lines
	)
end

local function render_selected_file()
	if not state or not state.selected_pull_request or not state.selected_path then
		return
	end
	if not vim.api.nvim_win_is_valid(state.right_window) then
		return
	end

	local previous_diff_buffer = state.diff_buffer
	vim.api.nvim_set_current_win(state.right_window)
	local command =
		model.diff_command(state.repository_root, state.selected_pull_request, state.selected_path, state.context_lines)
	require("difft").diff({ cmd = command })

	state.diff_buffer = vim.api.nvim_get_current_buf()
	if previous_diff_buffer and vim.api.nvim_buf_is_valid(previous_diff_buffer) then
		vim.api.nvim_buf_delete(previous_diff_buffer, { force = true })
	end
	vim.wo[state.right_window].winbar = diff_winbar()

	vim.keymap.set("n", "+", function()
		M.adjust_context(CONTEXT_STEP)
	end, { buffer = state.diff_buffer, desc = "Show more diff context" })
	vim.keymap.set("n", "=", function()
		M.adjust_context(CONTEXT_STEP)
	end, { buffer = state.diff_buffer, desc = "Show more diff context" })
	vim.keymap.set("n", "-", function()
		M.adjust_context(-CONTEXT_STEP)
	end, { buffer = state.diff_buffer, desc = "Show less diff context" })
	vim.keymap.set("n", "0", function()
		M.reset_context()
	end, { buffer = state.diff_buffer, desc = "Reset diff context" })
	vim.keymap.set("n", "r", render_selected_file, { buffer = state.diff_buffer, desc = "Refresh pull request diff" })
	vim.keymap.set("n", "<C-h>", focus_sidebar, { buffer = state.diff_buffer, desc = "Focus changed files" })
	vim.keymap.set("n", "q", close_review, { buffer = state.diff_buffer, desc = "Close Meteorite review" })
end

---@param tree_entry MeteoriteTreeEntry
local function select_file(tree_entry)
	if not state or not tree_entry.path then
		return
	end

	state.selected_pull_request = tree_entry.pull_request
	state.selected_path = tree_entry.path
	state.selection_generation = state.selection_generation + 1
	local selection_generation = state.selection_generation
	show_right_message("Fetching pull request revisions…")

	state.client:ensure_revisions(state.repository_root, tree_entry.pull_request, function(error_message)
		if not state or selection_generation ~= state.selection_generation then
			return
		end
		if error_message then
			vim.notify(error_message, vim.log.levels.ERROR, { title = "Meteorite" })
			show_right_message("Could not load the selected diff")
			return
		end

		render_selected_file()
	end)
end

local function select_sidebar_entry()
	if not state then
		return
	end

	local line_number = vim.api.nvim_win_get_cursor(state.sidebar_window)[1]
	local tree_entry = state.tree_entries[line_number]
	if not tree_entry then
		return
	end

	if tree_entry.kind == "pull_request" then
		local pull_request_number = tree_entry.pull_request.number
		state.collapsed_pull_requests[pull_request_number] = not state.collapsed_pull_requests[pull_request_number]
		render_sidebar()
		return
	end
	if tree_entry.kind == "directory" and tree_entry.directory_key then
		local directory_key = tree_entry.directory_key
		state.collapsed_directories[directory_key] = not state.collapsed_directories[directory_key]
		render_sidebar()
		return
	end

	select_file(tree_entry)
end

local function configure_sidebar()
	if not state then
		return
	end

	local buffer = state.sidebar_buffer
	vim.bo[buffer].buftype = "nofile"
	vim.bo[buffer].bufhidden = "wipe"
	vim.bo[buffer].swapfile = false
	vim.bo[buffer].filetype = "meteorite"
	vim.wo[state.sidebar_window].number = false
	vim.wo[state.sidebar_window].relativenumber = false
	vim.wo[state.sidebar_window].cursorline = true
	vim.wo[state.sidebar_window].wrap = false
	vim.wo[state.sidebar_window].winfixwidth = true
	vim.wo[state.sidebar_window].winbar = " Pull requests and changed files · Enter select/toggle · q close "

	vim.keymap.set("n", "<CR>", select_sidebar_entry, { buffer = buffer, desc = "Select Meteorite entry" })
	vim.keymap.set("n", "l", select_sidebar_entry, { buffer = buffer, desc = "Select Meteorite entry" })
	vim.keymap.set("n", "q", close_review, { buffer = buffer, desc = "Close Meteorite review" })
end

---@param repository_root string
---@param stack MeteoriteStack
---@param files_by_pull_request table<integer, string[]>
---@param client table
function M.open(repository_root, stack, files_by_pull_request, client)
	if state and vim.api.nvim_tabpage_is_valid(state.tabpage) then
		close_review()
	end

	vim.cmd("tabnew")
	local review_tabpage = vim.api.nvim_get_current_tabpage()
	local right_window = vim.api.nvim_get_current_win()
	vim.bo[vim.api.nvim_get_current_buf()].bufhidden = "wipe"

	vim.cmd("topleft 48vnew")
	local sidebar_window = vim.api.nvim_get_current_win()
	local sidebar_buffer = vim.api.nvim_get_current_buf()

	state = {
		repository_root = repository_root,
		stack = stack,
		files_by_pull_request = files_by_pull_request,
		collapsed_pull_requests = {},
		collapsed_directories = {},
		client = client,
		tabpage = review_tabpage,
		sidebar_window = sidebar_window,
		sidebar_buffer = sidebar_buffer,
		right_window = right_window,
		tree_entries = {},
		context_lines = DEFAULT_CONTEXT_LINES,
		selection_generation = 0,
	}

	configure_sidebar()
	render_sidebar()
	show_right_message("Select a changed file to view its Difftastic diff")
	focus_sidebar()
end

---@param change integer
function M.adjust_context(change)
	if not state or not state.selected_path then
		return
	end

	state.context_lines = math.max(0, math.min(MAX_CONTEXT_LINES, state.context_lines + change))
	render_selected_file()
end

function M.reset_context()
	if not state or not state.selected_path then
		return
	end

	state.context_lines = DEFAULT_CONTEXT_LINES
	render_selected_file()
end

return M
