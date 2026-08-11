# AGENTS.md

## Purpose

This repository is a personal Neovim configuration built on AstroNvim v5. AstroNvim is the editor framework that provides the default Neovim setup; this repository layers personal plugins, keymaps, language tooling, and editor behavior on top of it.

Treat this as a user-owned configuration repository. Before changing anything, run `git status --short` and preserve existing local edits.

## Startup flow

- `init.lua` bootstraps Lazy.nvim, the plugin manager, then loads `lua/lazy_setup.lua` and `lua/polish.lua`.
- `lua/lazy_setup.lua` loads AstroNvim, imports community packs, and imports every plugin specification under `lua/plugins/`.
- `lua/community.lua` imports AstroCommunity language packs. AstroCommunity is the shared collection of AstroNvim plugin bundles; this repository currently imports Lua, Rust, Ruby, and TypeScript packs.
- `lua/polish.lua` is for final custom Lua that does not fit elsewhere, but it is currently disabled by an early return guard.

Avoid editing `init.lua` unless the bootstrap process itself needs to change.

## Where to change things

- Change plugins in `lua/plugins/*.lua`. Each file returns a Lazy.nvim plugin specification.
- Change AstroCommunity pack imports in `lua/community.lua`.
- Change core editor options, diagnostics defaults, autocommands, and general keymaps in `lua/plugins/astrocore.lua`.
- Change language server behavior in `lua/plugins/astrolsp.lua`.
- Change automatically installed Mason tools in `lua/plugins/mason.lua`. Mason is the tool installer that downloads language servers, formatters, debuggers, and related command-line tools for Neovim.
- Change formatter sources in `lua/plugins/none-ls.lua`. none-ls exposes external formatters and linters through Neovim's language server interface.
- Change Treesitter parsers in `lua/plugins/treesitter.lua`. Treesitter provides syntax-aware parsing for highlighting and editor features.
- Change search and picker keymaps in `lua/plugins/search.lua`.
- Change symbol outline and diagnostics picker behavior in `lua/plugins/lsp.lua`.
- Change Git tooling in `lua/plugins/git.lua`.
- Change artificial intelligence assistant tooling in `lua/plugins/ai.lua`.
- Change Model Context Protocol hub setup in `lua/plugins/mcphub.lua` and server definitions in `mcpservers.json`.
- Change Makefile/task runner integration in `lua/plugins/tasks.lua`.
- Change the custom Cmux scratchpad task picker in `lua/user/cmux_tasks.lua`.
- Change colors, highlights, and icons in `lua/plugins/astroui.lua`, but note that file is currently disabled by an early return guard.

`lua/plugins/user.lua` is an AstroNvim example file and is currently disabled. Prefer creating or updating focused files under `lua/plugins/` instead of enabling the whole example file.

## Current language and formatting setup

Language servers are configured through AstroLSP in `lua/plugins/astrolsp.lua`. AstroLSP is AstroNvim's layer for Neovim's language server support.

- Bash uses `bashls` for definitions, completion, hover, and diagnostics.
- Ruby uses `ruby_lsp` for navigation, completion, hover, and references.
- Ruby type-checking uses `sorbet`, but it only attaches when a project has `sorbet/config`.
- Python support starts with AstroCommunity Python subpacks imported in `lua/community.lua`. Those subpacks add Python and TOML Treesitter parsers, virtual environment selection, debugging through `debugpy`, test support, and formatting through `black` and `isort`. `lua/plugins/astrolsp.lua` lists `pyright` explicitly so Python buffers get language server support reliably.
- TypeScript and JavaScript support starts with the AstroCommunity TypeScript pack imported in `lua/community.lua`. That pack adds JavaScript, TypeScript, TSX, and JSDoc Treesitter parsers, TypeScript-specific tooling, and import updates on file rename or move. `lua/plugins/astrolsp.lua` also lists `vtsls` explicitly so TypeScript support works even when Mason cannot auto-enable it.

Do not add `rust_analyzer` to `lua/plugins/astrolsp.lua`. Rust language support is managed by `rustaceanvim` from the AstroCommunity Rust pack, and adding `rust_analyzer` here would attach two Rust language clients to the same buffer.

Do not enable `ts_ls` in `lua/plugins/astrolsp.lua` unless intentionally replacing `vtsls`. The AstroCommunity TypeScript pack uses `vtsls`, and running both TypeScript language clients at once creates duplicate diagnostics and completions.

Mason is configured in `lua/plugins/mason.lua` to install `js-debug-adapter`, `debugpy`, `black`, and `isort`. This Shopify-managed machine blocks Mason's `npm`-based `vtsls` install path, so `vtsls` is intentionally managed outside Mason. It was installed with `pnpm add -g @vtsls/language-server`, and `lua/plugins/astrolsp.lua` starts it with `vtsls --stdio`. Python language support uses `pyright`, which was installed with `pnpm add -g pyright`, and `lua/plugins/astrolsp.lua` starts it with `pyright-langserver --stdio`.

Formatter sources are configured in `lua/plugins/none-ls.lua`:

- Lua: `stylua`
- Python: `isort`, `black`
- JavaScript, TypeScript, and JSON: `prettierd`
- Terraform: `terraform_fmt`

Treesitter parsers are configured in `lua/plugins/treesitter.lua`.

## Current key setup

- Leader key: Space
- Local leader key: comma
- General keymaps: `lua/plugins/astrocore.lua`
- Language-related keymaps: `lua/plugins/astrolsp.lua` and `lua/plugins/lsp.lua`
- Search keymaps: `lua/plugins/search.lua`
- Git keymaps: `lua/plugins/git.lua`
- Artificial intelligence assistant keymaps: `lua/plugins/ai.lua`

## Generated files, cache, and local state

- `lazy-lock.json` is tracked. It records pinned plugin revisions and changes when plugins are installed or updated.
- Lazy.nvim installs plugin checkouts under Neovim's data directory, usually `~/.local/share/nvim/lazy/`.
- Mason installs external editor tools under Neovim's data directory, usually `~/.local/share/nvim/mason/`.
- Neovim state and logs usually live under `~/.local/state/nvim/`.
- Neovim cache usually lives under `~/.cache/nvim/`.
- `mcpservers.json` is tracked and currently contains an empty `mcpServers` object. Do not commit secrets there.

Do not commit generated plugin checkouts, Mason-installed binaries, Neovim cache files, or Neovim state files.

## Useful commands

From a shell:

```sh
nvim
nvim --headless "+Lazy! install" +qa
git status --short
selene .
```

Inside Neovim:

```vim
:Lazy
:Lazy sync
:Lazy update
:Mason
:LspInfo
:checkhealth
:TSUpdate
:MCPHub
:CodeCompanionChat Toggle
:ClaudeCode
```

## Useful documentation

- AstroNvim documentation: https://docs.astronvim.com/
- AstroCommunity TypeScript pack documentation: `~/.local/share/nvim/lazy/astrocommunity/lua/astrocommunity/pack/typescript/README.md` after AstroCommunity is installed
- AstroCommunity Python pack documentation: `~/.local/share/nvim/lazy/astrocommunity/lua/astrocommunity/pack/python/README.md` after AstroCommunity is installed
- AstroNvim help inside Neovim: `:h astrocore`, `:h astrolsp`, and `:h astroui`
- Lazy.nvim documentation: https://lazy.folke.io/
- Mason.nvim documentation: https://github.com/mason-org/mason.nvim
- none-ls documentation: https://github.com/nvimtools/none-ls.nvim
- Treesitter for Neovim documentation: https://github.com/nvim-treesitter/nvim-treesitter

## Contribution notes for agents

- Keep changes small and feature-focused. Prefer one plugin concern per file under `lua/plugins/`.
- Preserve the existing disabled-file guard pattern: files beginning with `if true then return ... end` are intentionally inactive.
- Prefer changing AstroNvim extension points over replacing the startup flow.
- Keep secrets out of this repository. Some plugins call local commands to fetch credentials at runtime; do not inline those credentials.
- After changing plugin specifications, expect `lazy-lock.json` to change when plugins are installed or updated.
