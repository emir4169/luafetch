local io = require "io"
local math = require "math"
local os = require "os"
local function read_first_line(filepath)
    local file = io.open(filepath, "r")
    if file then
        local line = file:read("*l")
        file:close()
        return line
    end
    return nil
end
local function read_memory_info()
    local mem_total = read_first_line("/proc/meminfo"):match("MemTotal:%s+(%d+)")
    if mem_total then
        local kb = tonumber(mem_total)
        local mb = kb / 1024
        local gb = mb / 1024
        return string.format("%d GB ( %d MB )", math.ceil(gb), math.ceil(mb))
    end
    return "Couldn't fetch MemTotal from /proc/meminfo"
end
local function gupt()
    local uptime_seconds = read_first_line("/proc/uptime"):match("^(%d+)")
    if uptime_seconds then
        local str = ""
        local seconds = tonumber(uptime_seconds)
        local days = math.floor(seconds / 86400)
        local hours = math.floor((seconds % 86400) / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local rsec = math.floor((seconds % 60))
        if days ~= 0 then str = string.format("%d days, ", days) end
        if hours ~= 0 then str = str..string.format("%d hours, ", hours) end
        if minutes ~= 0 then str = str..string.format("%d minutes, ", minutes) end
        if rsec ~= 0 then str = str..string.format("%d seconds", rsec) end
        return str or "0"
        --return string.format("%d days, %d hours, %d minutes, %d seconds", days, hours, minutes,rsec)
    end
    return "Couldnt detect uptime"
end

-- Function to repeat a string a given number of times
local function repeat_string_times(str, times)
    return string.rep(str, times)
end

-- Function to left pad a string with spaces
local function leftpad(str, spaces)
    return repeat_string_times(" ", spaces) .. str
end

-- Get system information
local user = os.getenv("USER") or "user"
local hostname = read_first_line("/proc/sys/kernel/hostname") or "hostname"
local colored_hostname = "\x1b[1;36m" .. hostname .. "\x1b[1;00m"
local os_name = (read_first_line("/etc/os-release") or "NAME=\"no-osrelease\""):match('NAME="([^"]+)"') or "couldntmatchfirstline"
local kernel = read_first_line("/proc/sys/kernel/osrelease") or "couldnt detect"
local uptime = gupt()
local shell = string.match(os.getenv("SHELL") or "", "([^/]+)$") or "couldnt detect"
local terminal = os.getenv("TERM") or "unknown"
local memory_info = read_memory_info()

local colored_user = user
if user == "root" then
    colored_user = "\x1b[1;31m" .. user .. "\x1b[1;39m"
else
    colored_user = "\x1b[1;32m" .. user .. "\x1b[1;39m"
end
--os_name = "Archcraft"
local userathost = user .. "@" .. hostname
local colored_userathost = colored_user .. "@" .. colored_hostname
if os_name == "Arch Linux" then
    logo = {
        "\x1b[36m       /\\      \x1b[39m",
        "\x1b[36m      /  \\     \x1b[39m",
        "\x1b[36m     /\\   \\     \x1b[39m",
        "\x1b[36m    /      \\    \x1b[39m",
        "\x1b[36m   /        \\   \x1b[39m",
        "\x1b[36m  /    __    \\  \x1b[39m",
        "\x1b[36m /    |  |   /\\ \x1b[39m",
        "\x1b[36m/__--'    '--__\\\x1b[39m"
    } 
elseif os_name == "Archcraft" then
logo = {
    "\x1b[38;5;43m       /\\      \x1b[39m",
    "\x1b[38;5;42m      /  \\     \x1b[39m",
    "\x1b[38;5;41m     /\\   \\    \x1b[39m",
    "\x1b[38;5;40m    /  \x1b[33m()\x1b[38;5;40m  \\   \x1b[39m",
    "\x1b[38;5;39m   /        \\   \x1b[39m",
    "\x1b[38;5;38m  /    __    \\  \x1b[39m",
    "\x1b[38;5;37m /    |  |   /\\ \x1b[39m",
    "\x1b[38;5;36m/__--'    '--__\\\x1b[39m"
}
elseif os_name == "couldntmatchfirstline" or os_name == "no-osrelease" then
    logo = {
        "\x1b[38;5;196m    .---.      \x1b[39m",
        "\x1b[38;5;196m   |     |     \x1b[39m",
        "\x1b[38;5;196m   .     |     \x1b[39m",
        "\x1b[38;5;196m        /      \x1b[39m",
        "\x1b[38;5;196m       /       \x1b[39m",
        "\x1b[38;5;196m      |        \x1b[39m",
        "\x1b[38;5;196m      .        \x1b[39m"

    }
end
-- Prepare the system information lines
local sys_info = {
    colored_userathost,
    repeat_string_times("-", #userathost),
    "OS: " .. os_name,
    "Kernel: " .. kernel,
    "Uptime: " .. uptime,
    "Shell: " .. shell,
    "Terminal: " .. terminal,
    "Total Memory: " .. memory_info
}

-- Determine the maximum number of lines
local max_lines = math.max(#logo, #sys_info)

-- Print the logo and system information side by side
for i = 1, max_lines do
    io.write("\x1b[1m")
    local logo_line = logo[i] or ""
    local info_line = sys_info[i] or ""
    print(string.format("%-20s %s", logo_line, info_line))
end
