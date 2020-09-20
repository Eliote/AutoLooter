local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("FishingIgnore", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 10

local reason = Color.DARK_BLUE .. L["Ignore Fishing"]

function module:CanEnable()
	return module.db.profile.enableModule
end

function module:InitializeDb()
	local defaults = { profile = { enableModule = false } }
	self.db = AutoLooter.db:RegisterNamespace("FishingIgnoreModule", defaults)
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (module.db.profile.enableModule and IsFishingLoot()) then
		return false, reason, AutoLooter.FormatLoot(icon, link, nQuantity), true
	end
end

function module:GetOptions()
	return {
		fishing = {
			name = L["Fishing"],
			type = "group",
			args = {
				fishingBuddy = {
					type = "toggle",
					name = L["Don't loot anything while Fishing"],
					desc = L["This can be useful to let addons like Fishing Buddy do its work"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, value) self:SetProfileVar("enableModule", Util.GetBoolean(value)) end,
					get = function(info) return self.db.profile.enableModule end
				}
			}
		}
	}
end