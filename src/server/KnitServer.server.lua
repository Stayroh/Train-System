local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local source = ServerScriptService.source

local Knit = require(ReplicatedStorage.Packages.knit)

local Services = {
	source.TrainService,
}

for _, v in pairs(Services) do
	require(v)
end

Knit:Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
