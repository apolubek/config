return {
  {
    "Isrothy/neominimap.nvim",
    version = "v3.*",
    lazy = false, -- plugin lazy-loads itself
    keys = {
      { "<leader>M", "<cmd>Neominimap Toggle<cr>", desc = "toggle minimap" },
    },
    init = function()
      vim.g.neominimap = {
        auto_enable = true,
        layout = "float",
        float = { minimap_width = 20, window_border = "none", margin = { right = 3 } }, -- leave room for satellite scrollbar (whole-file diff marks)
        exclude_filetypes = { "help", "bigfile", "snacks_picker_list", "snacks_picker_input", "snacks_layout_box", "alpha", "lazy", "mason" },
        git = { enabled = true, mode = "sign" },
        diagnostic = { enabled = true, mode = "line" },
        search = { enabled = true },
      }
    end,
  },
}
