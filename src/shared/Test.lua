local Module = {}
local Math = require(game.ReplicatedStorage.source.Math)
function Module.Alpha(Height)
	local S = game.Workspace.Sphere
	local A = workspace.PointA
	local B = workspace.PointB
	local R = workspace.Result
	local P = workspace.Plane
	local D = workspace.Disc
	local Radius = S.Size.X / 2
	P.Position = Vector3.new(0, Radius * Height, 0) + S.Position
	local V1 = (A.Position - S.Position).Unit
	local V2 = (B.Position - S.Position).Unit
	D.CFrame = CFrame.lookAt(Vector3.zero, V1:Cross(V2)) * CFrame.Angles(0, math.pi / 2, 0) + D.Position
	local Angle = Math.ArcLatitudeIntersection(V1, V2, Height)
	if not Angle then
		print("Not succeded")
		return
	end
	R.Position = Math.RotateOverVector(V1, V2, Angle).Unit * Radius + S.Position
end

function Module.Beta()
	local P1 = game.Workspace.P1
	local P2 = game.Workspace.P2
	local T1 = game.Workspace.T1
	local S = game.Workspace.S
	local Pos, Size = Math.SphereFromArc(P1.Position, P2.Position, T1.Position - P1.Position)
	print(Size)
	S.Position = Pos
	S.Size = Vector3.one * Size * 2
end

function Module.Gamma()
	local P1 = game.Workspace.P1
	local P2 = game.Workspace.P2
	local T1 = game.Workspace.T1
	local S = game.Workspace.S
	local T = game.Workspace.Target
	local IS = game.Workspace.IntersectionSphere
	local Disc = game.Workspace.TDisc

	local Angle, P, Origin, Arc_Radius, GC =
		Math.ArcSphereIntersectionDemo(P1.Position, P2.Position, T1.Position - P1.Position, IS.Position, IS.Size.X / 2)
	T.Position = P * Arc_Radius + Origin
	S.Position = Origin
	S.Size = Vector3.one * Arc_Radius * 2
	Disc.CFrame = CFrame.lookAt(Vector3.zero, GC) * CFrame.Angles(0, math.pi / 2, 0) + Origin
	Disc.Size = Vector3.new(0.01, 2 * Arc_Radius, 2 * Arc_Radius)
	print(Angle)
end

return Module
