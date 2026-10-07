Snacks = Snacks

-- Move focus to the neighbouring herdr pane (no-op outside herdr)
local function herdr_focus(direction)
  local pane = vim.env.HERDR_PANE_ID
  if not pane then return end
  vim.system({ vim.env.HERDR_BIN_PATH or "herdr", "pane", "focus", "--direction", direction, "--pane", pane })
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile      = { enabled = true },
      dashboard    = { enabled = false },
      indent       = { enabled = false },
      input        = { enabled = true },
      notifier     = { enabled = true },
      explorer     = { enabled = true },
      lazygit      = {
        win = {
          keys = {
            -- herdr sends ctrl+h/l into nvim; lazygit's terminal would swallow them
            herdr_left  = { "<c-h>", function() herdr_focus("left") end,  mode = "t" },
            herdr_right = { "<c-l>", function() herdr_focus("right") end, mode = "t" },
          },
        },
      },
      picker       = {
        enabled = true,
        explorer = {
          opts = {
            win = {
              list = {
                keys = {
                  ["<c-]>"] = "explorer_cd",
                }
              }
            }
          }
        },
        previewers = {
          git = {
            native = true, -- use native (terminal) or Neovim for previewing git diffs and commits
          },
        },
        win = {
          -- input window
          input = {
            keys = {
              -- ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
              ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
              ["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
              ["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
            },
          },
        },
      },
      quickfile    = { enabled = false },
      scroll       = { enabled = false },
      statuscolumn = {
        enabled = true,
      },
      words        = { enabled = false },
    },
    keys = {
      -- ╭─────────────────────────────────────────────────────────╮
      -- │ Lazygit                                                 │
      -- ╰─────────────────────────────────────────────────────────╯
      { "<leader>gg",  function() Snacks.lazygit() end,                                        desc = "Lazygit" },
      { "<leader>gla", function() Snacks.lazygit.log() end,                                    desc = "Lazygit Log (cwd)" },
      { "<leader>glc", function() Snacks.lazygit.log_file() end,                               desc = "Lazygit Current File History" },
      -- ╭─────────────────────────────────────────────────────────╮
      -- │ Zen                                                     │
      -- ╰─────────────────────────────────────────────────────────╯
      { "<leader>z",   function() Snacks.zen({ win = { width = 200 } }) end,                   desc = "Zen Mode" },
      { "<leader>Z",   function() Snacks.zen.zoom() end,                                       desc = "Zoom Mode" },
      -- ╭─────────────────────────────────────────────────────────╮
      -- │ Picker                                                  │
      -- ╰─────────────────────────────────────────────────────────╯
      { "<C-e>",       function() Snacks.picker.explorer() end,                                desc = "explorer" },
      { "<C-p>",       function() Snacks.picker.smart() end,                                   desc = "smart files" },
      { "<S-p>",       function() Snacks.picker.grep() end,                                    desc = "grep" },
      { "<leader>pw",  function() Snacks.picker.grep_word() end,                               desc = "grep word",                   mode = { "n", "v" } },

      { "<leader>pl",  function() Snacks.picker.projects() end,                                desc = "projects list" },

      { "<leader>cd",  function() Snacks.picker.diagnostics() end,                             desc = "diagnostics" },

      { "<leader>sf",  function() Snacks.picker.files() end,                                   desc = "files" },
      { "<leader>sb",  function() Snacks.picker.buffers() end,                                 desc = "buffers" },
      { "<leader>sh",  function() Snacks.picker.recent() end,                                  desc = "recent files" },
      { "<leader>sH",  function() Snacks.picker.command_history() end,                         desc = "command history" },
      { "<leader>ss",  function() Snacks.picker.search_history() end,                          desc = "search history" },
      { "<leader>sq",  function() Snacks.picker.qflist() end,                                  desc = "quickfix list" },
      { "<leader>sc",  function() Snacks.picker.colorschemes() end,                            desc = "color schemes" },
      { "<leader>sd",  function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "dotfiles" },

      { "<leader>gf",  function() Snacks.picker.git_files() end,                               desc = "git files" },
      { "<leader>gs",  function() Snacks.picker.git_status() end,                              desc = "git status" },
      { "<leader>glA", function() Snacks.picker.git_log() end,                                 desc = "log" },
      { "<leader>glC", function() Snacks.picker.git_log_file() end,                            desc = "file commits" },
    },
  }
}
