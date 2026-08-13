-- Customize Treesitter

---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	opts = function(_, opts)
		-- nvim-treesitter's master branch is archived and its query predicates are
		-- incompatible with Neovim 0.12. Re-register the affected ones.
		require("user.ts_predicate_compat").setup()

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
