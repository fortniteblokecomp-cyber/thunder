local HttpService = game:GetService("HttpService")

export type Config = {
	title: string?;
	tabs: {any};
	toggles: {[string]: {any}};
	sliders: {[string]: {any}};
	
	[string]: any;
}


const scriptBase = {}

-- Private
const function decodeConfig(body: string) : Config
	local _decoded = HttpService:JSONDecode(body);
	assert(type(_decoded) == "table", "game config must be a json Object");
	
	return _decoded:: string;
end

-- Public

function scriptBase:addTask(base, task: RBXScriptConnection)
	assert(task.Connected, "cannot register and disconnected task");
	
	table.insert(base.tasks, task);
	
	return task;
end

function scriptBase:changeTab(base, newTab)
	
end

function scriptBase:toggle(base, _instance)
	
end

function scriptBase:loadConfig(configBaseUrl: string)
	local ok, bodyOrError = pcall(function()
		return HttpService:GetAsync(configBaseUrl, true);
	end)
	assert(ok, "unable to fetch game config");
	
	local decodeOk, configOrError = pcall(decodeConfig, bodyOrError);
	assert(decodeOk, "invalid to fetch game config");
	
	base.config = configOrError;
	base.tabs = configOrError.tabs or {};
	base.toggles = configOrError.toggles or {};
	base.sliders = configOrError.sliders or {};
	
	return configOrError
end


return scriptBase