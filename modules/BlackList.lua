local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local ListHelper = PRIVATE_TABLE.ListHelper
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("BlackList", "AceEvent-3.0")
module.priority = 500

local reason = Color.ORANGE .. L["Ignored"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.ignore[sTitle]) then
		if (PRIVATE_TABLE.DB.printoutIgnored) then
			return false, reason, "(List)" .. Util.GetItemText(icon, link, nQuantity), true
		else
			return false, nil, nil, true
		end
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
					set = function(info, val) ListHelper.AddItem(val, PRIVATE_TABLE.DB.ignore) end,
					get = false,
					order = 1,
				},
				remove = {
					type = "input",
					name = L["Remove item from ignore list"],
					width = "full",
					set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.ignore) end,
					get = false,
					order = 2,
				},
				list = {
					type = "input",
					name = L["Items list"],
					multiline = 13,
					set = false,
					get = function(info) return ListHelper.ListToString(PRIVATE_TABLE.DB.ignore) end,
					width = "full",
					order = -1
				}
			}
		}
	}
end