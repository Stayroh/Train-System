if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.src.Controllers
local Knit = require(ReplicatedStorage.Packages.knit)

--Knit.AddControllers(Controllers)

Knit:Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
