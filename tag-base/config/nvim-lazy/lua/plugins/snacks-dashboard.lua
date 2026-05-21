return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = (function()
          -- Render the hostname as an ANSI Shadow figlet banner. Override
          -- the displayed name with $DASHBOARD_HOSTNAME (useful when the
          -- system hostname is ugly, e.g. ubuntu-2gb-nyc1-01).
          local name = (os.getenv("DASHBOARD_HOSTNAME") or vim.fn.hostname()):upper()
          local font_dir = vim.fn.stdpath("config") .. "/figlet-fonts"
          local lines = vim.fn.systemlist({ "figlet", "-d", font_dir, "-f", "ansi-shadow", name })
          if vim.v.shell_error == 0 and #lines > 0 then
            return "\n   " .. table.concat(lines, "\n   ") .. "\n "
          end
          return "\n   " .. name .. "\n "
        end)(),
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
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1, limit = 8 },
        {
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          indent = 2,
          padding = 1,
          limit = 8,
        },
      },
    },
  },
}
