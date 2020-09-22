local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Token", "AceEvent-3.0")
module.priority = 900

local reason = Color.GREEN .. L["Token"]

local GetItemInfo = GetItemInfo

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, _, _, _, _, _, iPrice = GetItemInfo(link)

	if not iPrice then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end
