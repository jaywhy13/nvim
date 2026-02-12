# Neovim Configuration Overview

This repository contains a modular Neovim configuration built on top of [NvChad](https://nvchad.com/) and managed with the [Lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager. The setup is designed for modern development workflows, providing enhanced code editing, AI assistance, testing, Git integration, and more.

## Plugin Themes Overview

Below is a high-level summary of the main plugin themes and the plugins used for each, with brief descriptions of their roles.
| Theme | Plugins & Description |
| :--- | :--- |
| **AI & Code Assistance** | **CodeCompanion**: In-editor AI assistant for code generation and refactoring. <br> **Copilot**: GitHub Copilot code suggestions. <br> **CopilotChat**: Chat-based Copilot interface. <br> **MCPHub**: Multi-model AI chat and code tools. |
| **Editing & Navigation** | **Telescope**: Fuzzy finder for files, symbols, and more. <br> **nvim-tree**: File explorer. <br> **Aerial**: Symbols outline. <br> **search.nvim**: Tabbed search UI. <br> **nvim-ufo**: Advanced code folding. <br> **nvim-surround**: Surround text objects. <br> **multicursors.nvim**: Multiple cursors support. |
| **Syntax & LSP** | **nvim-treesitter**: Syntax highlighting and parsing. <br> **nvim-lspconfig**: LSP client configuration. <br> **vim-graphql**: GraphQL syntax support. |
| **Testing & Tasks** | **neotest**: Test runner integration. <br> **makeit.nvim**: Makefile integration. <br> **overseer.nvim**: Task runner and job management. |
| **Git & Collaboration** | **neogit**: Git UI. <br> **lazygit.nvim**: LazyGit integration. <br> **octo.nvim**: GitHub PR and issue management. <br> **vim-gh-line**: Copy GitHub links to lines. |
| **Diagnostics & Refactoring** | **trouble.nvim**: Diagnostics and quickfix list UI. <br> **conform.nvim**: Code formatter. <br> **nvim-spectre**: Find and replace across project. |
| **Diff & Markdown** | **mini.diff**: Inline diff view. <br> **markview.nvim**: Enhanced markdown rendering. <br> **img-clip.nvim**: Paste images from clipboard into markdown/chat buffers. |
| **Utilities & Misc** | **weather.nvim**: Weather info in Neovim. |
## Getting Started

- **Requirements:** Neovim 0.11+, Node.js (for some plugins), and a Mac system (for some build steps).
- **Plugin Management:** All plugins are managed via Lazy.nvim and configured in `lua/plugins/init.lua`.
- **Customization:** Each plugin's configuration can be found in the `lua/configs/` directory.

## Repository Structure

```
.
├── init.lua                # Main Neovim configuration entry point (highlighted)
├── mcpservers.json         # Server configuration file (highlighted)
├── lua/
│   ├── chadrc.lua
│   ├── colors.lua          # Color scheme and highlight settings
│   ├── mappings.lua        # Key mappings and shortcuts
│   ├── options.lua         # General Neovim options
│   ├── configs/            # Plugin configurations (one file per plugin)
│   ├── custom/             # User-specific or experimental Lua scripts
│   └── plugins/            # Plugin initialization and management
├── .stylua.toml
├── LICENSE
├── README.md
└── lazy-lock.json
```

### Highlights

- **init.lua**: The main entry point for Neovim configuration.
- **mcpservers.json**: Contains server-specific settings.
- **lua/configs/**: Houses configuration files for each plugin, making it easy to manage and customize plugins individually.
- **lua/colors.lua**: Manages color schemes and highlight groups.
- **lua/mappings.lua**: Centralizes key mappings for easier navigation and command execution.
- **lua/options.lua**: Sets global Neovim options.
- **lua/custom/**: For user-specific or experimental Lua scripts.
- **lua/plugins/**: Handles plugin initialization and management.

This modular structure keeps your configuration organized, maintainable, and easy to extend.

---

Continue reading for setup instructions, usage tips, and plugin-specific configuration details.

