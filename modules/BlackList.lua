local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local ListHelper = PRIVATE_TABLE.ListHelper
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("BlackList", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 500

local reason = Color.ORANGE .. L["Ignored"]

function module:CanEnable()
	return AutoLooter.db.profile.ignore and next(AutoLooter.db.profile.ignore)
end

function module:InitializeDb()
	self.db = AutoLooter.db
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local id = Util.getId(link)
	if (AutoLooter.db.profile.ignore[id] or AutoLooter.db.profile.ignore[sTitle]) then
		return false, reason, "(List)" .. AutoLooter.FormatLoot(icon, link, nQuantity), true
	end
end

function module:GetOptions()
	return {
		blacklist = {
			name = L["Blacklist"],
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
					name = L["Add item to ignore list"],
					width = "full",
					set = function(info, val)
						ListHelper.AddItem(val, AutoLooter.db.profile.ignore)
						module:UpdateState()
					end,
					get = false,
					order = 1,
				},
				remove = {
					type = "select",
					name = L["Remove item from ignore list"],
					width = "full",
					values = function() return ListHelper.GetValues(AutoLooter.db.profile.ignore) end,
					set = function(info, val)
						ListHelper.RemoveItem(val, AutoLooter.db.profile.ignore)
						module:UpdateState()
					end,
					get = function(info) end,
					order = 2,
				},
			}
		}
	}
end