return {
    'zapling/mason-lock.nvim',
    lazy = false,
    config = function ()
        require('mason-lock').setup({
            lockfile_path = vim.fn.expand('$HOME/dotfiles/nvim/mason-lock.json')
        })
    end
}
