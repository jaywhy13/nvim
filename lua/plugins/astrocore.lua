-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- navigate buffer tabs
        ["L"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["H"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- close current buffer
        ["<S-x>"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },

        -- command mode shortcut
        [";"] = { ":", desc = "Enter command mode" },

        -- save
        ["<C-s>"] = { "<cmd>w!<cr>", desc = "Save file" },
        ["<C-S-s>"] = { "<cmd>noautocmd w<cr>", desc = "Save file without triggering auto-commands" },

        -- quit all
        ["<Leader>q"] = { "<cmd>qa!<cr>", desc = "Quit all" },

        -- disable AstroNvim default <Leader>w save
        ["<Leader>w"] = false,

        -- window management
        ["<M-up>"] = { "<C-w>+", desc = "Increase window height" },
        ["<M-down>"] = { "<C-w>-", desc = "Decrease window height" },
        ["<Leader>wo"] = { "<C-w>o", desc = "Close other windows" },
        ["<Leader>wq"] = { "<C-w>q", desc = "Close window" },

        -- clear search highlights
        ["<Leader>h"] = { "<cmd>noh<cr>", desc = "Clear search highlights" },

        -- toggle markdown checkbox on the current line
        ["<Leader>mt"] = {
          function()
            local current_line = vim.api.nvim_get_current_line()
            local unchecked_checkbox_start_column = current_line:find("%[ %]")

            if unchecked_checkbox_start_column then
              local checked_line = current_line:sub(1, unchecked_checkbox_start_column)
                .. "x"
                .. current_line:sub(unchecked_checkbox_start_column + 2)

              vim.api.nvim_set_current_line(checked_line)
              return
            end

            local checked_checkbox_start_column = current_line:find("%[[xX]%]")

            if checked_checkbox_start_column then
              local unchecked_line = current_line:sub(1, checked_checkbox_start_column)
                .. " "
                .. current_line:sub(checked_checkbox_start_column + 2)

              vim.api.nvim_set_current_line(unchecked_line)
              return
            end

            vim.notify("No markdown checkbox found on current line", vim.log.levels.INFO)
          end,
          desc = "Toggle markdown checkbox",
        },

        -- copy relative file path to clipboard
        ["<Leader>cf"] = {
          function()
            local path = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd() .. "/", "")
            vim.fn.setreg("+", path)
          end,
          desc = "Copy relative file path",
        },

        -- terminal toggle
        ["<A-h>"] = { "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle horizontal terminal" },
      },

      i = {
        -- save from insert mode
        ["<C-s>"] = { "<ESC><cmd>w!<cr>", desc = "Save file" },
      },

      v = {
        -- wrap visual selection with parentheses
        ["<Leader>("] = { "<esc>bi(<esc>wwhi)<esc>", desc = "Wrap selection with parentheses" },
      },

      t = {
        -- terminal toggle (dismiss)
        ["<A-h>"] = { "<cmd>ToggleTerm<cr>", desc = "Toggle horizontal terminal" },

        -- exit terminal mode (alias for the awkward default <C-\><C-n>)
        ["<C-x>"] = { [[<C-\><C-n>]], desc = "Exit terminal mode" },
      },
    },
  },
}
