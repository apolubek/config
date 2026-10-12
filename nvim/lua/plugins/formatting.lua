return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          css = { "oxfmt", "prettierd", "prettier" },
          graphql = { "oxfmt", "prettierd", "prettier" },
          html = { "oxfmt", "prettierd", "prettier" },
          javascript = { "oxfmt", "prettierd", "prettier" },
          javascriptreact = { "oxfmt", "prettierd", "prettier" },
          json = { "oxfmt", "prettierd", "prettier" },
          lua = { "stylua" },
          markdown = { "oxfmt", "prettierd", "prettier" },
          python = { "isort", "black" },
          sql = { "sql-formatter" },
          svelte = { "oxfmt", "prettierd", "prettier" },
          typescript = { "oxfmt", "prettierd", "prettier", "sql-formatter" },
          typescriptreact = { "oxfmt", "prettierd", "prettier" },
          yaml = { "oxfmt", "prettier" },
          xml = { "xmlformatter" },
        },
        formatters = {
          -- Only in projects that opted into oxc; elsewhere fall through to prettier
          oxfmt = {
            condition = function(_, ctx)
              return vim.fs.find(
                { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts", "node_modules/.bin/oxfmt" },
                { upward = true, path = ctx.dirname }
              )[1] ~= nil
            end,
          },
        },
        format_on_save = {
          timeout_ms = 1000,
          lsp_format = "fallback",
        },
        default_format_opts = {
          stop_after_first = true,
        },
      })

      vim.keymap.set({ "n" }, "<leader>f", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          -- timeout_ms = 500,
        })
      end, { desc = "format file" })

      vim.keymap.set({ "v" }, "<leader>f", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          -- timeout_ms = 500,
        })
      end, { desc = "format selection" })

      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end

        conform.format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })
    end,
  },
}
