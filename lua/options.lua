require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

--
-- Copy Github link to the clipboard
vim.g.gh_open_command = 'fn() { echo "$@" | pbcopy; }; fn '

-- Configuration for nvim-ufo
-- See https://github.com/kevinhwang91/nvim-ufo?tab=readme-ov-file#minimal-configuration
o.foldcolumn = "1" -- '0' is not bad
o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
o.foldlevelstart = 99
o.foldenable = true
