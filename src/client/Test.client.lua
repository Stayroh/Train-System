local Knit = require(game.ReplicatedStorage.Packages.knit)

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

wait(2)

local People = { "Stayroh", "Hycarius", "Marek", "Timmy" }

local KillBoard = Knit.GetController("KillBoard")

for i = 1, 10 do
	local Player1, Player2 = People[math.random(1, #People)], People[math.random(1, #People)]
	KillBoard:NewKill(Player1, Player2)
	task.wait(math.random(1, 100) / 100)
end
