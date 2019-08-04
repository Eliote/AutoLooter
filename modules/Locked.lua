local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("Locked", "AceEvent-3.0")
module.priority = 100

local reason = Color.RED .. L["Locked"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (locked) then
		return false, reason, Util.GetItemText(icon, link, nQuantity), true
	end
end
