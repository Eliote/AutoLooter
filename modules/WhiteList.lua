local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local ListHelper = PRIVATE_TABLE.ListHelper
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("WhiteList", "AceEvent-3.0")
module.priority = 400

local reason = Color.GREEN .. L["Listed"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local id = Util.getId(link)
	if (PRIVATE_TABLE.DB.items[id] or PRIVATE_TABLE.DB.items[sTitle]) then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
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
					type = "select",
					name = L["Remove item from white list"],
					width = "full",
					values = function() return ListHelper.GetValues(PRIVATE_TABLE.DB.items) end,
					set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.items) end,
					get = function(info) end,
					order = 2,
				},
			}
		}
	}
end