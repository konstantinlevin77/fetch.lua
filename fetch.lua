#! /usr/bin/env lua

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



