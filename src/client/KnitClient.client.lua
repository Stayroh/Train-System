if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local source = ReplicatedStorage.source
local Knit = require(ReplicatedStorage.Packages.knit)

local Controllers = {
	source.TrainCtrl,
}

for _, v in pairs(Controllers) do
	require(v)
end

Knit:Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
