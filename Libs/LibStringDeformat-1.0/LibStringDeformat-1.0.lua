--[[
This library is inspired by LibDeformat-3.0 (by ckknight [ckknight@gmail.com]),
but without using "loadstring" and with support for sparse indices.
License: MIT
]]--

local LSD = LibStub:NewLibrary("LibStringDeformat-1.0", 1)
if not LSD then return end

local function nop() end

local function compilePattern(pattern)
	local parts = { "^" }
	local captureToArgument = {}
	local captureIsNumber = {}
	local position = 1
	local nextIndex = 0
	local highestIndex = 0
	local captureCount = 0

	local function escape(text)
		return (text:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1"))
	end

	while position <= #pattern do
		local char = pattern:sub(position, position)

		-- Ordinary literal text.
		if char ~= "%" then
			local nextPercent = pattern:find("%%", position)

			if nextPercent then
				parts[#parts + 1] = escape(pattern:sub(position, nextPercent - 1))
				position = nextPercent
			else
				parts[#parts + 1] = escape(pattern:sub(position))
				break
			end

			-- Escaped percent sign.
		elseif pattern:sub(position + 1, position + 1) == "%" then
			parts[#parts + 1] = "%%"
			position = position + 2
		else
			local start = position
			local cursor = position + 1

			-- Optional positional index (1-99).
			local indexText = pattern:sub(cursor):match("^(%d%d?)%$")
			local argumentIndex
			if indexText then
				argumentIndex = tonumber(indexText)
				cursor = cursor + #indexText + 1
			else
				nextIndex = nextIndex + 1
				argumentIndex = nextIndex
			end

			local specifier = pattern:sub(cursor, cursor)
			local capturePattern
			local isNumber = false

			if specifier == "s" then
				capturePattern = ".+"
				cursor = cursor + 1
			elseif specifier == "c" then
				capturePattern = "."
				cursor = cursor + 1
			elseif specifier == "d" then
				capturePattern = "%-?%d+"
				isNumber = true
				cursor = cursor + 1
			elseif specifier == "f" or specifier == "g" then
				capturePattern = "%-?%d+%.?%d*"
				isNumber = true
				cursor = cursor + 1
			elseif specifier == "." then
				-- Precision format: %.2f, %.3g, etc.
				local precision = pattern:sub(cursor):match("^(%.%d+)")

				if precision then
					cursor = cursor + #precision
					specifier = pattern:sub(cursor, cursor)

					if specifier == "f" or specifier == "g" then
						capturePattern = "%-?%d+%.?%d*"
						isNumber = true
						cursor = cursor + 1
					end
				end
			end

			if capturePattern then
				captureCount = captureCount + 1
				captureToArgument[captureCount] = argumentIndex
				captureIsNumber[captureCount] = isNumber
				highestIndex = math.max(highestIndex, argumentIndex)
				parts[#parts + 1] = "(" .. capturePattern .. ")"
				position = cursor
			else
				-- Unsupported sequence: treat the percent literally.
				parts[#parts + 1] = "%%"
				position = start + 1
			end
		end
	end

	if captureCount == 0 then
		return nop
	else
		parts[#parts + 1] = "$"

		local unpattern = table.concat(parts)

		return function(self, text)
			local captures = { text:match(unpattern) }

			if captures[1] == nil then
				return unpack({}, 1, highestIndex)
			end

			local result = {}
			for i = 1, captureCount do
				local value = captures[i]
				if captureIsNumber[i] then
					value = value + 0
				end
				result[captureToArgument[i]] = value
			end

			return unpack(result, 1, highestIndex)
		end
	end
end

-- @param pattern The pattern used to create a text.
-- @return A table with [pattern] variable and a function [parse] that receives the text as parameter.
-- @usage StringDeformat.Compile("Hello, %s").parse("Hello, world") == "world"
function LSD:Compile(pattern)
	return {
		pattern = pattern,
		Parse = compilePattern(pattern)
	}
end

--@debug@
-- Tests from LibDeformat-3.0 made by ckknight (ckknight@gmail.com), with a fill more cases.
function LSD.Test()
	local function tuple(success, ...)
		if success then
			return true, { n = select('#', ...), ... }
		else
			return false, ...
		end
	end

	local function check(text, pattern, ...)
		local success, results = tuple(pcall(function(t, p) return LSD:Compile(p):Parse(t) end, text, pattern))
		if not success then
			return false, results
		end

		if select('#', ...) ~= results.n then
			return false, ("Differing number of return values. Expected: %d. Actual: %d."):format(select('#', ...), results.n)
		end

		for i = 1, results.n do
			local expected = select(i, ...)
			local actual = results[i]
			if type(expected) ~= type(actual) then
				return false, ("Return #%d differs by type. Expected: %s (%s). Actual: %s (%s)"):format(i, type(expected), expected or "nil", type(actual), actual or "nil")
			elseif expected ~= actual then
				return false, ("Return #%d differs. Expected: %s. Actual: %s"):format(i, expected, actual)
			end
		end

		return true
	end

	local function test(text, pattern, ...)
		local success, problem = check(text, pattern, ...)
		if not success then
			print(("Problem with (%q, %q): %s"):format(text, pattern, problem or ""))
		end
	end

	test("Hello, friend", "Hello, %s", "friend")
	test("Hello, friend", "Hello, %1$s", "friend")
	test("Cost: $100", "Cost: $%d", 100)
	test("Cost: $100", "Cost: $%1$d", 100)
	test("Alpha, Bravo", "%s, %s", "Alpha", "Bravo")
	test("Alpha, Bravo", "%1$s, %2$s", "Alpha", "Bravo")
	test("Alpha, Bravo", "%2$s, %1$s", "Bravo", "Alpha")
	test("Alpha, Bravo, Charlie, Delta, Echo", "%s, %s, %s, %s, %s", "Alpha", "Bravo", "Charlie", "Delta", "Echo")
	test("Alpha, Bravo, Charlie, Delta, Echo", "%1$s, %2$s, %3$s, %4$s, %5$s", "Alpha", "Bravo", "Charlie", "Delta", "Echo")
	test("Alpha, Bravo, Charlie, Delta, Echo", "%5$s, %4$s, %3$s, %2$s, %1$s", "Echo", "Delta", "Charlie", "Bravo", "Alpha")
	test("Alpha, Bravo, Charlie, Delta, Echo", "%2$s, %3$s, %4$s, %5$s, %1$s", "Echo", "Alpha", "Bravo", "Charlie", "Delta")
	test("Alpha, Bravo, Charlie, Delta, Echo", "%3$s, %4$s, %5$s, %1$s, %2$s", "Delta", "Echo", "Alpha", "Bravo", "Charlie")
	test("Alpha, Bravo, Charlie, Delta", "%s, %s, %s, %s, %s", nil, nil, nil, nil, nil)
	test("Hello, friend", "Cost: $%d", nil)
	test("Alpha, Delta, Echo", "%1$s, %4$s, %5$s", "Alpha", nil, nil, "Delta", "Echo")
	test("Alpha, Echo", "%10$s, %1$s", "Echo", nil, nil, nil, nil, nil, nil, nil, nil, "Alpha")
	test("Alpha, Alpha", "%1$s, %1$s", "Alpha")
	test("123, 456", "%2$d, %5$d", nil, 123, nil, nil, 456)
	print("StringDeformat: Tests completed.")
end
--@end-debug@
