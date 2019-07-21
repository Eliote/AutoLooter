local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("Locked", "AceEvent-3.0")
module.priority = 100

local reason = Color.RED .. L["Locked"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (locked) then
		if (PRIVATE_TABLE.DB.printoutIgnored) then
			return false, reason, Util.GetItemText(icon, link, nQuantity), true
		else
			return false, nil, nil, true
		end
	end
end
