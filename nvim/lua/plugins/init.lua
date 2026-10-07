return {
  -- Add subdirectories here
  {
    { import = "plugins.ai" },
    { import = "plugins.languages" },
  },

  -- ╭─────────────────────────────────────────────────────────╮
  -- │ General plugins                                         │
  -- ╰─────────────────────────────────────────────────────────╯
  { "AndrewRadev/switch.vim", lazy = false },
  { "tpope/vim-repeat",       lazy = false },
  { "tpope/vim-speeddating",  lazy = false },
  {
    "airblade/vim-rooter",
    event = "VeryLazy",
    config = function()
      vim.g.rooter_patterns = EcoVim.plugins.rooter.patterns
      vim.g.rooter_silent_chdir = 1
      vim.g.rooter_resolve_links = 1
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = true,
  },
  {
    "ChmaraX/herdr-nvim",
    opts = {},
    config = function(_, opts)
      local herdr = require("herdr-nvim")
      herdr.setup(opts)
      -- the sidebar daemon calls setup() again on VimEnter; a second run
      -- warns "not overriding existing map" for every map set above
      herdr.setup = function() end
    end,
  },
}
