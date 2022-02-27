#! /usr/bin/env lua

-- TO DO: DO NOT FORGET TO WRITE THE FUNCTION "getDesktopEnvironment"

function getOSName()
    
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
    
    local handle = io.popen("uname -r")
    local kernelVersion = handle:read()
    handle:close()
    return kernelVersion
end

function getUptime()
    
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
    
    local shell 
    local handle = io.popen("echo $SHELL")
    shell = handle:read()
    handle:close()
    return shell
end


function getWindowManager()
    -- This function has some problems that I couldn't resolve yet
    -- and needs to be tested on different distributions
    -- not completely ready for the release.
    local wmName 
    local handle = io.popen("wmctrl -m")
    
    for line in handle:lines() do
        if (not (string.find(line,"Name:") == nil)) then
            -- 6 is the index that the name of WM starts.
            wmName = string.sub(line,6,string.len(line))
        end
    end
    handle:close()
    return wmName
end

function getCPU()
    
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
