return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local bufferline = require("bufferline")

      -- Zed-like bar: lighter strip, selected tab blends into editor bg
      local p = require("gruvbox").palette
      local bar, sel, sep = p.dark1, p.dark0, p.dark0
      local highlights = {
        fill = { bg = bar },
        background = { fg = p.light4, bg = bar },
        buffer_visible = { fg = p.light4, bg = bar },
        buffer_selected = { fg = p.light1, bg = sel, bold = true },
        indicator_visible = { fg = bar, bg = bar },
        indicator_selected = { fg = p.bright_yellow, bg = sel },
        separator = { fg = sep, bg = bar },
        separator_visible = { fg = sep, bg = bar },
        separator_selected = { fg = sep, bg = sel },
        offset_separator = { fg = sep, bg = bar },
        tab = { bg = bar },
        tab_selected = { bg = sel },
        tab_close = { bg = bar },
        tab_separator = { fg = sep, bg = bar },
        tab_separator_selected = { fg = sep, bg = sel },
        trunc_marker = { bg = bar },
      }
      for _, group in ipairs({ "numbers", "modified", "duplicate", "close_button", "pick" }) do
        highlights[group] = { bg = bar }
        highlights[group .. "_visible"] = { bg = bar }
        highlights[group .. "_selected"] = { bg = sel }
      end

      bufferline.setup {
        highlights = highlights,
        options = {
          close_command = function(n)
            Snacks.bufdelete(n)
          end,
          right_mouse_command = function(n)
            Snacks.bufdelete(n)
          end,
          show_buffer_close_icons = false,
          separator_style = "thin",
          always_show_bufferline = true,
          style_preset = bufferline.style_preset.no_italic,
          numbers = function(opts)
            return string.format("%s", opts.ordinal)
          end,
          custom_filter = function(buf_number)
            -- filter out filetypes you don't want to see
            if vim.bo[buf_number].filetype ~= "qf" then
              return true
            end
          end,
          offsets = {
            {
              filetype = "snacks_layout_box",
              text = "",
              highlight = "EcovimNvimTreeTitle",
              text_align = "center",
              separator = false,
            },
          },
        },
      }
    end,
    keys = {
      { "<A-1>",       "<cmd>BufferLineGoToBuffer 1<CR>" },
      { "<A-2>",       "<cmd>BufferLineGoToBuffer 2<CR>" },
      { "<A-3>",       "<cmd>BufferLineGoToBuffer 3<CR>" },
      { "<A-4>",       "<cmd>BufferLineGoToBuffer 4<CR>" },
      { "<A-5>",       "<cmd>BufferLineGoToBuffer 5<CR>" },
      { "<A-6>",       "<cmd>BufferLineGoToBuffer 6<CR>" },
      { "<A-7>",       "<cmd>BufferLineGoToBuffer 7<CR>" },
      { "<A-8>",       "<cmd>BufferLineGoToBuffer 8<CR>" },
      { "<A-9>",       "<cmd>BufferLineGoToBuffer 9<CR>" },
      { "<Leader>bb",  "<cmd>BufferLineMovePrev<CR>",                desc = "Move back" },
      { "<Leader>bl",  "<cmd>BufferLineCloseLeft<CR>",               desc = "Close Left" },
      { "<Leader>br",  "<cmd>BufferLineCloseRight<CR>",              desc = "Close Right" },
      { "<Leader>bn",  "<cmd>BufferLineMoveNext<CR>",                desc = "Move next" },
      { "<Leader>bp",  "<cmd>BufferLinePick<CR>",                    desc = "Pick Buffer" },
      { "<Leader>bP",  "<cmd>BufferLineTogglePin<CR>",               desc = "Pin/Unpin Buffer" },
      { "<Leader>bsd", "<cmd>BufferLineSortByDirectory<CR>",         desc = "Sort by directory" },
      { "<Leader>bse", "<cmd>BufferLineSortByExtension<CR>",         desc = "Sort by extension" },
      { "<Leader>bsr", "<cmd>BufferLineSortByRelativeDirectory<CR>", desc = "Sort by relative dir" },
    }
  }
}
