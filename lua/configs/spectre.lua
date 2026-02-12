require("spectre").setup {
  find_engine = {
    -- rg is map with finder arguments
    ["rg"] = {
      cmd = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--pcre2",
      },
    },
    -- you can put your own finder here like ag, pt, grep etc
    -- and a custom function
  },
  mapping = {
    ["toggle_line"] = {
      map = "tl",
      cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
      desc = "toggle line",
    },
    ["send_to_qf"] = {
      map = "q",
      cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
      desc = "send all items to quickfix",
    },
    ["run_current_replace"] = {
      map = "r",
      cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
      desc = "replace current line",
    },
    ["run_replace"] = {
      map = "R",
      cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
      desc = "replace all",
    },
    ["change_view_mode"] = {
      map = "v",
      cmd = "<cmd>lua require('spectre').change_view()<CR>",
      desc = "change result view mode",
    },
    ["delete_line"] = {
      map = "rd",
      cmd = "<cmd>lua require('spectre.actions').run_delete_line()<CR>",
      desc = "delete line",
    },
  },
}
