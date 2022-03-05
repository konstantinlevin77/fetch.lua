#! /usr/bin/env lua

-- TO DO: DO NOT FORGET TO WRITE THE FUNCTION "getGPU" using lspci.



function getOSName()
    --[[
    This function returns the pretty name of distribution by processing
    the /etc/os-release file which consists of the information about the
    distribution.
    --]]
    
    local OSName
    local f = io.open("/etc/os-release","r")

    for line in f:lines() do
        if (not (string.find(line,"PRETTY_NAME") == nil)) then
            -- 13 is the index of the char which is at the start
            -- of the name of operating system.
            OSName = string.sub(line,14,string.len(line)-1)
        end 
    end    
    f:close()
    return OSName
end

function getKernelVersion()
    
    --[[
    This function returns the kernel version by processing the 
    output of "uname" utility.
    --]]
    
    local handle = io.popen("uname -r")
    local kernelVersion = handle:read()
    handle:close()
    return kernelVersion
end

function getUptime()
    
    --[[
    This function returns the uptime by processing the output
    of "uptime" utility.
    --]]
    
    local uptime 
    
    local handle = io.popen("uptime")
    local handleResult = handle:read()
    handle:close()
    
    -- I've added +2 because string.find() returns the index that
    -- the search string starts.
    local startIndex = string.find(handleResult,"up")+2
    local endIndex = string.find(handleResult,",")-1
    
    uptime = string.sub(handleResult,startIndex,endIndex)
    
    -- this regular expression trims the string given.
    uptime = string.gsub(uptime, "^%s*(.-)%s*$", "%1")
    return uptime    
end

function getShell()
    
    --[[
    This function returns the current shell's name by processing
    the value of "$SHELL" environment variable which is mostly
    declared in Linux systems.
    --]]
    
    local shell 
    local handle = io.popen("echo $SHELL")
    shell = handle:read()
    handle:close()
    return shell
end

function getDesktopEnvironment()
    
    --[[ 
    This function returns the current desktop environment.
    For the very first release, I've decided to use XDG_CURRENT_DESKTOP
    environment variable which is accesible only on Xorg based systems.
    
    I'll figure out a better way which will work both on Wayland and Xorg
    PR's are welcomed.
    --]]
    
    local desktopEnvironment 
    local handle = io.popen("echo $XDG_CURRENT_DESKTOP")
    desktopEnvironment = handle:read()
    handle:close()
    return desktopEnvironment
    
end


function getWindowManager()
    --[[
    This function returns the name of window manager. This function
    uses "wmctrl" which is used to manage Xorg window managers and therefore
    just as the previous function it's going to be working only on Xorg based
    systems. I'm going to figure out a better way soon.
    --]]
    
    local wmName 
    -- I had to redirect stderr onto null device cause I had an 
    -- error whenever I've used the utility on different distros.
    local handle = io.popen("wmctrl -m 2> /dev/null")
    
    for line in handle:lines() do
        if (not (string.find(line,"Name:") == nil)) then
            -- 7 is the index that the name of WM starts.
            wmName = string.sub(line,7,string.len(line))
        end
    end
    handle:close()
    return wmName
end

function getCPU()
    
    --[[
    This function returns the name of CPU by processing the "/proc/cpuinfo"
    file which consists of the information about the CPU.
    --]]
    
    local CPUName
    local handle = io.popen("cat /proc/cpuinfo")
    for line in handle:lines() do
        if (not (string.find(line,"model name") == nil)) then
            -- 14 is the index that the name of CPU starts
            CPUName = string.sub(line,14,string.len(line))
            --[[
            I've used a break here, cause the /proc/cpuinfo file has the same entry more than one, so there's no need to iterate over all of them.
            ]]--
            break
        end
    end
    return CPUName
end


function getRamValues()
    
    --[[
    Returns the first line of the output of "free" utility as splitted by spaces. This function is later used by getUsedRam() and getTotalRam()
    functions to gather information about ram.
    --]]
    
    local handle = io.popen("free -m | grep Mem -C0 | cat")
    local result = handle:read()
    handle:close()
    
    local values = string.gmatch(result,"%S+")
    -- This simple regex pattern splits strings by spaces.
    -- The first value of the table is the "Mem:" itself, please
    -- refer to "free" manpage for the detailed information.
    return values
end


function getUsedRam()
    
    --[[
    This function returns the used ram in MiBs by using
    the previously defined function getRamValues()
    --]]
    
    local vals = getRamValues()
    local counter = 1
    local usedRam
    
    for val in vals do
        -- The first value will be an irrelevant string
        -- Second will be the total ram
        -- Third will be the ram used.
        if (counter == 3) then
            usedRam = "" .. val .. " MiB"
            return usedRam
        end
        counter = counter + 1
    end
end


function getTotalRam()
    
    --[[
    This function returns the total ram in MiBs by using
    the previously defined function getRamValues()
    --]]
    
    local vals = getRamValues()
    local counter = 1
    local totalRam 
    
    for val in vals do
        -- The first value will be an irrelevant string
        -- Second will be the total ram.
        if (counter == 2) then
            totalRam = "" .. val .. " MiB"
            return totalRam
        end
        counter = counter + 1
    end
    
end

function isUserOnGUI()
    --[[
    This function returns whether the user is on GUI or not.
    This is determined with the environment variable $DISPLAY
    "$DISPLAY" is set on Xorg based systems when there's a GUI running.
    
    --]]
    
    local handle = io.popen("echo $DISPLAY")
    local val = handle:read()
    handle:close()
    return #val > 0
    
end

function displayFetchResults()
    --[[
    This function displays the gathered information in a pretty format.
    Basically, this function is the frontend of the script.
    Config file is read here, and also an ANSI library is used to change
    the color of the text.
    
    credit: https://luarocks.org/modules/smi11/eansi
    --]]
    
    local config = require "fetch.config"
    local eansi = require "eansi"
    local color = eansi.toansi "bold bright_green"

    
    if (config.titles.OSTitle) then
    print(color .. "OS: " .. eansi "" .. getOSName()) 
    end
    
    if (config.titles.kernelVersion) then
    print(color .. "Kernel: " .. eansi "" .. getKernelVersion())
    end 
    
    if (config.titles.uptime) then
    print(color .. "Uptime: " .. eansi "" .. getUptime())
    end
    
    if (config.titles.shell) then
    print(color .. "Shell: " .. eansi "" .. getShell())
    end 
    
    if (isUserOnGUI()) then
        
        if (config.titles.desktopEnvironment) then
            print(color .. "DE: " .. eansi "" .. getDesktopEnvironment())
        end
    
        if (config.titles.getWindowManager) then
            print(color .. "WM: " .. eansi "" .. getWindowManager())
        end
        
    end

    if (config.titles.cpu) then
        print(color .. "CPU: " .. eansi "" .. getCPU())
    end
    
    -- There must be the GPU function here
    
    if (config.titles.memory) then
        print(color .. "Memory: " .. eansi "" .. getUsedRam() .. "/" .. getTotalRam())
    end
        
end


displayFetchResults()


