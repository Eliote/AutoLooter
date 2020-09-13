local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("IgnoreBOP", PRIVATE_TABLE.SingleVarModulePrototype:New(), "AceEvent-3.0")
module.priority = 600

local reason = Color.ORANGE .. L["Ignored"]

function module:CanEnable()
	return PRIVATE_TABLE.DB.ignoreBop
end

function module:InitializeDb()
	self.db = AutoLooter.db
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.ignoreBop and link and select(14, GetItemInfo(link)) == 1) then
		return false, reason, "(BoP)" .. AutoLooter.FormatLoot(icon, link, nQuantity), true
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				ignoreBop = {
					type = "toggle",
					name = L["Ignore BoP"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val)
						PRIVATE_TABLE.DB.ignoreBop = Util.GetBoolean(val)
						self:LoadState()
					end,
					get = function(info) return PRIVATE_TABLE.DB.ignoreBop end
				}
			}
		}
	}
end