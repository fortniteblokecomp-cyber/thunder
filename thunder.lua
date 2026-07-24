local HttpService = game:GetService("HttpService")

local thunder = {}
thunder.__index = thunder

local bin = {
    luna = nil,
    interface = nil
}

-- Generic HTTP getter (executor first, then fallback)
local function httpGet(url)
    if syn and syn.request then
        local res = syn.request({Url = url, Method = "GET"})
        return res.Body
    elseif http_request then
        local res = http_request({Url = url, Method = "GET"})
        return res.Body
    elseif request then
        local res = request({Url = url, Method = "GET"})
        return res.Body
    else
        return game:HttpGet(url)
    end
end

-- Decode JSON safely
local function decodeConfig(body)
    local decoded = HttpService:JSONDecode(body)
    assert(type(decoded) == "table", "Invalid JSON config")
    return decoded
end

-- Load config from URL
function thunder:loadConfig(url)
    print("Thunder DEBUG: Fetching URL ->", url)

    local ok, body = pcall(function()
        return httpGet(url)
    end)

    print("Thunder DEBUG: HTTP ok =", ok)
    if not ok then
        warn("Thunder DEBUG: HTTP request failed:", body)
        error("Failed to fetch config")
    end

    local decodeOk, config = pcall(decodeConfig, body)
    print("Thunder DEBUG: decodeOk =", decodeOk)

    if not decodeOk then
        warn("Thunder DEBUG: JSON decode failed:", config)
        error("Invalid config JSON")
    end

    self.config = config
    self.tabs = config.tabs or {}
    self.toggles = config.toggles or {}
    self.sliders = config.sliders or {}

    print("Thunder DEBUG: Config loaded successfully")
    return config
end

-- Load config based on placeId
function thunder:loadGameConfig(baseUrl, placeId)
    print("Thunder DEBUG: loadGameConfig called")
    print("Thunder DEBUG: baseUrl =", baseUrl)
    print("Thunder DEBUG: placeId =", placeId)

    local url = string.format("%s/%d.json", baseUrl, placeId)
    print("Thunder DEBUG: Final URL =", url)

    return self:loadConfig(url)
end

-- Constructor
function thunder.new()
    local self = setmetatable({}, thunder)

    self.dataBase = {}
    self.tasks = {}
    self.tabs = {}
    self.config = {}

    return self
end

-- Load Luna UI Library
function thunder:mount()
    bin.luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna"))()
end

-- Render UI
function thunder:render()
    local luna = bin.luna
    assert(luna, "Luna UI library not loaded")

    bin.interface = luna:CreateWindow({
        Name = self.config.title or "Thunder"
    })

    -- Create tabs
    for _, tabName in ipairs(self.tabs) do
        self.tabs[tabName] = bin.interface:CreateTab(tabName)
    end

    -- Create toggles
    for toggleName, data in pairs(self.toggles) do
        local tab = self.tabs[data.tab]
        if tab then
            tab:CreateToggle({
                Name = toggleName,
                Default = data.default or false,
                Callback = function(state)
                    print(toggleName, state)
                end
            })
        end
    end

    -- Create sliders
    for sliderName, data in pairs(self.sliders) do
        local tab = self.tabs[data.tab]
        if tab then
            tab:CreateSlider({
                Name = sliderName,
                Min = data.min,
                Max = data.max,
                Default = data.default or data.min,
                Callback = function(value)
                    print(sliderName, value)
                end
            })
        end
    end
end

-- Cleanup
function thunder:cleanup()
    for _, task in ipairs(self.tasks) do
        if task.Connected then
            task:Disconnect()
        end
    end

    table.clear(self.tasks)
    table.clear(bin)

    return setmetatable(self, nil)
end

return thunder
