local ADDON_NAME, PRIVATE_TABLE = ...
local Util = PRIVATE_TABLE.Util
local L = PRIVATE_TABLE.L

local Color = PRIVATE_TABLE.Color
Color.BLUE = "|cFF29E0E7"
Color.DARK_BLUE = "|cFF3044D0"
Color.PURPLE = "|cFFB737E7"
Color.WHITE = "|cFFFFFFFF"
Color.RED = "|cFFDC2924"
Color.YELLOW = "|cFFFFF244"
Color.GREEN = "|cFF3DDC53"
Color.PINK = "|cFFDC5272"
Color.ORANGE = "|cFFE77324"

Color.GOLD = "|cFFFFFF00"
Color.SILVER = "|cFFCCCCCC"
Color.COPPER = "|cFFFF6600"

local ICO_GOLD = "|TInterface\\MoneyFrame\\UI-GoldIcon:0|t"
local ICO_SILVER = "|TInterface\\MoneyFrame\\UI-SilverIcon:0|t"
local ICO_COPPER = "|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"

function Util.formatGold(value, cor, somenteMaior)
	local text = ""

	if not somenteMaior or value >= 10000 then
		text = text .. (cor or Color.GOLD) .. math.floor(value / 10000) .. ICO_GOLD .. "|r "
	end

	if not somenteMaior or (value >= 100 and value < 10000) then
		text = text .. (cor or Color.SILVER) .. math.floor((value / 100) % 100) .. ICO_SILVER .. "|r "
	end

	if not somenteMaior or (value < 100) then
		text = text .. (cor or Color.COPPER) .. math.floor(value % 100) .. ICO_COPPER .. "|r"
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

function Util.GetItemText(icon, link, quantity)
	quantity = quantity or 1
	icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark" .. ":0|t"
	link = link or ""

	return quantity .. "x|T" .. icon .. ":0|t" .. link .. " "
end

function Util.GetBoolean(bool, def)
	if (bool == "on" or bool == true) then
		return true
	elseif (bool == "off" or bool == false) then
		return false
	end

	if not def then return false end

	return def
end

function Util.mergeTable(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			Util.mergeTable(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end