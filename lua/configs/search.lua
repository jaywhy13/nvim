local builtin = require "telescope.builtin"
require("search").setup {
  tabs = {
    {
      "Files",
      function(opts)
        opts = opts or {}
        builtin.find_files(opts)
      end,
    },
    {
      "Text",
      function()
        require("telescope").extensions.live_grep_args.live_grep_args()
      end,
    },
    {
      "Buffers",
      function()
        builtin.buffers()
      end,
    },
    {
      "Jumplist",
      function()
        builtin.jumplist()
      end,
    },
  },
}
