-- Lua language support.
--
-- lua_ls is started by AstroCommunity's Lua pack, outside AstroLSP's own server
-- setup path. AstroLSP only wraps `on_attach` for servers in its `servers` list
-- (see lua/plugins/astrolsp.lua), so its mappings were never installed in Lua
-- buffers: no <Leader>lh, no <Leader>lr, no `gd` while editing this config.
--
-- Adding lua_ls to the `servers` list does install the mappings, but AstroLSP
-- then also enables lua_ls itself, producing two lua_ls clients on one buffer.
--
-- Fix: register the AstroLSP `on_attach` on lua_ls's config without enabling the
-- server. Whoever starts lua_ls picks it up, and only one client attaches.
return {
	{
		"AstroNvim/astrolsp",
		optional = true,
		---@param opts AstroLSPOpts
		opts = function(_, opts)
			local existing_on_attach = (vim.lsp.config["lua_ls"] or {}).on_attach
			vim.lsp.config("lua_ls", {
				on_attach = function(client, bufnr)
					if type(existing_on_attach) == "function" then
						existing_on_attach(client, bufnr)
					end
					require("astrolsp").on_attach(client, bufnr)
				end,
			})
			return opts
		end,
	},
}
