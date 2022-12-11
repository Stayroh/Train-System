local Math = {}

function Math.RotateOverVector(V1: Vector3, V2: Vector3, Angle: number): Vector3
	local GC = V1:Cross(V2).Unit
	return V1 * math.cos(Angle) + GC:Cross(V1) * math.sin(Angle)
end

function Math.ToUpSpace(V1: Vector3, V2: Vector3, Direction: Vector3)
	local CF = CFrame.lookAt(Vector3.zero, Direction)
	local UpCF = CFrame.lookAt(Vector3.zero, Vector3.new(0, 1, 0))
	return UpCF:VectorToWorldSpace(CF:VectorToObjectSpace(V1)), UpCF:VectorToWorldSpace(CF:VectorToObjectSpace(V2))
end

function Math.LineSphereIntersection(Start: Vector3, End: Vector3, Sphere_Pos: Vector3, Radius: number): number?
	End -= Start
	Sphere_Pos -= Start
	local Lenght = End.Magnitude
	local Direction = End.Unit
	local Center = Direction:Dot(Sphere_Pos)
	local CenterPos = Center * Direction
	local NearRadius = (CenterPos - Sphere_Pos).Magnitude
	if NearRadius > Radius then
		return
	end
	local X = math.sqrt(Radius ^ 2 - NearRadius ^ 2)
	local T1, T2 = Center - X, Center + X
	if T1 >= 0 and T1 <= Lenght then
		return T1
	end
	if T2 >= 0 and T2 <= Lenght then
		return T2
	end
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
	Arc_P2 -= Arc_P1
	local XHead = Tangent_V1:Cross(Arc_P2):Cross(Tangent_V1).Unit
	local X = XHead:Dot(Arc_P2)
	local Y = Tangent_V1:Dot(Arc_P2)
	local H = X / 2 + (Y ^ 2) / (2 * X)
	local R = math.abs(H)
	local Center = XHead * H + Arc_P1

	return Center, R
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
