return {
  {
    "folke/noice.nvim",
    cond = EcoVim.plugins.experimental_noice.enabled,
    lazy = false,
    config = function()
      require("noice").setup({
        messages = { enabled = false },
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            ["vim.lsp.util.stylize_markdown"] = false,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
          progress = {
            enabled = false,
          },
          hover = {
            enabled = true,
            silent = true,
          },
          signature = {
            enabled = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = false,        -- use a classic bottom cmdline for search
          command_palette = true,       -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false,           -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false,       -- add a border to hover docs and signature help
        },
      })

      vim.keymap.set({ "n", "i", "s" }, "<C-f>", function()
        if not require("noice.lsp").scroll(4) then
          return "<C-f>"
        end
      end, { silent = true, expr = true })

      vim.keymap.set({ "n", "i", "s" }, "<C-b>", function()
        if not require("noice.lsp").scroll(-4) then
          return "<C-b>"
        end
      end, { silent = true, expr = true })
    end
  }
}
