local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Fishing", PRIVATE_TABLE.SingleVarModulePrototype:New(), "AceEvent-3.0")
module.priority = 1200

local reason = Color.DARK_BLUE .. L["Fishing"]

function module:CanEnable()
	return module.db.profile.enableFishingLoot
end

function module:InitializeDb()
	local defaults = { profile = { enableFishingLoot = false } }
	self.db = AutoLooter.db:RegisterNamespace("FishingModule", defaults)
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (module.db.profile.enableFishingLoot and IsFishingLoot()) then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				fishingLoot = {
					type = "toggle",
					width = "double",
					name = L["Loot everything while Fishing"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val)
						self.db.profile.enableFishingLoot = Util.GetBoolean(val)
						self:LoadState()
					end,
					get = function(info) return self.db.profile.enableFishingLoot end
				}
			}
		}
	}
end