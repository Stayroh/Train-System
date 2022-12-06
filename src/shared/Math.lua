local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angle: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angle) + GC:Cross(V1) * math.sin(Angle)
end

function Math.GetQuardant(Angle: number): number
	return math.ceil((Angle % (math.pi * 2)) / (math.pi / 2)) + 1
end

function Math.ToUpSpace(V1: Vector3, V2: Vector3, Direction: Vector3)
	local D_XHead = Direction.Unit
	local D_ZHead = D_XHead:Cross(Vector3.new(0, 1, 0))
	D_ZHead = D_ZHead == Vector3.zero and Vector3.new(1, 0, 0) or D_ZHead.Unit
	local D_YHead = D_ZHead:Cross(D_XHead)
	print("-----------------------------")
	print(D_XHead.X, D_YHead.X, D_ZHead.X)
	print(D_XHead.Y, D_YHead.Y, D_ZHead.Y)
	print(D_XHead.Z, D_YHead.Z, D_ZHead.Z)
	local XHead = Vector3.new(0, 1, 0)
	local YHead = Vector3.new(-1, 0, 0)
	local ZHead = Vector3.new(0, 0, 1)

	local D_XHeadT = Vector3.new(D_XHead.X, D_YHead.X, D_ZHead.X)
	local D_YHeadT = Vector3.new(D_XHead.Y, D_YHead.Y, D_ZHead.Y)
	local D_ZHeadT = Vector3.new(D_XHead.Z, D_YHead.Z, D_ZHead.Z)
	print("-----------------------------")
	print(D_XHeadT.X, D_YHeadT.X, D_ZHeadT.X)
	print(D_XHeadT.Y, D_YHeadT.Y, D_ZHeadT.Y)
	print(D_XHeadT.Z, D_YHeadT.Z, D_ZHeadT.Z)

	local I_XHead = Vector3.new(
		XHead.X * D_XHeadT.X + YHead.X * D_XHeadT.Y + ZHead.X * D_XHeadT.Z,
		XHead.Y * D_XHeadT.X + YHead.Y * D_XHeadT.Y + ZHead.Y * D_XHeadT.Z,
		XHead.Z * D_XHeadT.X + YHead.Z * D_XHeadT.Y + ZHead.Z * D_XHeadT.Z
	)
	local I_YHead = Vector3.new(
		XHead.X * D_YHeadT.X + YHead.X * D_YHeadT.Y + ZHead.X * D_YHeadT.Z,
		XHead.Y * D_YHeadT.X + YHead.Y * D_YHeadT.Y + ZHead.Y * D_YHeadT.Z,
		XHead.Z * D_YHeadT.X + YHead.Z * D_YHeadT.Y + ZHead.Z * D_YHeadT.Z
	)
	local I_ZHead = Vector3.new(
		XHead.X * D_ZHeadT.X + YHead.X * D_ZHeadT.Y + ZHead.X * D_ZHeadT.Z,
		XHead.Y * D_ZHeadT.X + YHead.Y * D_ZHeadT.Y + ZHead.Y * D_ZHeadT.Z,
		XHead.Z * D_ZHeadT.X + YHead.Z * D_ZHeadT.Y + ZHead.Z * D_ZHeadT.Z
	)
	print("-----------------------------")
	print(I_XHead.X, I_YHead.X, I_ZHead.X)
	print(I_XHead.Y, I_YHead.Y, I_ZHead.Y)
	print(I_XHead.Z, I_YHead.Z, I_ZHead.Z)
	print("-----------------------------")

	return V1.X * I_XHead + V1.Y * I_YHead + V1.Z * I_ZHead, V2.X * I_XHead + V2.Y * I_YHead + V2.Z * I_ZHead
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
	Sphere_Pos: Vector3,
	Radius: number
): number?
	local Origin, Arc_Radius = Math.SphereFromArc(Arc_P1, Arc_P2, Tangent_V1)
	local Start, End = Math.ToUpSpace((Arc_P1 - Origin).Unit, (Arc_P2 - Origin).Unit, (Sphere_Pos - Origin).Unit)
	local HeightIntersection = Math.SphereSphereIntersection(Vector3.zero, Sphere_Pos - Origin, Arc_Radius, Radius)
	local Height = HeightIntersection / Arc_Radius
	if Height > 1 or Height < -1 then
		return
	end
	local Angle = Math.ArcLatitudeIntersection(Start, End, Height)
	if Angle == nil then
		return
	end
	local S, E = (Arc_P1 - Origin).Unit, (Arc_P2 - Origin).Unit
	return Angle / math.acos(S:Dot(E)), Math.RotateOverVector(S, E, Angle), Origin, Arc_Radius, S:Cross(E).Unit
end

return Math
