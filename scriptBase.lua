local HttpService = game:GetService("HttpService")

export type Config = {
    title: string?;
    tabs: {string}?;
    toggles: {[string]: {tab: string, default: boolean}?};
    sliders: {[string]: {tab: string, min: number, max: number, default: number}?};
    [string]: any;
}

local scriptBase = {}
scriptBase.__index = scriptBase

-- Decode JSON safely
local function decodeConfig(body: string): Config
    local decoded = HttpService:JSONDecode(body)
    assert(type(decoded) == "table", "Config must be a JSON object")
    return decoded
end

-- Register a task
function scriptBase:addTask(task: RBXScriptConnection)
    if task and task.Connected then
        table.insert(self.tasks, task)
    end
    return task
end

-- Load config from URL
function scriptBase:loadConfig(url: string)
    local ok, body = pcall(function()
        return HttpService:GetAsync(url)
    end)

    assert(ok, "Failed to fetch config")

    local decodeOk, config = pcall(decodeConfig, body)
    assert(decodeOk, "Invalid config JSON")

    self.config = config
    self.tabs = config.tabs or {}
    self.toggles = config.toggles or {}
    self.sliders = config.sliders or {}

    return config
end

-- Load config based on placeId
function scriptBase:loadGameConfig(baseUrl: string, placeId: number)
    local url = string.format("%s/%d.json", baseUrl, placeId)
    return self:loadConfig(url)
end

return scriptBase
