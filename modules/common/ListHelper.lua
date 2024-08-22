local ADDON_NAME, PRIVATE_TABLE = ...

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local ListHelper = PRIVATE_TABLE.ListHelper
local Util = PRIVATE_TABLE.Util
local Color = PRIVATE_TABLE.Color

local GetItemInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo

function ListHelper.AddItem(sTitle, list)
	local sLink = sTitle
	if not sTitle or sTitle == "" then
		sTitle, sLink = GameTooltip:GetItem()

		if not sTitle or sTitle == "" then
			for k, _ in pairs(list) do
				AutoLooter.print(k)
			end

			return
		end
	end

	local id = Util.getId(sLink)
	if not id then
		AutoLooter.print(L["Invalid item"], ": ", sTitle);
		return
	end

	local item = Item:CreateFromItemID(id)
	if not item or item:IsItemEmpty() then
		AutoLooter.print(L["Invalid item"], ": ", sTitle);
		return
	end

	item:ContinueOnItemLoad(function()
		local name, link = GetItemInfo(id)

		if (list[id]) then
			AutoLooter.print(L["Already in the list"], ": ", Color.YELLOW, link)
			return
		end

		if (list[name]) then
			list[name] = nil
		end

		list[id] = link
		AutoLooter.print(L["Added"], ": ", Color.YELLOW, link)
	end)
end

function ListHelper.RemoveItem(sTitle, list)
	local sLink = sTitle
	if not sTitle or sTitle == "" then
		sTitle, sLink = GameTooltip:GetItem()

		if not sTitle or sTitle == "" then
			for k, _ in pairs(list) do
				AutoLooter.print(k)
			end

			return
		end
	end

	local id = Util.getId(sLink)

	if(not id) then
		if (list[sTitle]) then
			list[sTitle] = nil
			AutoLooter.print(L["Removed"], ": ", Color.YELLOW, sTitle)
			return
		end
	end

	if (list[id]) then
		local link = list[id]
		list[id] = nil
		AutoLooter.print(L["Removed"], ": ", Color.YELLOW, link)
		return
	end

	AutoLooter.print(L["Not listed"], ": ", Color.YELLOW, sTitle)
end

function ListHelper.ListToString(list)
	local text = ""
	for k, _ in pairs(list) do
		text = text .. k .. '\n'
	end
	return text
end

function ListHelper.GetValues(list)
	local values = {}

	for k, v in pairs(list) do
		if (tonumber(k)) then
			values[k] = v
		elseif (v) then
			values[k] = k
		end
	end

	return values
end