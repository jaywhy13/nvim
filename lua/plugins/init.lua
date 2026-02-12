return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- Github line copy
  { "ruanyl/vim-gh-line", event = "BufEnter" },
  -- Add trouble for Diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufWritePre",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  -- Configure LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  -- Configure Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    config = function()
      require "configs.telescope"
    end,
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      -- This will not install any breaking changes.
      -- For major updates, this must be adjusted manually.
      version = "^1.0.0",
    },
  },
  -- Configure Treesitter and provide a list of languages
  -- that should have syntax highlights
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
        "typescript",
        "terraform",
        "markdown",
        "markdown_inline",
      },
    },
  },
  -- Add better code folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require "configs.nvim-ufo"
    end,
  },
  -- Github Copilot
  {
    "github/copilot.vim",
    event = "BufEnter",
    config = function()
      require "configs.copilot"
    end,
  },
  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    event = "BufEnter",
    config = function()
      require "configs.copilot_chat"
    end,
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  -- Code Companion

  {
    "olimorris/codecompanion.nvim",
    opts = {},
    event = "BufEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require "configs.codecompanion"
    end,
  },

  -- Some additional plugins to make Code Companion better
  {
    -- I wasn't able to markdown working properly. In normal mode, headings
    -- and other markdown elements were not being rendered properly.
    -- I created an issue here: https://github.com/OXY2DEV/markview.nvim/issues/92
    -- For now, doing :Markview toggle works nicely
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
    },
    opts = function()
      local function conceal_tag(icon, hl_group)
        return {
          on_node = { hl_group = hl_group },
          on_closing_tag = { conceal = "" },
          on_opening_tag = {
            conceal = "",
            virt_text_pos = "inline",
            virt_text = { { icon .. " ", hl_group } },
          },
        }
      end

      return {
        markdown = {
          hybrid_modes = { "n", "i" },
        },
        html = {
          container_elements = {
            ["^buf$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^file$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^help$"] = conceal_tag("󰘥", "CodeCompanionChatVariable"),
            ["^image$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^symbols$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^url$"] = conceal_tag("󰖟", "CodeCompanionChatVariable"),
            ["^var$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^tool$"] = conceal_tag("", "CodeCompanionChatTool"),
            ["^user_prompt$"] = conceal_tag("", "CodeCompanionChatTool"),
            ["^group$"] = conceal_tag("", "CodeCompanionChatToolGroup"),
          },
        },
      }
    end,
  },
  --Use mini.diff for a cleaner diff when using the inline assistant or the @insert_edit_into_file tool
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require "mini.diff"
      diff.setup {
        -- Disabled by default
        source = diff.gen_source.none(),
      }
    end,
  },
  -- Use img-clip.nvim to copy images from your system clipboard into a chat buffer via :PasteImage:

  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
  -- Weather
  {
    "wyattjsmith1/weather.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require "configs.weather"
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  -- Github PRs
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = { "Octo" },
    config = function()
      require "configs.octo"
    end,
  },
  -- Make file
  { -- This plugin
    "Zeioth/makeit.nvim",
    cmd = { "MakeitOpen", "MakeitToggleResults", "MakeitRedo" },
    dependencies = { "stevearc/overseer.nvim" },
    opts = {},
  },
  { -- The task runner we use
    "stevearc/overseer.nvim",
    commit = "400e762648b70397d0d315e5acaf0ff3597f2d8b",
    cmd = { "MakeitOpen", "MakeitToggleResults", "MakeitRedo" },
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
  },

  {
    "jparise/vim-graphql",
  },

  --
  -- These are some examples, uncomment them if you want to see them work!
  --
  -- {
  -- 	"williamboman/mason.nvim",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"lua-language-server", "stylua",
  -- 			"html-lsp", "css-lsp" , "prettier"
  -- 		},
  -- 	},
  -- },
  --
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    config = function()
      require "configs.avante"
    end,
  },

  -- Better find and replace with Spectre
  {
    "nvim-pack/nvim-spectre",
    event = "BufEnter",
    config = function()
      require "configs.spectre"
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- Multiple cursors
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvimtools/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
  },

  -- Git integration
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require "configs.nvim-surround"
    end,
  },
  -- Aerial -- symbols outline
  {
    "stevearc/aerial.nvim",
    opts = {},
    event = "BufRead",
    -- Optional dependencies
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require "configs.aerial"
    end,
  },
  -- Tests
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require "configs.neotest"
    end,
  },
  -- Neotree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = function()
      require "configs.nvim-tree"
    end,
  },
  -- Tabbed searches
  {
    "FabianWirth/search.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require "configs.search"
    end,
  },

  -- Configure MCP Hub
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "BufRead",
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require "configs.mcphub"
    end,
  },

  -- Use Copilot as suggestions
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Code Companion

  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- Some additional plugins to make Code Companion better
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = function()
      local function conceal_tag(icon, hl_group)
        return {
          on_node = { hl_group = hl_group },
          on_closing_tag = { conceal = "" },
          on_opening_tag = {
            conceal = "",
            virt_text_pos = "inline",
            virt_text = { { icon .. " ", hl_group } },
          },
        }
      end

      return {
        html = {
          container_elements = {
            ["^buf$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^file$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^help$"] = conceal_tag("󰘥", "CodeCompanionChatVariable"),
            ["^image$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^symbols$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^url$"] = conceal_tag("󰖟", "CodeCompanionChatVariable"),
            ["^var$"] = conceal_tag("", "CodeCompanionChatVariable"),
            ["^tool$"] = conceal_tag("", "CodeCompanionChatTool"),
            ["^user_prompt$"] = conceal_tag("", "CodeCompanionChatTool"),
            ["^group$"] = conceal_tag("", "CodeCompanionChatToolGroup"),
          },
        },
      }
    end,
  },
  --Use mini.diff for a cleaner diff when using the inline assistant or the @insert_edit_into_file tool
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require "mini.diff"
      diff.setup {
        -- Disabled by default
        source = diff.gen_source.none(),
      }
    end,
  },
  -- Use img-clip.nvim to copy images from your system clipboard into a chat buffer via :PasteImage:

  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        codecompanion = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}
