return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup({
      options = {
        theme = 'adwaita'
      }
    })
  end
}


-- adwaita.normal = {
--     a = { fg = bg, bg = colors.teal_5, gui = 'bold' },
--     b = { fg = colors.teal_5, bg = nil },
--     c = { fg = fg, bg = nil },
-- }
--
-- adwaita.visual = {
--     a = { fg = bg, bg = colors.blue_5, gui = 'bold' },
--     b = { fg = colors.blue_5, bg = nil },
-- }
--
-- adwaita.inactive = {
--     b = { fg = fg, bg = nil },
--     a = { fg = fg, bg = bg, gui = 'bold' },
-- }
--
-- adwaita.replace = {
--     a = { fg = bg, bg = colors.purple_4, gui = 'bold' },
--     b = { fg = colors.purple_2, bg = nil },
--     c = { fg = fg, bg = nil },
-- }
--
-- adwaita.insert = {
--     a = { fg = bg, bg = colors.orange_4, gui = 'bold' },
--     b = { fg = colors.orange_1, bg = nil },
--     c = { fg = fg, bg = nil },
-- }
