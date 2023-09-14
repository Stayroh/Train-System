if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local src = ReplicatedStorage.src
local Knit = require(ReplicatedStorage.Packages.knit)

local Controllers = {
	src.TrainCtrl,
}

for _, v in pairs(Controllers) do
	require(v)
end

Knit:Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
