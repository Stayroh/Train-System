local Module = {}
local Spline = require(game.ReplicatedStorage.src.Spline)

-- Assuming the necessary modules and data structures are available
-- Let's assume Vector3 and Spline are defined somewhere in your codebase

-- Helper function to insert a knot into a B-spline
function insertKnot(controlPoints, knots, t)
	local newControlPoints = {}
	local n = #controlPoints - 1
	local m = #knots - 1

	for i = 1, n + 1 do
		table.insert(newControlPoints, controlPoints[i])
	end

	for j = 1, m + 1 do
		if knots[j] > t then
			for i = n + 1, j + 1, -1 do
				knots[i + 1] = knots[i]
				newControlPoints[i + 1] = newControlPoints[i]
			end
			knots[j + 1] = t
			break
		end
	end

	for j = 1, m + 1 do
		if knots[j] == t then
			for i = j + 1, n + 2 do
				local alpha = (t - knots[i - 1]) / (knots[i] - knots[i - 1])
				newControlPoints[i] = (1 - alpha) * newControlPoints[i - 1] + alpha * newControlPoints[i]
			end
			break
		end
	end

	return newControlPoints
end

-- Function to convert B-spline to Bezier splines
function Module.bsplineToBezier(controlPoints: { Vector3 }): { Spline.Spline }
	local bezierSplines = {}
	local n = #controlPoints - 1

	-- Define knots vector (uniform knots for simplicity)
	local knots = {}
	for i = 1, n + 5 do
		knots[i] = (i - 1) / (n + 3)
	end

	-- Insert knots to break the B-spline into Bezier segments
	for i = 2, n + 1 do
		local t = knots[i]
		controlPoints = insertKnot(controlPoints, knots, t)
	end

	-- Extract Bezier segments
	for i = 1, n - 2 do
		local p0 = controlPoints[i]
		local p1 = controlPoints[i + 1]
		local p2 = controlPoints[i + 2]
		local p3 = controlPoints[i + 3]

		local tangent1 = (p1 - p0) * 3
		local tangent2 = (p3 - p2) * 3

		table.insert(bezierSplines, Spline.new(p0, p3, tangent1, tangent2))
	end

	return bezierSplines
end

return Module
