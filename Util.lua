local ADDON_NAME, PRIVATE_TABLE = ...;
local Util = PRIVATE_TABLE.GetTable("Util")
local L = PRIVATE_TABLE.GetTable("L")

local Color = PRIVATE_TABLE.GetTable("Color")
Color.BLUE = "|cFF29E0E7"
Color.DARK_BLUE = "|cFF3044D0"
Color.PURPLE = "|cFFB737E7"
Color.WHITE = "|cFFFFFFFF"
Color.RED = "|cFFDC2924"
Color.YELLOW = "|cFFFFF244"
Color.GREEN = "|cFF3DDC53"
Color.PINK = "|cFFDC5272"
Color.ORANGE = "|cFFE77324"

Color.OURO = "|cFFFFFF00"
Color.PRATA = "|cFFCCCCCC"
Color.BRONZE = "|cFFFF6600"

local ICO_OURO = "|TInterface\\MoneyFrame\\UI-GoldIcon:0|t"
local ICO_PRATA = "|TInterface\\MoneyFrame\\UI-SilverIcon:0|t"
local ICO_BRONZE = "|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"

function Util.formatGold(value, cor, somenteMaior)
	local text = ""

	if not somenteMaior or value >= 10000 then
		text = text .. (cor or Color.OURO) .. math.floor(value / 10000) .. ICO_OURO .. "|r "
	end

	if not somenteMaior or (value >= 100 and value < 10000) then
		text = text .. (cor or Color.PRATA) .. math.floor((value / 100) % 100) .. ICO_PRATA .. "|r "
	end

	if not somenteMaior or (value < 100) then
		text = text .. (cor or Color.BRONZE) .. math.floor(value % 100) .. ICO_BRONZE .. "|r"
	end

	text = trim(text)

	return text
end

function Util.__genOrderedIndex(t)
	local orderedIndex = {}
	for key in pairs(t) do
		table.insert(orderedIndex, key)
	end
	table.sort(orderedIndex)
	return orderedIndex
end

function Util.orderedNext(t, state)
	-- Equivalent of the next function, but returns the keys in the alphabetic
	-- order. We use a temporary ordered key table that is stored in the
	-- table being iterated.

	local key
	if state == nil then
		-- the first time, generate the index
		t.__orderedIndex = Util.__genOrderedIndex(t)
		key = t.__orderedIndex[1]
	else
		-- fetch the next value
		for i = 1, table.getn(t.__orderedIndex) do
			if t.__orderedIndex[i] == state then
				key = t.__orderedIndex[i + 1]
			end
		end
	end

	if key then
		return key, t[key]
	end

	-- no more value to return, cleanup
	t.__orderedIndex = nil
	return
end

function Util.orderedPairs(t)
	-- Equivalent of the pairs() function on tables. Allows to iterate
	-- in order
	return Util.orderedNext, t, nil
end

function Util.CountTable(t)
	if not t then return 0 end

	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function Util.CountChecked(t)
	local n = 0
	for k, v in pairs(t) do
		if v then n = n + 1 end
	end

	return n
end

function Util.GetColorForRarity(rarity)
	local _, _, _, hColor = GetItemQualityColor(rarity)
	if hColor then
		return "|c" .. hColor
	end

	return ""
end

--[[function Util.GetItemClassTable()
	local classes = GetItemClasses()

	for class, index in classes do
		classes[class] = GetItemsSubClasses(index)
	end
end]]

--[[function Util.GetItemClasses()
	local out = {}

	local itemClasses = { GetAuctionItemClasses() }
	if #itemClasses > 0 then
		for i, itemClass in pairs(itemClasses) do
			out[itemClass] = i
		end
	end

	return out
end]]

--[[function Util.GetItemsSubClasses(index)
	local out = {}

	local itemSubClasses = { GetAuctionItemSubClasses(i) };
	if #itemSubClasses > 0 then
		for i, itemSubClass in pairs(itemSubClasses) do
			out[itemSubClass] = false
		end
	end

	return out
end]]

Util.OnOff = function(bToggle)
	if (bToggle) then
		return Color.GREEN .. L["On"] .. "|r"
	end
	return Color.RED .. L["Off"] .. "|r"
end

-- UTIL
Util.print = function(...)
	local out = ""

	for i = 1, select("#", ...) do
		local s = tostring(select(i, ...))

		out = out .. s
	end

	print(Color.WHITE .. "<" .. Color.BLUE .. "AutoLooter" .. Color.WHITE .. ">|r", out)
end

--[[function Util.interp(str, tab)
    return (str:gsub('($%b{})', function(w) return tostring(tab[w:sub(3, -2)] or w) end))
end]]
