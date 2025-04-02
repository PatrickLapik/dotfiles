return {
    cmd = { 'typescript-language-server', '--stdio' },
    filetypes = { 'typescript', 'javascript', 'vue', 'typescriptreact', 'javascriptreact' },
    root_markers = { 'package.json' },
    init_options = {
        plugins = {
            {
                name = '@vue/typescript-plugin',
                location = '/usr/lib/node_modules/@vue/typescript-plugin',
                languages = { 'vue', 'javascript', 'typescript' },
            },
        }
    }
}
