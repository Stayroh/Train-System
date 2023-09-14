local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local Player = game:GetService("Players").LocalPlayer

local UIController = Knit.CreateController({ Name = "UIController" })

function UIController:KnitInit() end

function UIController:KnitStart()
	local UI = Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true,
	}, {
		Roact.createElement("TextLabel", {
			Text = "Hey?",
			Size = UDim2.new(0, 300, 0, 100),
		}),
	})
	self.Handler = Roact.mount(UI, Player.PlayerGui)
end

return UIController
