return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require('config.lsp.setup')
      require('config.lsp.config')
      require('config.lsp.functions')
    end
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<CR>", desc = "Mason" },
    },
  },

  {
    "antosha417/nvim-lsp-file-operations",
    event = "LspAttach",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-tree/nvim-tree.lua" },
    },
    config = function()
      -- nvim-lsp-file-operations starts a timer that stats its logfile, but the
      -- file is only created when something is logged. Create it up front so the
      -- timer does not fail with "Unable to retrieve stats from logfile".
      local logfile = vim.fs.joinpath(vim.fn.stdpath("cache"), "lsp-file-operations.log")
      if vim.fn.isdirectory(logfile) == 1 then vim.fn.delete(logfile, "d") end
      if vim.fn.filereadable(logfile) == 0 then vim.fn.writefile({}, logfile) end
      require("lsp-file-operations").setup()
    end
  },
}
