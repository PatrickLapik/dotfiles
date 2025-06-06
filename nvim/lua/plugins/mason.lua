return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        config = function()
            require("mason-lspconfig").setup{
                automatic_installation = true,
                ensure_installed = {
                    "ts_ls",
                    "lua_ls",
                    "rust_analyzer",
                    "tailwindcss",
                    "intelephense",
                    "clangd",
                    "vuels",
                    "gopls",
                    "emmet_language_server"
                },
            }
        end,
    },
}
