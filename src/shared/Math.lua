local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angle: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angle) + GC:Cross(V1) * math.sin(Angle)
end

function Math.GetQuardant(Angle: number): number
	return math.ceil((Angle % (math.pi * 2)) / (math.pi / 2)) + 1
end

function Math.ToUpSpace(V1: Vector3, Direction: Vector3): Vector3
	local D_XHead = Direction.Unit
	local D_ZHead = D_XHead:Cross(Vector3.new(0, 1, 0))
	D_ZHead = D_ZHead == Vector3.zero and Vector3.new(1, 0, 0) or D_ZHead.Unit
	local D_YHead = D_ZHead:Cross(D_XHead)
	local XHead = Vector3.new(0, 1, 0)
	local ZHead = Vector3.new(0, 0, 1)
	local YHead = Vector3.new(-1, 0, 0)
	local D_XHead, D_ZHead, D_YHead =
		Vector3.new(D_XHead.X, D_YHead.X, D_ZHead.X),
		Vector3.new(D_XHead.Y, D_YHead.Y, D_ZHead.Y),
		Vector3.new(D_XHead.Z, D_YHead.Z, D_ZHead.Z)
	local I_XHead = Vector3.new(
		XHead.X * D_XHead.X + YHead.X * D_XHead.Y + ZHead.X * D_XHead.Z,
		XHead.Y * D_XHead.X + YHead.Y * D_XHead.Y + ZHead.Y * D_XHead.Z,
		XHead.Z * D_XHead.X + YHead.Z * D_XHead.Y + ZHead.Z * D_XHead.Z
	)
	local I_YHead = Vector3.new(
		XHead.X * D_YHead.X + YHead.X * D_YHead.Y + ZHead.X * D_YHead.Z,
		XHead.Y * D_YHead.X + YHead.Y * D_YHead.Y + ZHead.Y * D_YHead.Z,
		XHead.Z * D_YHead.X + YHead.Z * D_YHead.Y + ZHead.Z * D_YHead.Z
	)
	local I_ZHead = Vector3.new(
		XHead.X * D_ZHead.X + YHead.X * D_ZHead.Y + ZHead.X * D_ZHead.Z,
		XHead.Y * D_ZHead.X + YHead.Y * D_ZHead.Y + ZHead.Y * D_ZHead.Z,
		XHead.Z * D_ZHead.X + YHead.Z * D_ZHead.Y + ZHead.Z * D_ZHead.Z
	)
	return V1.X * I_XHead + V1.Y * I_YHead + V1.Z * I_ZHead
end

function Math.ArcLatitudeIntersection(V1: Vector3, V2: Vector3, Height: number): number?
	local GC = V1:Cross(V2).Unit
	local a = V1.Y
	local b = GC:Cross(V1).Unit.Y
	local c = Height
	local atan = math.atan2(b, a)
	local ToAcos = c / math.sqrt(a ^ 2 + b ^ 2)
	if ToAcos > 1 or ToAcos < -1 then
		return nil
	end
	local acos = math.acos(ToAcos)
	acos = (atan - acos) % (math.pi * 2) <= (atan + acos) % (math.pi * 2) and acos or -acos
	local Angle = atan - acos
	return Angle
end

function Math.GetTangent(RelativNext: Vector3, Tangent: Vector3): Vector3
	local d = -Tangent
	local Normal = RelativNext.Unit
	return d - 2 * d:Dot(Normal) * Normal
end

function Math.SphereSphereIntersection(
	Sphere1_Pos: Vector3,
	Sphere2_Pos: Vector3,
	Radius1: number,
	Radius2: number
): number
	local d = (Sphere1_Pos - Sphere2_Pos).Magnitude
	return (Radius1 ^ 2 - Radius2 ^ 2 + d ^ 2) / (2 * d)
end

function Math.SphereFromArc(Arc_P1: Vector3, Arc_P2: Vector3, Tangent_V1: Vector3)
	Arc_P2 -= Arc_P1
	local Tangent_V2 = Math.GetTangent(Arc_P2, Tangent_V1)
	local N_V1 = Tangent_V1:Cross(Arc_P2):Cross(Tangent_V1).Unit
	local N_V2 = Tangent_V2:Cross(-Arc_P2):Cross(Tangent_V2).Unit
	local Alpha = math.acos(N_V1:Dot(Arc_P2.Unit))
	local Beta = math.acos(N_V2:Dot(-Arc_P2.Unit))
	local Gamma = math.pi - (Alpha + Beta)
	local d = Arc_P2.Magnitude / math.sin(Gamma) * math.sin(Beta)
	return N_V1 * d + Arc_P1, d
end

function Math.ArcSphereIntersection(
	Arc_P1: Vector3,
	Arc_P2: Vector3,
	Tangent_V1: Vector3,
	Tangent_V2: Vector3,
	Sphere_Pos: Vector3,
	Radius: number
): number
end

return Math
