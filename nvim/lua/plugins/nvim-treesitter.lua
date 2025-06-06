return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "markdown", "html", "php", "blade", "php_only", "go", "javascript" },
      auto_installed = true,
      highlight = {
          enable = true,
      },
      indent = { enable = true },
    })
  end,
}
