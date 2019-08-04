local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Rarity", "AceEvent-3.0")
module.priority = 700

local reason = Color.GREEN .. L["Rarity"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.rarity > -1) and nRarity and (nRarity >= PRIVATE_TABLE.DB.rarity) then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				rarity = {
					type = "select",
					name = L["Rarity"],
					order = 1001,
					values = {
						[-1] = "|cFFFF0000" .. L["Off"],
						[0] = Util.GetColorForRarity(0) .. _G["ITEM_QUALITY0_DESC"],
						[1] = Util.GetColorForRarity(1) .. _G["ITEM_QUALITY1_DESC"],
						[2] = Util.GetColorForRarity(2) .. _G["ITEM_QUALITY2_DESC"],
						[3] = Util.GetColorForRarity(3) .. _G["ITEM_QUALITY3_DESC"],
						[4] = Util.GetColorForRarity(4) .. _G["ITEM_QUALITY4_DESC"]
					},
					set = function(info, val) PRIVATE_TABLE.DB.rarity = val end,
					get = function(info) return PRIVATE_TABLE.DB.rarity end
				}
			}
		}
	}
end