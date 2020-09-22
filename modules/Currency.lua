local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Currency", "AceEvent-3.0")
module.priority = 300

local reason = Color.GREEN .. L["Coin"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (currencyID ~= nil) then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end
