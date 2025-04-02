local WhitelistManager = {}

local whitelist_url = "https://raw.githubusercontent.com/wrealaero/whitelistcheck/refs/heads/main/newwhitlist.json"

function WhitelistManager:fetchWhitelist()
    local HttpService = game:GetService("HttpService")

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

function WhitelistManager:isWhitelisted(userId)
    local whitelist = self:fetchWhitelist()

    if not whitelist or not whitelist[userId] then
        return false, nil
    end
    
    local userEntry = whitelist[userId]
    
    if type(userEntry) == "table" then
        if userEntry.banned then
            return false, nil
        end
        
        return true, userEntry.tier or "default"
    else
        return true, "default"
    end
end

return WhitelistManager
