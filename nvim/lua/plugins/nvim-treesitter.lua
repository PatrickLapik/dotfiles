return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
    parser_config.blade = {
      install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
      },
      filetype = "blade",
    }
    vim.filetype.add({
      pattern = {
        [".*%.blade%.php"] = "blade",
      },
    })
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "markdown", "html", "php", "blade", "php_only", "go" },
      auto_installed = true,
      highlight = true,
      indent = { enabled = true },
    })
  end,
}
