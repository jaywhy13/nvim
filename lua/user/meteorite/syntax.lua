local M = {}
local installed = false

-- Difftastic emits unchanged keywords as bold-only ANSI spans. The pinned
-- difft.nvim parser discards styles without a foreground colour. Keep its
-- parser and renderer, adding only these missing spans from the original text.
function M.setup()
	if installed then
		return
	end
	local parser = require("difft").lib.parser
	local parse_ansi_line = parser.parse_ansi_line
	parser.parse_ansi_line = function(raw_line)
		local clean_line, highlights = parse_ansi_line(raw_line)
		local search_from = 1
		while true do
			local first, last, keyword = raw_line:find("\27%[1m([^\27]+)\27%[0m", search_from)
			if not first then
				break
			end
			local prefix = raw_line:sub(1, first - 1):gsub("\27%[[%d;]*m", "")
			local column = #prefix
			local already_highlighted = false
			for _, highlight in ipairs(highlights) do
				if highlight.col < column + #keyword and highlight.col + highlight.length > column then
					already_highlighted = true
					break
				end
			end
			if not already_highlighted then
				table.insert(highlights, { col = column, length = #keyword, hl_group = "Keyword" })
			end
			search_from = last + 1
		end
		return clean_line, highlights
	end
	installed = true
end

return M
