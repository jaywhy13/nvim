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

-- Heap-allocation highlighting.
--
-- `after/queries/rust/highlights.scm` captures allocating expressions as
-- `@rust.alloc`. Treesitter resolves a capture name to the highlight group of
-- the same name, so that group has to exist or the capture does nothing.
--
-- Only `bg` is set. Attributes left unset fall through to the highlight
-- underneath, so a token keeps its usual foreground colour from the base Rust
-- queries and gains a background tint behind it.
--
-- The tint is the theme's warning colour mixed into the normal background
-- rather than the warning colour itself, which as a background would be far too
-- loud. `.clone()` appears constantly in real Rust, so the mark has to stay
-- quiet to remain useful. Raise ALLOC_TINT_STRENGTH for a stronger tint.
local ALLOC_TINT_STRENGTH = 0.18

---Split a 24-bit RGB integer into its three channels.
local function channels(rgb)
	return math.floor(rgb / 65536) % 256, math.floor(rgb / 256) % 256, rgb % 256
end

---Mix `top` over `base` at the given strength, returning a 24-bit RGB integer.
local function blend(top, base, strength)
	local top_r, top_g, top_b = channels(top)
	local base_r, base_g, base_b = channels(base)

	local function mix(a, b)
		return math.floor(a * strength + b * (1 - strength) + 0.5)
	end

	return mix(top_r, base_r) * 65536 + mix(top_g, base_g) * 256 + mix(top_b, base_b)
end

local function set_alloc_highlight()
	local warn = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })

	if warn.fg and normal.bg then
		vim.api.nvim_set_hl(0, "@rust.alloc", { bg = blend(warn.fg, normal.bg, ALLOC_TINT_STRENGTH) })
	else
		-- Either group can be missing before a colorscheme is applied. `Visual`
		-- carries a background in every theme, so it is a safe stand-in until the
		-- ColorScheme autocommand runs again.
		vim.api.nvim_set_hl(0, "@rust.alloc", { link = "Visual" })
	end
end

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
	{
		"AstroNvim/astrocore",
		opts = function(_, opts)
			-- Whichever runs first wins: if the colorscheme is already applied, the
			-- direct call reads the real `DiagnosticWarn` colour; if it is applied
			-- later, the autocommand re-reads it.
			set_alloc_highlight()

			opts.autocmds = opts.autocmds or {}
			opts.autocmds.rust_alloc_highlight = {
				{
					event = "ColorScheme",
					desc = "Restyle @rust.alloc after a colorscheme change",
					callback = set_alloc_highlight,
				},
			}

			return opts
		end,
	},
}
