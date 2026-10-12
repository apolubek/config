return {
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        python = { "pylint" },
      }

      local oxlint_fts = {
        javascript = true,
        typescript = true,
        javascriptreact = true,
        typescriptreact = true,
        svelte = true,
      }

      -- Prefer oxlint in projects that opted into oxc; elsewhere use linters_by_ft
      local function uses_oxlint(bufnr)
        return vim.fs.find(
          { ".oxlintrc.json", "oxlint.config.ts", "node_modules/.bin/oxlint" },
          { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)) }
        )[1] ~= nil
      end

      vim.keymap.set("n", "<leader>l", function()
        if oxlint_fts[vim.bo.filetype] and uses_oxlint(0) then
          lint.try_lint("oxlint")
        else
          lint.try_lint()
        end
      end, { desc = "lint file" })
    end,
  },
}
