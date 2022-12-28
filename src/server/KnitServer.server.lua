print("a")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local source = ServerStorage.source
local Knit = require(ReplicatedStorage.Packages.knit)

local Services = {
	source.TestService,
}

for _, v in pairs(Services) do
	require(v)
end
print("b")
Knit:Start()
	:andThen(function()
		print("Knit started")
	end)
	:catch(warn)
