local Chassis = {}
Chassis.__index = Chassis

function Chassis:Update(Joint0: Vector3, Joint1: Vector3, DeltaTime: number): CFrame end

local Cons = {}
function Cons.new()
	local self = setmetatable({}, Chassis)

	return self
end

return Cons
