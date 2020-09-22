local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Quest", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 800

local reason = Color.GREEN .. L["Quest"]

local GetItemInfo = GetItemInfo

function module:CanEnable()
	return self.db.profile.lootQuest
end

function module:InitializeDb()
	self.db = AutoLooter.db
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (AutoLooter.db.profile.lootQuest) then
		local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, itemClassID, itemSubClassID, bindType = GetItemInfo(link)
		if (isQuestItem or bindType == 4 or itemClassID == LE_ITEM_CLASS_QUESTITEM) then
			return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
		end
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				lootQuest = {
					type = "toggle",
					name = L["Loot quest itens"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, value) self:SetProfileVar("lootQuest", Util.GetBoolean(value)) end,
					get = function(info) return self.db.profile.lootQuest end
				}
			}
		}
	}
end