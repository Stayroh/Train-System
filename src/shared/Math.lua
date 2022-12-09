local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angle: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angle) + GC:Cross(V1) * math.sin(Angle)
end

function Math.ToUpSpace(V1: Vector3, V2: Vector3, Direction: Vector3)
	local CF = CFrame.lookAt(Vector3.zero, Direction)
	local UpCF = CFrame.lookAt(Vector3.zero, Vector3.new(0, 1, 0))
	return UpCF:VectorToWorldSpace(CF:VectorToObjectSpace(V1)), UpCF:VectorToWorldSpace(CF:VectorToObjectSpace(V2))

	--[[
	local D_XHead = Direction.Unit
	local D_ZHead = D_XHead:Cross(Vector3.new(0, 1, 0))
	D_ZHead = D_ZHead == Vector3.zero and Vector3.new(1, 0, 0) or D_ZHead.Unit
	local D_YHead = D_ZHead:Cross(D_XHead)

	local XHead = Vector3.new(0, 1, 0)
	local YHead = Vector3.new(-1, 0, 0)
	local ZHead = Vector3.new(0, 0, 1)

	local D_XHeadT = Vector3.new(D_XHead.X, D_YHead.X, D_ZHead.X)
	local D_YHeadT = Vector3.new(D_XHead.Y, D_YHead.Y, D_ZHead.Y)
	local D_ZHeadT = Vector3.new(D_XHead.Z, D_YHead.Z, D_ZHead.Z)

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

	return V1.X * I_XHead + V1.Y * I_YHead + V1.Z * I_ZHead, V2.X * I_XHead + V2.Y * I_YHead + V2.Z * I_ZHead
	]]
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
	local RelativP2 = Arc_P2 - Arc_P1
	local Side = Tangent_V1:Cross(RelativP2):Cross(Tangent_V1).Unit
	local X = Side:Dot(RelativP2)
	local Y = Tangent_V1:Dot(RelativP2)
	print(X, Y)
	local H = X / 2 + (Y ^ 2) / (2 * X)
	local Center = Side * H + Arc_P1
	return Center, H
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
	return Angle / math.acos(Start:Dot(End))
end

function Math.ArcSphereIntersectionDemo(
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
	return (Angle % (math.pi * 2)) / math.acos(S:Dot(E)),
		Math.RotateOverVector(S, E, Angle),
		Origin,
		Arc_Radius,
		S:Cross(E)
end

return Math
