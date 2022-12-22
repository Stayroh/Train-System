local Types = {}

export type NodeType = {
	Position: Vector3,
	Tangent: Vector3,
	UpVector: Vector3,
	Pre: number | { [number]: number } | nil,
	Fol: number | { [number]: number } | nil,
}

export type NetworkType = { [number]: NodeType }

export type SwitchType = {
	Pre: {
		Visual: number,
		Individ: { [number]: number? },
	},
	Fol: {
		Visual: number,
		Individ: { [number]: number? },
	},
}

export type SwitchNetType = { [number]: SwitchType }
export type SwitchesType = { [number]: SwitchNetType }

export type BroadcastElementType = {
	Network: number,
	Node: number,
	State: SwitchType,
}
export type BroadcastType = { [number]: BroadcastElementType }

return Types
