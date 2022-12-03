local Module = {}
local Math = require(game.ReplicatedStorage.source.Math)
function Module.Test(Height)
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
return Module
