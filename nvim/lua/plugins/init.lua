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

      -- The sidebar daemon keeps the HERDR_PANE_ID of the first sidebar pane;
      -- after a re-toggle it points at a closed pane and ctrl+h/j/k/l can't
      -- leave the sidebar (ChmaraX/herdr-nvim#40). Re-point it on UI attach.
      local function refresh_pane_id()
        local tab = vim.env.HERDR_TAB_ID
        if not tab or vim.fn.executable("herdr") == 0 then return end
        local ok, list = pcall(vim.json.decode, vim.fn.system({ "herdr", "pane", "list" }))
        if not ok or type(list) ~= "table" or not list.result then return end
        local sidebar
        for _, pane in ipairs(list.result.panes) do
          if pane.pane_id == vim.env.HERDR_PANE_ID then return end
          if pane.tab_id == tab and pane.label == "nvim sidebar" then sidebar = pane.pane_id end
        end
        if sidebar then vim.env.HERDR_PANE_ID = sidebar end
      end
      vim.api.nvim_create_autocmd("UIEnter", { callback = refresh_pane_id })
      herdr.refresh_pane_id = refresh_pane_id
    end,
  },
}
