--!strict

local Polynomial: PolynomialClass = {} :: PolynomialClass
Polynomial.__index = Polynomial

type PolynomialClass = {
	__index: PolynomialClass,
	__eq: (lhs: Polynomial, rhs: Polynomial) -> boolean,
	__add: (lhs: Polynomial, rhs: Polynomial) -> Polynomial,
	new: (coefficients: { number }) -> Polynomial,
	getValue: (self: Polynomial, x: number) -> number,
	getDerivative: (self: Polynomial) -> Polynomial,
	sampledBisection: (
		self: Polynomial,
		startInterval: number,
		endInterval: number,
		samples: number,
		iterations: number,
		epsilon: number
	) -> number?,
	solveBisection: (
		self: Polynomial,
		startInterval: number,
		endInterval: number,
		iterations: number,
		epsilon: number
	) -> number?,
}

export type Polynomial = typeof(setmetatable({} :: { number }, Polynomial))

function Polynomial.__add(lhs: Polynomial, rhs: Polynomial): Polynomial
	local newCoefficients = {}
	for i = 1, math.max(#lhs, #rhs) do
		newCoefficients[i] = (lhs[i] or 0) + (rhs[i] or 0)
	end
	return Polynomial.new(newCoefficients)
end

function Polynomial:getValue(x: number): number
	local result = 0
	for i = 1, #self do
		result += self[i] * x ^ (i - 1)
	end
	return result
end

function Polynomial:getDerivative(): Polynomial
	local newCoefficients = {}
	for i = 2, #self do
		newCoefficients[i - 1] = self[i] * (i - 1)
	end
	return Polynomial.new(newCoefficients)
end

function Polynomial:sampledBisection(
	startInterval: number,
	endInterval: number,
	samples: number,
	iterations: number,
	epsilon: number
): number?
	local step = (endInterval - startInterval) / samples
	local lastY = self:getValue(startInterval)
	for i = 1, samples do
		local x = startInterval + i * step
		local y = self:getValue(x)
		if lastY * y < 0 then
			local switch = step < 0
			local result =
				self:solveBisection(switch and x or (x - step), switch and (x - step) or x, iterations, epsilon)
			return result
		end
		lastY = y
	end
	return
end

function Polynomial:solveBisection(
	startInterval: number,
	endInterval: number,
	iterations: number,
	epsilon: number
): number?
	local startValue = self:getValue(startInterval)
	local endValue = self:getValue(endInterval)
	if startValue * endValue > 0 then
		return
	end
	for i = 1, iterations do
		local midPoint = (startInterval + endInterval) / 2
		local midValue = self:getValue(midPoint)
		if math.abs(midValue) < epsilon then
			return midPoint
		end
		if startValue * midValue < 0 then
			endInterval = midPoint
			endValue = midValue
		else
			startInterval = midPoint
			startValue = midValue
		end
	end
	return (startInterval + endInterval) / 2
end

function Polynomial.__eq(lhs: Polynomial, rhs: Polynomial): boolean
	if #lhs ~= #rhs then
		return false
	end
	for i = 1, #lhs do
		if lhs[i] ~= rhs[i] then
			return false
		end
	end
	return true
end

function Polynomial.new(coefficients: { number }): Polynomial
	local self = setmetatable({}, Polynomial)
	for i = 1, #coefficients do
		self[i] = coefficients[i]
	end
	return self
end

return Polynomial
