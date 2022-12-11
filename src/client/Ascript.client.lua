if not game:IsLoaded() then
	game.Loaded:Wait()
end
local Test = require(game.ReplicatedStorage.source.Test)

game:GetService("RunService").Heartbeat:Connect(function()
	Test.Delta()
end)

print("Kek")
