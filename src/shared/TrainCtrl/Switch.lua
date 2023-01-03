local SwitchModule = {}
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)

local SwitchNetworks = {} --Array of networks where switchs are stored for this network
SwitchNetworks.__index = function(_, index)
	SwitchNetworks[index] = {}
end

function SwitchModule:Update(Update: Types.SwitchUpdateType)
	if not Update then
		return
	end
	for Network, SwitchUpdates: Types.NetworkSwitches in pairs(Update) do
		if type(SwitchUpdates) ~= "table" then
			SwitchNetworks[Network] = nil
			continue
		end
		for Node, SwitchState: Types.SwitchType in pairs(SwitchUpdates) do
			if type(SwitchState) ~= "table" then
				SwitchNetworks[Network][Node] = nil
				continue
			end
			SwitchNetworks[Network][Node] = SwitchState
		end
	end
end

function SwitchModule:GetSwitchConnection(NodeId: number, Direction: boolean, TrainId: number, Network: number)
	if not (SwitchNetworks[Network] and SwitchNetworks[Network][NodeId]) then
		return
	end
	local Switch: Types.SwitchType = SwitchNetworks[Network][NodeId]
	local SwitchSide = Switch[Direction and "Fol" or "Pre"]
	if TrainId and SwitchSide.Individ and SwitchSide.Individ[TrainId] then
		return SwitchSide.Individ[TrainId]
	end
	return SwitchSide.Visual
end

return SwitchModule
