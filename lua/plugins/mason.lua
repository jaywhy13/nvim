-- Customize Mason: ensure language servers/tools we rely on are installed.

---@type LazySpec
return {
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				-- Ruby: ruby-lsp powers go-to-definition, completion, hover, references
				-- in any Ruby project (Sorbet stays as the type-checker for Sorbet repos).
				"ruby-lsp",

				-- TypeScript: js-debug-adapter powers JavaScript debugging. vtsls is installed
				-- with pnpm because this machine blocks Mason's npm-based vtsls installer.
				"js-debug-adapter",

				-- Python: debugpy powers debugging, while black and isort power formatting.
				-- basedpyright is installed with uv because Mason briefly pointed at an unavailable version.
				"debugpy",
				"black",
				"isort",
			},
		},
	},
}
