--!strict

--type SplineSuper = typeof(require(game.ReplicatedStorage.src.SplineSuper))

local SplineLut: SplineLutClass = {} :: SplineLutClass
SplineLut.__index = SplineLut

type SplineLutClass = {
	__index: SplineLutClass,
	inverseLookup: (self: SplineLut, t: number) -> number,
	forwardLookup: (self: SplineLut, t: number) -> number,
	regenerate: (self: SplineLut, spline: any, sampleCount: number, resolution: number) -> nil,
	new: () -> SplineLut,
	generate: (Spline: any, sampleCount: number, lutResolution: number) -> SplineLut,
	getLength: (self: SplineLut) -> number,
}

export type SplineLut = typeof(setmetatable(
	{} :: {
		sampleCount: number,
		resolution: number,
		samples: { number },
		length: number,
		lut: { number },
	},
	SplineLut
))

function SplineLut:getLength(): number
	return self.length
end

function SplineLut:inverseLookup(t: number): number
	local lowerIndex = math.floor(t * #self.lut)
	local upperIndex = math.ceil(t * #self.lut)
	if lowerIndex == upperIndex then
		if lowerIndex == 0 then
			return 0
		end
		return self.lut[lowerIndex]
	end
	local lowerT = self.lut[lowerIndex] or 0
	local upperT = self.lut[upperIndex] or 0
	local fraction = (t * #self.lut) - lowerIndex
	local returnValue = lowerT + (upperT - lowerT) * fraction
	return returnValue
end

function SplineLut:forwardLookup(t: number): number
	local lowerIndex = math.floor(t * #self.samples)
	local upperIndex = math.ceil(t * #self.samples)
	if lowerIndex == upperIndex then
		if lowerIndex == 0 then
			return 0
		end
		return self.samples[lowerIndex]
	end
	local lowerT = self.samples[lowerIndex] or 0
	local upperT = self.samples[upperIndex] or 0
	local fraction = (t * #self.samples) - lowerIndex
	local returnValue = lowerT + (upperT - lowerT) * fraction
	return returnValue / self.length
end

function SplineLut:regenerate(spline: any, sampleCount: number, resolution: number)
	self.sampleCount = sampleCount
	self.resolution = resolution
	local distance = 0
	local samples = {}
	local lastPos = spline:getPoint(0, false)
	for i = 1, sampleCount do
		local t = i / sampleCount
		local pos = spline:getPoint(t, false)
		distance += (pos - lastPos).magnitude
		lastPos = pos
		table.insert(samples, distance)
	end
	self.samples = samples
	self.length = self.samples[#self.samples]
	local lut = {}
	local step = self.length / resolution
	local index = 1
	for i = 1, resolution - 1 do
		distance = i * step
		while distance > self.samples[index] and index <= #self.samples do
			index += 1
		end
		local intervalStart = self.samples[index - 1] or 0
		local interval = self.samples[index] - intervalStart
		local intervalPos = (distance - intervalStart) / interval
		local t = ((index - 1) * (1 - intervalPos) + index * intervalPos) / #self.samples
		lut[i] = t
	end
	lut[resolution] = 1
	self.lut = lut
end

function SplineLut.new()
	local self = setmetatable({}, SplineLut)
	return self
end

function SplineLut.generate(spline: SplineSuper, sampleCount: number, lutResolution: number)
	local self = SplineLut.new(spline)
	self:regenerate(spline, sampleCount, lutResolution)
	return self
end

return SplineLut
