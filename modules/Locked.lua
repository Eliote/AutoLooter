local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Locked", "AceEvent-3.0")
module.priority = 100

local reason = Color.RED .. L["Locked"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (locked) then
		return false, reason, AutoLooter.FormatLoot(icon, link, nQuantity), true
	end
end
