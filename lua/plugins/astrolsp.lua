-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
	"AstroNvim/astrolsp",
	---@type AstroLSPOpts
	opts = {
		features = {
			codelens = true,
			inlay_hints = false,
			semantic_tokens = true,
		},
		formatting = {
			format_on_save = {
				enabled = true,
			},
			timeout_ms = 1000,
		},
		-- Language servers:
		--   bashls   -> definitions / completion / hover / diagnostics for Bash scripts
		--   pyright  -> definitions / completion / hover / diagnostics for Python
		--   ruby_lsp -> definitions / references / completion / hover (works in any Ruby project)
		--   sorbet   -> type-checker diagnostics (only attaches when the repo has sorbet/config)
		-- TypeScript is enabled through the AstroCommunity TypeScript pack, which configures vtsls.
		-- vtsls is listed explicitly because this machine's Mason install path cannot use npm.
		-- Python is enabled through AstroCommunity Python subpacks, with pyright installed by pnpm.
		-- Keep ts_ls disabled to avoid two TypeScript clients attaching.
		-- NOTE: Do NOT add lua_ls here. AstroCommunity's Lua pack already starts it,
		-- and listing it makes AstroLSP start a second lua_ls client on the same
		-- buffer. lua/plugins/lua.lua attaches AstroLSP's mappings instead.
		servers = { "bashls", "pyright", "ruby_lsp", "sorbet", "vtsls" },
		-- Mason can auto-enable installed Ruby servers (solargraph/standardrb) and older
		-- TypeScript language server packages (ts_ls). Prefer ruby-lsp + sorbet for Ruby
		-- and vtsls from the AstroCommunity TypeScript pack for TypeScript.
		handlers = {
			solargraph = false,
			standardrb = false,
			ts_ls = false,
		},
		-- customize language server configuration options passed to `lspconfig`
		-- NOTE: Do NOT add rust_analyzer here. rustaceanvim (via astrocommunity.pack.rust)
		-- manages rust-analyzer directly and bypasses lspconfig entirely. Adding it here
		-- would cause two LSP clients to attach to Rust buffers simultaneously.
		---@diagnostic disable: missing-fields
		config = {
			bashls = {
				cmd = { "bash-language-server", "start" },
			},
			pyright = {
				cmd = { "pyright-langserver", "--stdio" },
				settings = {
					python = {
						analysis = {
							autoImportCompletions = true,
							typeCheckingMode = "basic",
						},
					},
				},
			},
			vtsls = {
				cmd = { "vtsls", "--stdio" },
				settings = {
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						inlayHints = {
							enumMemberValues = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							parameterNames = { enabled = "all" },
							parameterTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							variableTypes = { enabled = true },
						},
					},
					javascript = {
						updateImportsOnFileMove = { enabled = "always" },
						inlayHints = {
							enumMemberValues = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							variableTypes = { enabled = true },
						},
					},
					vtsls = {
						enableMoveToFileCodeAction = true,
					},
				},
			},
			ruby_lsp = {
				-- ruby-lsp itself manages its own custom Bundle, so call the binary directly
				-- (Mason installs it to ~/.local/share/nvim/mason/bin/ruby-lsp).
				-- Attach for any Ruby file, even outside a Gemfile project.
				root_markers = { "Gemfile", ".ruby-version", ".git" },
				single_file_support = true,
			},
			sorbet = {
				cmd = { "bundle", "exec", "srb", "tc", "--lsp", "--disable-watchman" },
				-- Only attach Sorbet when the repo actually has Sorbet configured.
				-- Otherwise `bundle exec srb` fails with "command not found: srb" and spams lsp.log.
				root_markers = { "sorbet/config" },
				root_dir = function(bufnr, on_dir)
					-- Walk up from the buffer looking for sorbet/config; if found, use the
					-- repo root (its parent's parent of sorbet/) so Sorbet's relative diagnostic
					-- paths resolve against the repo root, not the sorbet/ directory.
					local sorbet_config = vim.fs.find("sorbet/config", {
						upward = true,
						path = vim.api.nvim_buf_get_name(bufnr),
					})[1]
					if not sorbet_config then
						return
					end -- no Sorbet in this project, skip attach
					local repo_root = vim.fs.root(bufnr, { "Gemfile", ".git" })
					if repo_root then
						on_dir(repo_root)
					end
				end,
			},
		},
		autocmds = {
			lsp_codelens_refresh = {
				cond = "textDocument/codeLens",
				{
					event = { "InsertLeave", "BufEnter" },
					desc = "Refresh codelens (buffer)",
					callback = function(args)
						if require("astrolsp").config.features.codelens then
							vim.lsp.codelens.refresh({ bufnr = args.buf })
						end
					end,
				},
			},
		},
		-- mappings set up on attaching of a language server
		mappings = {
			n = {
				gD = {
					function()
						vim.lsp.buf.declaration()
					end,
					desc = "Declaration of current symbol",
					cond = "textDocument/declaration",
				},
				["<Leader>uY"] = {
					function()
						require("astrolsp.toggles").buffer_semantic_tokens()
					end,
					desc = "Toggle LSP semantic highlight (buffer)",
					cond = function(client, bufnr)
						return require("astrolsp.utils").supports_method(
							client,
							"textDocument/semanticTokens/full",
							bufnr
						) and vim.lsp.semantic_tokens ~= nil
					end,
				},

				-- hover / info
				-- NOTE: AstroNvim's default <Leader>lh is "Signature help", gated on
				-- textDocument/signatureHelp. Overrides are merged, not replaced, so the
				-- default `cond` is inherited unless it is set explicitly here. Without
				-- this line the mapping is dropped for servers without signature help.
				["<Leader>lh"] = {
					function()
						vim.lsp.buf.hover()
					end,
					desc = "Hover documentation",
					cond = "textDocument/hover",
				},
				["<Leader>ll"] = {
					function()
						vim.diagnostic.open_float(0, { scope = "line" })
					end,
					desc = "Show line diagnostics",
				},

				-- navigation
				["<Leader>lgd"] = {
					function()
						vim.lsp.buf.definition()
					end,
					desc = "Go to definition",
				},
				["<Leader>lgD"] = {
					function()
						vim.lsp.buf.declaration()
					end,
					desc = "Go to declaration",
				},
				["<Leader>lgr"] = {
					function()
						vim.lsp.buf.references()
					end,
					desc = "Go to references",
				},

				-- actions
				["<Leader>lr"] = {
					function()
						vim.lsp.buf.rename()
					end,
					desc = "Rename symbol",
				},
				["<Leader>lf"] = {
					function()
						vim.lsp.buf.format({ async = true })
					end,
					desc = "Format buffer",
				},
				["<Leader>la"] = {
					function()
						vim.lsp.buf.code_action()
					end,
					desc = "Code actions",
				},

				-- diagnostics navigation
				["<Leader>ldk"] = {
					function()
						vim.diagnostic.goto_next()
					end,
					desc = "Next diagnostic",
				},
				["<Leader>ldj"] = {
					function()
						vim.diagnostic.goto_prev()
					end,
					desc = "Previous diagnostic",
				},
				["<Leader>ldt"] = {
					function()
						if vim.diagnostic.is_enabled() then
							vim.diagnostic.enable(false)
						else
							vim.diagnostic.enable()
						end
					end,
					desc = "Toggle diagnostics",
				},
			},
		},
		on_attach = function(_client, _bufnr) end,
	},
}
