-- Rust language support.
--
-- rustaceanvim (from astrocommunity.pack.rust) starts and owns rust-analyzer
-- directly. It deliberately bypasses lspconfig, which is why rust_analyzer must
-- NOT be added to the `servers` list in lua/plugins/astrolsp.lua: that would
-- attach a second Rust client to the same buffer.
--
-- The side effect of bypassing lspconfig is that AstroLSP's `on_attach` never
-- runs for Rust buffers, so none of the AstroLSP mappings are installed. That
-- means no <Leader>l mappings at all in Rust files (no hover, no go-to
-- definition, no rename, no code action, no `gd`).
--
-- Fix: call AstroLSP's `on_attach` from rustaceanvim's own server `on_attach`.
-- This installs the mappings without starting another language client.
return {
	{
		"mrcjkb/rustaceanvim",
		optional = true,
		opts = function(_, opts)
			opts.server = opts.server or {}
			local existing_on_attach = opts.server.on_attach
			opts.server.on_attach = function(client, bufnr)
				if existing_on_attach then
					existing_on_attach(client, bufnr)
				end
				require("astrolsp").on_attach(client, bufnr)
			end
			return opts
		end,
	},
}
