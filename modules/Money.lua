local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Color = PRIVATE_TABLE.Color

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("Money", "AceEvent-3.0")
module.priority = 200

local reason = Color.GREEN .. L["Coin"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (nQuantity == 0) then
		return true, reason, string.gsub(sTitle, "\n", " "), nil
	end
end
