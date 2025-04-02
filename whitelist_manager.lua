local WhitelistManager = {}

-- Configuration - Your whitelist URL
local whitelist_url = "https://raw.githubusercontent.com/wrealaero/whitelistcheck/refs/heads/main/newwhitlist.json"

-- Fetch whitelist from GitHub
function WhitelistManager:fetchWhitelist()
    local HttpService = game:GetService("HttpService")
    
    -- Try to get the whitelist with retries
    local retries = 3
    local success, response
    
    while retries > 0 do
        success, response = pcall(function()
            return game:HttpGet(whitelist_url)
        end)
        
        if success and response then
            local successDecode, whitelist = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if successDecode and whitelist then
                return whitelist
            end
        end
        
        retries = retries - 1
        wait(1)  -- wait before retrying
    end
    
    -- Return empty whitelist if failed
    return {}
end

-- Check if a user is whitelisted
function WhitelistManager:isWhitelisted(userId)
    local whitelist = self:fetchWhitelist()
    
    -- Basic check - is the UserID in the whitelist?
    if not whitelist or not whitelist[userId] then
        return false, nil
    end
    
    local userEntry = whitelist[userId]
    
    -- Check if it's a table (new format) or string (old format)
    if type(userEntry) == "table" then
        -- Check if banned
        if userEntry.banned then
            return false, nil
        end
        
        -- Return user tier
        return true, userEntry.tier or "default"
    else
        -- Old format - just a string or boolean
        return true, "default"
    end
end

return WhitelistManager
