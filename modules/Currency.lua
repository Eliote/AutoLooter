local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("Currency", "AceEvent-3.0")
module.priority = 300

local reason = Color.GREEN .. L["Coin"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (currencyID ~= nil) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end
