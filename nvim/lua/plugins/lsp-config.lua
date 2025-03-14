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
                    "volar",
                    "gopls",
                },
            }
        end,
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local lspconfig = require("lspconfig")
            lspconfig.ts_ls.setup{
                init_options = {
                    plugins = {
                        {
                            name = "@vue/typescript-plugin",
                            location = "/usr/lib/node_modules/@vue/typescript-plugin",
                            languages = { "vue", "javascript", "typescript" },
                        },
                    },
                    filetypes = {
                        "javascript",
                        "typescript",
                        "vue",
                    },
                },
            }
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
            })
            lspconfig.rust_analyzer.setup({
                capabilities = capabilities,
            })
            lspconfig.html.setup({
                capabilities = capabilities,
            })
            lspconfig.tailwindcss.setup({
                capabilities = capabilities,
            })
            lspconfig.intelephense.setup({
                capabilities = capabilities,
            })
            lspconfig.clangd.setup({
                capabilities = capabilities,
            })
            lspconfig.volar.setup({
                capabilities = capabilities,
                filetypes = { "vue", "typescript", "typescriptreact", "javascript", "javascriptreact" },
                init_options = {
                    typescript = {
                        tsdk =
                        "/home/patrick/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib",
                    },
                    vue = {
                        hybridMode = false,
                    },
                },
            })
            lspconfig.docker_compose_language_service.setup({
                capabilities = capabilities,
            })
            lspconfig.dockerls.setup({
                capabilities = capabilities,
            })
            -- lspconfig.stimulus_ls.setup({
            --   capabilities = capabilities
            -- })
            lspconfig.gdscript.setup({
                capabilities = capabilities,
            })
            lspconfig.bashls.setup({
                capabilities = capabilities,
            })
            lspconfig.gopls.setup({
                capabilities = capabilities,
            })
            lspconfig.jdtls.setup({
                capabilities = capabilities,
            })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
        end,
    },
}
