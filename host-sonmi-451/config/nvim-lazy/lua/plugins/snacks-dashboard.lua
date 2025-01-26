return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
   ███████╗ ██████╗ ███╗   ██╗███╗   ███╗██╗      ██╗  ██╗███████╗ ██╗
   ██╔════╝██╔═══██╗████╗  ██║████╗ ████║██║      ██║  ██║██╔════╝███║
   ███████╗██║   ██║██╔██╗ ██║██╔████╔██║██║█████╗███████║███████╗╚██║
   ╚════██║██║   ██║██║╚██╗██║██║╚██╔╝██║██║╚════╝╚════██║╚════██║ ██║
   ███████║╚██████╔╝██║ ╚████║██║ ╚═╝ ██║██║           ██║███████║ ██║
   ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝           ╚═╝╚══════╝ ╚═╝
 ]],
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header", padding = 2 },
        { section = "startup", padding = 1 },
        { section = "keys", padding = 1, gap = 0.0 },
        { pane = 1, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1, limit = 8 },
        {
          pane = 1,
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          indent = 2,
          padding = 1,
          limit = 8,
        },
        {
          pane = 2,
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "onefetch --no-art --no-title -d languages -d churn -d size -d version -d url -t 0 0 0 12 12 6",
          padding = 1,
          ttl = 10 * 60,
        },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
      },
    },
  },
}
