return {
	{
		"ahkohd/difft.nvim",
		dependencies = {
			"folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{
				"<Leader>gs",
				function()
					require("user.meteorite").open()
				end,
				desc = "Review Meteorite stacks",
			},
		},
		opts = {
			layout = nil,
			auto_jump = true,
			keymaps = {
				next = "]",
				prev = "[",
				first = "g[",
				last = "g]",
				refresh = "r",
			},
			jump = {
				enabled = false,
			},
			window = {
				number = false,
				relativenumber = false,
			},
		},
	},
}
