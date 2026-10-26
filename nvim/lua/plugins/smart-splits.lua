return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      local ss = require("smart-splits")

      -- Herdr owns the ctrl+h/j/k/l keys and forwards them into Neovim. When
      -- smart-splits reaches the edge of Neovim's layout, hand the move back to
      -- Herdr so ctrl+h can leave Neovim for the pane on its left.
      local function herdr_focus(direction)
        local pane = vim.env.HERDR_PANE_ID
        if not pane then return false end
        vim.system({
          vim.env.HERDR_BIN_PATH or "herdr",
          "pane",
          "focus",
          "--direction",
          direction,
          "--pane",
          pane,
        })
        return true
      end

      ss.setup({
        move = {
          at_edge = function(ctx)
            if not herdr_focus(ctx.direction) then
              ctx.wrap()
            end
          end,
        },
      })

      -- resizing splits
      -- these keymaps will also accept a range,
      -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
      vim.keymap.set('n', '<A-h>', ss.resize_left)
      vim.keymap.set('n', '<A-j>', ss.resize_down)
      vim.keymap.set('n', '<A-k>', ss.resize_up)
      vim.keymap.set('n', '<A-l>', ss.resize_right)
      -- moving between splits
      vim.keymap.set('n', '<C-h>', ss.move_cursor_left)
      vim.keymap.set('n', '<C-j>', ss.move_cursor_down)
      vim.keymap.set('n', '<C-k>', ss.move_cursor_up)
      vim.keymap.set('n', '<C-l>', '<C-w>l')
      -- vim.keymap.set('n', '<C-l>', ss.move_cursor_right) -- This is temporary because it doesn't work with Snacks Explorer
      -- NOTE: smart-splits.nvim does not provide `move_cursor_previous`; map to prev window instead
      vim.keymap.set('n', '<C-\\>', '<C-w>p')
      -- swapping buffers between windows
      vim.keymap.set('n', '<leader><leader>h', ss.swap_buf_left)
      vim.keymap.set('n', '<leader><leader>j', ss.swap_buf_down)
      vim.keymap.set('n', '<leader><leader>k', ss.swap_buf_up)
      vim.keymap.set('n', '<leader><leader>l', ss.swap_buf_right)
    end
  }
}
