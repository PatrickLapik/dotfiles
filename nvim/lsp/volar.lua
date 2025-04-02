return {
    cmd = { 'vue-language-server', '--stdio' },
    filetypes = { 'vue' },
    init_options = {
        typescript = {
            tsdk = '/home/patrick/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib',
        },
        vue = {
            hybridMode = false,
        },
    }
}
