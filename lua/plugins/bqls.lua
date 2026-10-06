---@type LazySpec
return {
	"kitagry/bqls.nvim",
	lazy = false,
	build = "./install.sh",
	dependencies = { "neovim/nvim-lspconfig" },
	opts = {
		project_ids = { "shopify-dw" },
	},
	config = function(_, opts)
		require("bqls").setup(opts)
		vim.lsp.config("bqls", {
			settings = {
				project_id = "shopify-dw",
				location = "US",
			},
		})
	end,
	keys = {
		{
			"<Leader>lq",
			function()
				require("bqls").sidebar.toggle()
			end,
			desc = "Browse BigQuery",
		},
	},
}
