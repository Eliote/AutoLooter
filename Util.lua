local ADDON_NAME, PRIVATE_TABLE = ...

--- @class Util
local Util = PRIVATE_TABLE.Util
local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")

local GetItemQualityColor = (C_Item and C_Item.GetItemQualityColor) or GetItemQualityColor

--- @class Color
local Color = PRIVATE_TABLE.Color
Color.BLUE = "|cFF29E0E7"
Color.DARK_BLUE = "|cFF7878ff"
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

function Util.orderedPairs(t, sortFunction, filter, resetMessage)
	local sortTable = {}

	local iNext, iTable
	if (type(t) == "function") then
		iNext, iTable = t()
	else
		iNext, iTable = pairs(t)
	end

	for key, value in iNext, iTable do
		if (not filter or filter(key, value)) then
			table.insert(sortTable, key)
		end
	end
	table.sort(sortTable, sortFunction)

	local i = 0
	local iterator = function(k)
		if (resetMessage and (k == resetMessage)) then
			i = 0
			return
		end
		i = i + 1
		if (sortTable[i] == nil) then
			return nil
		else
			return sortTable[i], iTable[sortTable[i]]
		end
	end

	return iterator
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

function Util.GetItemText(icon, link, quantity, iconOnly)
	quantity = quantity or 1
	icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
	link = link or ""
	local texture = "|T" .. icon .. ":0|t"
	local text = texture .. link

	if (iconOnly) then
		local newText, count = link:gsub("|h%[.+%]|h", "|h[" .. texture .. "]|h")
		if (count == 0) then
			newText = link:gsub("|h.+|h", "|h" .. texture .. "|h")
		end
		text = newText
	end

	return Color.WHITE .. quantity .. "x|r" .. text
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

function Util.getId(itemLinkOrId)
	if not itemLinkOrId then return end
	if (tonumber(itemLinkOrId)) then return tonumber(itemLinkOrId) end

	local _, _, _, _, id = string.find(itemLinkOrId, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")

	return tonumber(id)
end

function Util.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end
