return {
  -- Browse and run Makefile targets from a floating picker
  {
    "Zeioth/makeit.nvim",
    dependencies = { "stevearc/overseer.nvim" },
    cmd = { "MakeitOpen", "MakeitToggleResults", "MakeitRedo" },
    opts = {},
    keys = {
      { "<Leader>mr", "<cmd>MakeitOpen<cr>",                             desc = "Run Makefile target" },
      { "<Leader>mf", "<cmd>MakeitOpen<cr><cmd>normal! iformat<cr>",    desc = "Run Makefile format target" },
    },
  },

  -- Task runner used by makeit.nvim to execute and display Makefile targets
  {
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
}
