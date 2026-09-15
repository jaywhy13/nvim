package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path

package.preload["nvim-web-devicons"] = function()
	return {
		get_icon = function()
			return "", "DevIconLua"
		end,
	}
end

local view = require("user.meteorite.view")
local pull_request = { number = 10, title = "Feature" }

local pull_request_line = view.decorated_tree_line({
	kind = "pull_request",
	line = "▾ #10 Feature",
	pull_request = pull_request,
})
assert(pull_request_line == "▾  #10 Feature", "pull requests should have a pull request icon")

local directory_line = view.decorated_tree_line({
	kind = "directory",
	line = "    ▾ source/",
	pull_request = pull_request,
	directory_key = "10:source",
})
assert(directory_line == "    ▾  source/", "expanded directories should have an open-folder icon")

local file_line, _, _, file_highlight = view.decorated_tree_line({
	kind = "file",
	line = "        example.lua",
	pull_request = pull_request,
	path = "source/example.lua",
})
assert(file_line == "           example.lua", "files should have their file-type icon")
assert(file_highlight == "DevIconLua", "file icons should keep their file-type colour")

print("meteorite_view_test: ok")
