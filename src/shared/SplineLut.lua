local Spline = require(game.ReplicatedStorage.src.Spline)

local SplineLut = {}
SplineLut.__index = SplineLut

function SplineLut:sample(sampleCount: number)
	local distance = 0
	local samples = {}
	local lastPos = self.Spline:computePoint(0)
	for i = 1, sampleCount do
		local t = i / sampleCount
		local pos = self.Spline:computePoint(t)
		distance += (pos - lastPos).magnitude
		lastPos = pos
		table.insert(samples, distance)
	end
	return samples
end

function SplineLut:compute(resolution: number)
	assert(self.samples and self.length, "Lut must be first sampled, before computing the Lut is possible.")
	local Lut = {}
	local step = self.length / resolution
	local index = 1
	for i = 1, resolution - 1 do
		local distance = i * step
		while distance > self.samples[index] and index <= #self.samples do
			index += 1
		end
		local intervalStart = self.samples[index - 1] or 0
		local interval = self.samples[index] - intervalStart
		local intervalPos = (distance - intervalStart) / interval
		local t = ((index - 1) * (1 - intervalPos) + index * intervalPos) / #self.samples
		Lut[i] = t
	end
	Lut[resolution] = 1
	return Lut
end

function SplineLut:getCorrectetT(t: number): number
	local lowerIndex = math.floor(t * #self.Lut)
	local upperIndex = math.ceil(t * #self.Lut)
	if lowerIndex == upperIndex then
		if lowerIndex == 0 then
			return 0
		end
		return self.Lut[lowerIndex]
	end
	local lowerT = self.Lut[lowerIndex] or 0
	local upperT = self.Lut[upperIndex] or 0
	local fraction = (t * #self.Lut) - lowerIndex
	local returnValue = lowerT + (upperT - lowerT) * fraction
	return returnValue
end

function SplineLut:getTFromDistance(distance: number): number
	local t = distance / self.length
	return self:getCorrectetT(t)
end

function SplineLut:regenerate(sampleCout: number, lutResolution: number)
	self.sampleCount = sampleCout
	self.lutResolution = lutResolution
	self.samples = self:sample(sampleCout)
	self.length = self.samples[#self.samples]
	self.Lut = self:compute(lutResolution)
end

function SplineLut.new(Spline: Spline.Spline)
	local self = setmetatable({}, SplineLut)
	self.Spline = Spline
	return self
end

function SplineLut.generate(Spline: Spline.Spline, sampleCount: number, lutResolution: number)
	local self = SplineLut.new(Spline)
	self:regenerate(sampleCount, lutResolution)
	return self
end

return SplineLut
