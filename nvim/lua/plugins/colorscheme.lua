return {
  {
    -- kept installed: galaxyline reads tokyonight.colors
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "folke/tokyonight.nvim" },
    config = function()
      require("gruvbox").setup({
        contrast = "",
      })
      vim.cmd("colorscheme " .. EcoVim.colorscheme)
      -- overrides in config.colorscheme are tokyonight-specific
      if EcoVim.colorscheme:match("^tokyonight") then
        require("config.colorscheme")
      end
    end,
  },
}
