local HttpService = game:GetService("HttpService")

--local scriptBase = loadstring(game:HttpGet("https://raw.githubusercontent.com/fortniteblokecomp-cyber/thunder/main/scriptBase.lua"))()

local thunder = {}
thunder.__index = thunder

local bin = {
    luna = nil,
    interface = nil
}

-- Private
const function loadConfig(url: string)
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

-- Constructor
function thunder.new()
    local self = setmetatable({}, thunder)

    self.dataBase = {}
    self.tasks = {}
    self.tabs = {}
    self.config = {}


	warn(self)

    return self
end


function thunder:mount()
    bin.luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna"))()
end

-- Render UI
function thunder:render()
	warn("yoooooooooooooooooooooo")
    local luna = bin.luna
    assert(luna, "Luna UI library not loaded")

    bin.interface = luna:CreateWindow({
        Name = self.config.title or "Thunder"
    })

    for _, tabName in ipairs(self.tabs) do
        self.tabs[tabName] = bin.interface:CreateTab(tabName)
    end

   
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


function thunder:loadGameConfig(baseUrl: string, placeId: number)
    local url = string.format("%s/%d.json", baseUrl, placeId)
    return loadConfig(url)
end


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
