local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("IgnoreBOP", "AceEvent-3.0")
module.priority = 600

local reason = Color.ORANGE .. L["Ignored"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.ignoreBop and link and select(14, GetItemInfo(link)) == 1) then
		if (PRIVATE_TABLE.DB.printoutIgnored) then
			return false, reason, "(BoP)" .. Util.GetItemText(icon, link, nQuantity), true
		else
			return false, nil, nil, true
		end
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				ignoreBop = {
					type = "toggle",
					name = L["Ignore BoP"],
					set = function(info, val) PRIVATE_TABLE.DB.ignoreBop = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.ignoreBop end
				}
			}
		}
	}
end