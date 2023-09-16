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

function KillBoard:Create()
	local Elements = { Roact.createElement("UIListLayout", { Padding = UDim.new(0, 5) }) }
	local Gradient = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1, 0), NumberSequenceKeypoint.new(1, 0, 0) })
	local Width = self.Size.X
	for i, v in next, self.State do
		local Content = string.format("%s killed %s", v.Player1, v.Player2)
		local Element = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			Size = UDim2.fromOffset(Width, self.ElemenHight),
			LayoutOrder = i,
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
		table.insert(Elements, Element)
	end

	local UI = Roact.createElement("ScreenGui", { IgnoreGuiInset = true, ResetOnSpawn = false }, {
		Frame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -5, 0, 5),
			Size = UDim2.fromOffset(self.Size.X, self.Size.Y),
		}, Elements),
	})
	return UI
end

function KillBoard:NewKill(Player1: string, Player2: string)
	local Element = {
		Player1 = Player1,
		Player2 = Player2,
	}
	Element.Thread = task.delay(self.Duration, function()
		local i = table.find(self.State, Element)
		if i then
			local NewState = {}
			for i = 2, #self.State do
				NewState[i - 1] = self.State[i]
			end
			self.State = NewState
			self.Handle = Roact.update(self.Handle, self:Create())
		end
	end)
	local NewState = {}
	local Offset = math.max(0, #self.State - self.MaxKills + 1)
	for i, v in next, self.State do
		if i > Offset then
			NewState[i - Offset] = v
		else
			coroutine.close(v.Thread)
		end
	end
	NewState[#NewState + 1] = Element
	self.State = NewState
	self.Handle = Roact.update(self.Handle, self:Create())
end

function KillBoard:KnitInit()
	self.MaxKills = math.floor((self.Size.Y + 5) / (self.ElemenHight + 5))
end

function KillBoard:KnitStart()
	self.Handle = Roact.mount(self:Create(), Player.PlayerGui)
end

return KillBoard
