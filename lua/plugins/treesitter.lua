-- Customize Treesitter

---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	opts = function(_, opts)
		if opts.ensure_installed == "all" then
			return
		end

		opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, {
			"lua",
			"vim",
			"vimdoc",
			"html",
			"css",
			"bash",
			"python",
			"terraform",
			"markdown",
			"markdown_inline",
		})
	end,
}
