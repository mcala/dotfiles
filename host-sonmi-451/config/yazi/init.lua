require("full-border"):setup()
--require("git"):setup()
--require("dual-pane"):setup()
--
function Linemode:size_and_mtime()
    local time = math.floor(self._file.cha.modified or 0)
    if time == 0 then
        time = ""
    elseif os.date("%Y", time) == os.date("%Y") then
        time = os.date("%Y-%m-%d %H:%M", time)
    else
        time = os.date("%Y-%m-%d", time)
    end

    local size = self._file:size()
    return ui.Line(string.format("%s %s", size and ya.readable_size(size) or "-", time))
end
