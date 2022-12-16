local NF = script
type Net_Type = {
	[number]: any,
}

local Networks: Net_Type = {
	[1] = NF.NetworkAlpha,
}

local Module = {}

for i, v in pairs(Networks) do
	Module[i] = require(v)
end

return Module
