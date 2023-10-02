local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local Roact = require(ReplicatedStorage.Packages.roact)
local Player = game:GetService("Players").LocalPlayer

local KillBoard = Knit.CreateController({
	Name = "KillBoard",
	State = {},
	Size = Vector2.new(250, 300),
	ElemenHight = 40,
	MaxKills = 2,
	Duration = 5,
})

local Gradient = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1, 0), NumberSequenceKeypoint.new(1, 0, 0) })

local Message = Roact.PureComponent:extend("Message")

function Message:init(Properties)
	assert(Properties.Content, "No content has been provided.")
	self:setState({
		Content = Properties.Content,
	})
end

function Message:render()
	local Content = self.state.Content
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(15, 15, 15),
		Size = UDim2.fromOffset(Width, self.ElemenHight),
		BackgroundTransparency = 0.5,
	}, {
		Roact.createElement("UIGradient", { Transparency = Gradient }),
		Roact.createElement("TextLabel", {
			TextScaled = true,
			FontFace = Font.fromEnum(Enum.Font.GothamBold),
			TextColor3 = Color3.new(1, 1, 1),
			Position = UDim2.fromOffset(5, 5),
			Size = UDim2.fromOffset(Width - 10, self.ElemenHight - 10),
			Text = Content,
			BackgroundTransparency = 1,
		}),
	})
end

function KillBoard:NewKill(Player1: string, Player2: string) end

function KillBoard:KnitInit() end

function KillBoard:KnitStart() end

return KillBoard
