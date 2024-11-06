return {
  {
    "ngtuonghy/live-server-nvim",
    build = ":LiveServerInstall",
    config = function()
      local liveserver = require("live-server-nvim")
      liveserver.setup({
        custom = {
          "--port=8080",
          "--no-css-inject",
        },
        serverPath = vim.fn.stdpath("data") .. "/live-server/", --default
        open = "folder",                                 -- folder|cwd     --default
      })
    end
  },
}
