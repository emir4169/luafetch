local function read_first_line(filepath)
    local file = io.open(filepath, "r")
    if file then
        local line = file:read("*l")
        file:close()
        return line
    end
    return nil
end

local function gupt()
    local uptime_seconds = read_first_line("/proc/uptime"):match("^(%d+)")
    if uptime_seconds then
        local seconds = tonumber(uptime_seconds)
        local days = math.floor(seconds / 86400)
        local hours = math.floor((seconds % 86400) / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        return string.format("%d days, %d hours, %d minutes", days, hours, minutes)
    end
    return "Couldnt detect uptime"
end

-- Function to repeat a string a given number of times
local function repeat_string_times(str, times)
    return string.rep(str, times)
end

-- Function to left pad a string with spaces
local function leftpad(str, spaces)
    return string.rep(" ", spaces) .. str
end

-- Get system information
local user = os.getenv("USER") or "user"
local hostname = read_first_line("/proc/sys/kernel/hostname") or "hostname"
local colored_hostname = "\x1b[1;36m" .. hostname .. "\x1b[1;00m"
local os_name = (read_first_line("/etc/os-release") or "NAME=\"UNKNOWN LINUX\""):match('NAME="([^"]+)"') or "Unknown Linux"
local kernel = read_first_line("/proc/sys/kernel/osrelease") or "couldnt detect"
local uptime = gupt()
local shell = string.match(os.getenv("SHELL") or "", "([^/]+)$") or "couldnt detect"
local terminal = os.getenv("TERM") or "unknown"

local colored_user = user
if user == "root" then
    colored_user = "\x1b[1;31m" .. user .. "\x1b[1;39m"
else
    colored_user = "\x1b[1;32m" .. user .. "\x1b[1;39m"
end

local userathost = user .. "@" .. hostname
local colored_userathost = colored_user .. "@" .. colored_hostname

if os_name == "Arch Linux" then
    logo = {
        "\x1b[36m       /\\      \x1b[39m",
        "\x1b[36m      /  \\     \x1b[39m",
        "\x1b[36m     /\\   \\    \x1b[39m",
        "\x1b[36m    /      \\   \x1b[39m",
        "\x1b[36m   /   __   \\  \x1b[39m",
        "\x1b[36m  /   |  |  -\\ \x1b[39m",
        "\x1b[36m /_--'    '--_\\\x1b[39m"
    } 
else
    logo = {
        "\x1b[38;5;214m     .--.      \x1b[39m",
        "\x1b[38;5;214m    |o_o |     \x1b[39m",
        "\x1b[38;5;214m    |    |     \x1b[39m",
        "\x1b[38;5;214m   //   \\ \\    \x1b[39m",
        "\x1b[38;5;214m  (|     | )   \x1b[39m",
        "\x1b[38;5;214m /'\\_   _/`\\   \x1b[39m",
        "\x1b[38;5;214m \\___)=(___/   \x1b[39m"
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
    "Terminal: " .. terminal
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