return {
  {
    "lewis6991/satellite.nvim",
    event = "BufReadPost",
    opts = {
      excluded_filetypes = { "snacks_picker_list", "snacks_picker_input", "snacks_layout_box", "alpha" },
      handlers = {
        gitsigns   = { enabled = true },
        diagnostic = { enabled = true },
        search     = { enabled = true },
        marks      = { enabled = false },
      },
    },
  },
}
