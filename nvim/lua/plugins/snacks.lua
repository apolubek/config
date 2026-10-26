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
        -- Panes spawned by herdr/nvim get a curated PATH that omits ~/.bun/bin,
        -- so lazygit's diffRenderers (`critique`) fail with "No such file or
        -- directory". Prepend the tool dirs here so spawn is env-independent.
        env = {
          PATH = table.concat({
            vim.fn.expand("~/.bun/bin"),
            vim.fn.expand("~/.local/bin"),
            vim.fn.expand("~/.cargo/bin"),
            vim.env.PATH,
          }, ":"),
        },
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
        sources = {
          explorer = {
            follow_file = false, -- reveal current file only on open (see <C-e>), not on every buffer switch
            actions = {
              -- Like the built-in `y` (explorer_yank), but paths relative to cwd
              explorer_yank_relative = function(picker)
                if vim.fn.mode():find("^[vV]") then picker.list:select() end
                local files = {} ---@type string[]
                for _, item in ipairs(picker:selected({ fallback = true })) do
                  table.insert(files, vim.fn.fnamemodify(Snacks.picker.util.path(item), ":."))
                end
                picker.list:set_selected()
                vim.fn.setreg("+", table.concat(files, "\n"))
                Snacks.notify.info("Yanked " .. table.concat(files, ", "))
              end,
            },
            win = {
              list = {
                keys = {
                  ["<c-]>"] = "explorer_cd",
                  ["Y"] = { "explorer_yank_relative", mode = { "n", "x" } },
                }
              }
            }
          },
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
      {
        "<C-e>",
        function()
          local explorer = Snacks.picker.get({ source = "explorer" })[1]
          if explorer then return explorer:close() end
          local file = vim.api.nvim_buf_get_name(0)
          if file == "" or vim.fn.filereadable(file) == 0 then return Snacks.explorer.open() end
          -- The explorer filters out dotfiles and gitignored files, so reveal could not land on them
          local hidden = file:find("/%.") ~= nil
          local ignored = vim.system({ "git", "check-ignore", "-q", file }):wait().code == 0
          Snacks.explorer.open({
            hidden = hidden,
            ignored = ignored,
            on_show = function() Snacks.explorer.reveal({ file = file }) end,
          })
        end,
        desc = "explorer",
      },
      { "<C-p>",       function() Snacks.picker.smart() end,                                   desc = "smart files" },
      { "<S-p>",       function() Snacks.picker.grep() end,                                    desc = "grep" },
      { "<F12>",       function() Snacks.picker.lsp_definitions() end,                         desc = "go to definition" },
      { "gs",          function() Snacks.picker.lsp_symbols({ filter = { default = true }, layout = { preset = "vscode" } }) end, desc = "go to symbol" },
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
