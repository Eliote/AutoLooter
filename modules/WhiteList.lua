local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local ListHelper = PRIVATE_TABLE.ListHelper
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("WhiteList", "AceEvent-3.0")
module.priority = 400

local reason = Color.GREEN .. L["Listed"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.items[sTitle]) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end

function module:GetOptions()
	return {
		whitelist = {
			name = L["Whitelist"],
			type = "group",
			args = {
				info = {
					type = "header",
					name = L["You can drag & drop items here!"],
					hidden = true,
					dialogHidden = false,
					order = 0
				},
				add = {
					type = "input",
					name = L["Add item to white list"],
					set = function(info, val) ListHelper.AddItem(val, PRIVATE_TABLE.DB.items) end,
					get = false,
					width = "full",
					usage = L["[link/id/name] or [mouse over]"],
					order = 1,
				},
				remove = {
					type = "input",
					name = L["Remove item from white list"],
					width = "full",
					set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.items) end,
					get = false,
					order = 2,
				},
				list = {
					type = "input",
					name = L["Items list"],
					multiline = 13,
					set = false,
					get = function(info) return ListHelper.ListToString(PRIVATE_TABLE.DB.items) end,
					width = "full",
					order = -1
				}
			}
		}
	}
end