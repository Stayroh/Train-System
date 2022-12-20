local SwitchModule = {}

type SwitchType = {
	Pre: {
		Visual: number,
		Individ: { [number]: number? },
	},
	Fol: {
		Visual: number,
		Individ: { [number]: number? },
	},
}

type SwitchNetType = { [number]: SwitchType }
type SwitchesType = { [number]: SwitchNetType }

type BroadcastElement = {
	Network: number,
	Node: number,
	State: SwitchType,
}
type Broadcast = { [number]: BroadcastElement }

local Switches: SwitchesType = {}

function SwitchModule.ApplyChanges(ChangeBroadcast: Broadcast)
	if not ChangeBroadcast then
		return
	end
	for _, Element: BroadcastElement in pairs(ChangeBroadcast) do
		local Network = Element.Network
		if Switches[Network] == nil then
			Switches[Network] = {}
		end
		Switches[Network][Element.Node] = Element.State
	end
end

function SwitchModule.ClearAllSwitches()
	Switches = {}
end

function SwitchModule.ApplySwitches(NewStates: SwitchesType)
	Switches = NewStates
end

function SwitchModule.GetNextNode(NodeId: number, Direction: boolean, TrainId: number, Network: number)
	if not (Switches[Network] and Switches[Network][NodeId]) then
		return
	end
	local Switch: SwitchType = Switches[Network][NodeId]
	local SwitchSide = Switch[Direction and "Fol" or "Pre"]
	if SwitchSide.Individ and SwitchSide.Individ[TrainId] then
		return SwitchSide.Individ[TrainId]
	end
	return SwitchSide.Visual
end

return table.freeze(SwitchModule)
