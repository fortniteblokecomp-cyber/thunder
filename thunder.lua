local HttpService = game:GetService("HttpService")

local thunder = {}
thunder.__index = thunder

local bin = {
    luna = nil,
    interface = nil
}

-- Executor-friendly HTTP
local function httpGet(url)
    if syn and syn.request then
        return syn.request({Url = url, Method = "GET"}).Body
    elseif http_request then
        return http_request({Url = url, Method = "GET"}).Body
    elseif request then
        return request({Url = url, Method = "GET"}).Body
    else
        return game:HttpGet(url)
    end
end

-- Decode JSON safely
local function decodeConfig(body)
    return HttpService:JSONDecode(body)
end

-- Load config from URL
function thunder:loadConfig(url)
    print("Thunder DEBUG: Fetching URL ->", url)

    local ok, body = pcall(function()
        return httpGet(url)
    end)

    if not ok then
        warn("Thunder DEBUG: HTTP failed:", body)
        error("Failed to fetch config")
    end

    local decodeOk, config = pcall(decodeConfig, body)
    if not decodeOk then
        warn("Thunder DEBUG: JSON decode failed:", config)
        error("Invalid config JSON")
    end

    self.config = config
    self.window = config.window or {}
    self.tabs = config.tabs or {}
    self.toggles = config.toggles or {}
    self.sliders = config.sliders or {}

    print("Thunder DEBUG: Config loaded successfully")
    return config
end

-- Load config based on placeId
function thunder:loadGameConfig(baseUrl, placeId)
    local url = string.format("%s/%d.json", baseUrl, placeId)
    return self:loadConfig(url)
end

-- Constructor
function thunder.new()
    local self = setmetatable({}, thunder)
    self.config = {}
    self.window = {}
    self.tabs = {}
    self.toggles = {}
    self.sliders = {}
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

    -- Create window using full Luna config
    bin.interface = luna:CreateWindow(self.window)

    -- Create tabs (NEW LUNA API)
    for _, tabName in ipairs(self.tabs) do
        self.tabs[tabName] = bin.interface:CreateTab({
            Name = tabName,
            Icon = "view_in_ar",
            ImageSource = "Material",
            ShowTitle = true
        })
    end

    -- Create toggles (NEW LUNA API)
    for toggleName, data in pairs(self.toggles) do
        local tab = self.tabs[data.tab]
        if tab then
            tab:CreateToggle({
                Name = toggleName,
                CurrentValue = data.default or false
            }, toggleName)
        end
    end

    -- Create sliders (NEW LUNA API)
    for sliderName, data in pairs(self.sliders) do
        local tab = self.tabs[data.tab]
        if tab then
            tab:CreateSlider({
                Name = sliderName,
                Range = {data.min, data.max},
                Increment = 1,
                CurrentValue = data.default or data.min
            }, sliderName)
        end
    end
end

return thunder
