vim.lsp.config("*", {
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            }
        }
    },
})

vim.o.completeopt = "menu,noinsert,popup,fuzzy"

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        require('completions')(args)
    end,
})

vim.lsp.enable({
    "luals"
})
