-- Neovim 0.12 compatibility shim for nvim-treesitter's query predicates.
--
-- nvim-treesitter's master branch was archived in May 2025 and registers its
-- custom predicates and directives with `{ all = false }`. That option told
-- `iter_matches` to pass a single TSNode per capture. Neovim 0.12 removed it,
-- so handlers now receive a list of nodes (`TSNode[]`) instead.
--
-- The archived handlers still treat the value as one node, so they crash with
-- "attempt to call method 'range' (a nil value)" (or 'type', or 'parent').
-- Markdown shows this most often: a fenced code block with an info string, such
-- as ```shell, runs `set-lang-from-info-string!` to pick the injected language.
--
-- This module re-registers the affected handlers with `{ force = true }`,
-- unwrapping the list first. Behaviour is otherwise identical to the originals.
--
-- Remove this once nvim-treesitter's `main` branch is adopted, or once
-- AstroNvim ships a Neovim 0.12-compatible pin.

local query = require("vim.treesitter.query")

local M = {}

local html_script_type_languages = {
	["importmap"] = "json",
	["module"] = "javascript",
	["application/ecmascript"] = "javascript",
	["text/ecmascript"] = "javascript",
}

local non_filetype_match_injection_language_aliases = {
	ex = "elixir",
	pl = "perl",
	sh = "bash",
	uxn = "uxntal",
	ts = "typescript",
}

--- Read one node out of a capture.
--- Neovim 0.12 hands over a list of nodes. The old `all = false` behaviour used
--- the last captured node, so keep that.
---@param match table<string|integer, TSNode|TSNode[]|nil>
---@param id string|integer
---@return TSNode|nil
local function node_from_match(match, id)
	local value = match[id]
	if type(value) == "table" then
		return value[#value]
	end
	return value
end

local function warn(message)
	vim.notify(message, vim.log.levels.ERROR)
end

local function valid_args(name, pred, count, strict_count)
	local arg_count = #pred - 1

	if strict_count then
		if arg_count ~= count then
			warn(string.format("%s must have exactly %d arguments", name, count))
			return false
		end
	elseif arg_count < count then
		warn(string.format("%s must have at least %d arguments", name, count))
		return false
	end

	return true
end

local function get_parser_from_markdown_info_string(injection_alias)
	local match = vim.filetype.match({ filename = "a." .. injection_alias })
	return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
end

function M.setup()
	-- Load the upstream module first so its registrations happen before ours.
	pcall(require, "nvim-treesitter.query_predicates")

	local opts = { force = true }

	query.add_predicate("nth?", function(match, _pattern, _bufnr, pred)
		if not valid_args("nth?", pred, 2, true) then
			return
		end

		local node = node_from_match(match, pred[2])
		local n = tonumber(pred[3])
		if node and node:parent() and node:parent():named_child_count() > n then
			return node:parent():named_child(n) == node
		end

		return false
	end, opts)

	query.add_predicate("is?", function(match, _pattern, bufnr, pred)
		if not valid_args("is?", pred, 2) then
			return
		end

		-- Required lazily to avoid a circular dependency, same as upstream.
		local locals = require("nvim-treesitter.locals")
		local node = node_from_match(match, pred[2])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		local _, _, kind = locals.find_definition(node, bufnr)

		return vim.tbl_contains(types, kind)
	end, opts)

	query.add_predicate("kind-eq?", function(match, _pattern, _bufnr, pred)
		if not valid_args(pred[1], pred, 2) then
			return
		end

		local node = node_from_match(match, pred[2])
		local types = { unpack(pred, 3) }

		if not node then
			return true
		end

		return vim.tbl_contains(types, node:type())
	end, opts)

	query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
		local node = node_from_match(match, pred[2])
		if not node then
			return
		end

		local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
		local configured = html_script_type_languages[type_attr_value]
		if configured then
			metadata["injection.language"] = configured
		else
			local parts = vim.split(type_attr_value, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end, opts)

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local node = node_from_match(match, pred[2])
		if not node then
			return
		end

		local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
	end, opts)

	query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
		local id = pred[2]
		local node = node_from_match(match, id)
		if not node then
			return
		end

		local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
		if not metadata[id] then
			metadata[id] = {}
		end
		metadata[id].text = string.lower(text)
	end, opts)
end

return M
