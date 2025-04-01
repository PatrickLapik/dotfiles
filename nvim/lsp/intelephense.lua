return {
    cmd = { 'intelephense', '--stdio' },
    filetypes = { 'php' },
    root_markers = { 'composer.json', 'composer.lock' },
    settings = {
        intelephense = {
            files = {
                maxSize = 1000000,
            }
        }
    }
}
