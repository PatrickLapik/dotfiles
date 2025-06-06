return {
  "sainnhe/gruvbox-material",
  config = function()
    vim.g.gruvbox_material_background = "soft"
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_transparent_background = 2
    vim.cmd.colorscheme("gruvbox-material")
  end
}
