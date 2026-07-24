-- Services

local HttpService = game:GetService("HttpService")



-----------------------------------------------------

local scriptBase = loadstring(game:HttpGet("https://github.com/fortniteblokecomp-cyber/thunder/blob/main/scriptBase.lua", true))()
warn(scriptBase)

-------------------------------------------------------


local thunder = setmetatable({}, {__index = scriptBase})


local bin = {
	lunaGit = nil;
}



function thunder.new()
	local self = setmetatable({}, {__index = thunder});
	
	self.dataBase = {};
	
	self.toggles = {};
	self.sliders = {};
	
	self.tasks = {} :: {RBXScriptConnection}
	
	self.tabs = {}
	self.config = {}
	
	return self 
end




function thunder:mount()
	bin.lunaGit = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()
end

function thunder:render()
	local git = bin.lunaGit
	
	warn(git)
	self:addTask(self, task.spawn(function()
		bin["interface"] = git:CreateWindow({
			Name = "thunder"
		})
	end))

end;


function scriptBase:loadGameConfig(configBaseUrl: string, placeId: number)
	const configUrl = `{configBaseUrl}/{placeId}.json`;

	return self:loadConfig(configUrl)
end

function thunder:cleanup()
	for _, task in self.tasks do
		task:Disconnect()
	end
	
	table.clear(self.tasks)
	table.clear(self.bin)
	return setmetatable(self, nil)
end

return thunder;