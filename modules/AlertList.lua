local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local ListHelper = PRIVATE_TABLE.ListHelper
local Util = PRIVATE_TABLE.Util
local WidgetLists = AceGUIWidgetLSMlists

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("AlertList", "AceEvent-3.0")
module.priority = 1

local PlaySoundFile = PlaySoundFile
local RaidNotice_AddMessage = RaidNotice_AddMessage

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local id = Util.getId(link)
	local db = AutoLooter.db.profile
	if (db.alert[id] or db.alert[sTitle]) then
		if db.alertSound then
			local sound = db.alertSound
			if (WidgetLists.sound[db.alertSound]) then
				sound = WidgetLists.sound[db.alertSound]
			end
			pcall(PlaySoundFile, sound) -- safe
		end

		RaidNotice_AddMessage(RaidWarningFrame, link, ChatTypeInfo["RAID_WARNING"])
	end
end

function module:GetOptions()
	return {
		alertlist = {
			name = L["Alert List"],
			type = "group",
			args = {
				info = {
					type = "header",
					name = L["You can drag & drop items here!"],
					order = 0,
					hidden = true,
					dialogHidden = false,
				},
				add = {
					type = "input",
					name = L["Add item to alert list"],
					width = "full",
					set = function(info, val) ListHelper.AddItem(val, AutoLooter.db.profile.alert) end,
					get = false,
					order = 1,
				},
				remove = {
					type = "select",
					name = L["Remove item from alert list"],
					width = "full",
					values = function() return ListHelper.GetValues(AutoLooter.db.profile.alert) end,
					set = function(info, val) ListHelper.RemoveItem(val, AutoLooter.db.profile.alert) end,
					get = function(info) end,
					order = 2,
				},
				sound = {
					type = "select",
					name = L["Set alert sound"],
					width = "full",
					dialogControl = "LSM30_Sound",
					values = WidgetLists.sound,
					set = function(info, val) AutoLooter.db.profile.alertSound = val end,
					get = function(info) return AutoLooter.db.profile.alertSound end,
					order = 3,
				}
			}
		}
	}
end