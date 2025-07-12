vim.lsp.config('*', {
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            }
        }
    },
})

vim.lsp.enable({
    'luals',
    'ts-ls',
    'intelephense',
    'gopls',
    'rust-analyzer',
    'tailwindcss',
    'volar',
    'html',
    'dockerls',
    'docker-compose-language-server',
    'bashls',
    'clangd',
    'emmet-language-server',
    'csharp-ls',
    'qmlls'
})

vim.diagnostic.config({ virtual_text = true })
vim.o.completeopt = 'menuone,popup,fuzzy,noselect'

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        require('config.completions')(args)
    end,
})
