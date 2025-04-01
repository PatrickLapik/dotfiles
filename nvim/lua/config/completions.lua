return function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
        -- Optional: trigger autocompletion on EVERY keypress. May be slow!
        local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
        client.server_capabilities.completionProvider.triggerCharacters = chars

        vim.api.nvim_create_autocmd({ 'TextChangedI' }, {
            buffer = args.buf,
            callback = function()
                vim.lsp.completion.get()
            end
        })

        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
end
