local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Rarity", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 700

local reason = Color.GREEN .. L["Rarity"]

function module:CanEnable()
	return self.db.profile.rarity ~= -1
end

function module:InitializeDb()
	self.db = AutoLooter.db
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (AutoLooter.db.profile.rarity > -1) and nRarity and (nRarity >= AutoLooter.db.profile.rarity) then
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
					set = function(info, val)
						AutoLooter.db.profile.rarity = val
						self:UpdateState()
					end,
					get = function(info) return AutoLooter.db.profile.rarity end
				}
			}
		}
	}
end