local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

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
				add = {
					type = "input",
					name = L["Add item to white list"],
					set = function(info, val) ListHelper.AddItem(val, PRIVATE_TABLE.DB.items) end,
					get = false,
					width = "double",
					usage = L["[link/id/name] or [mouse over]"]
				},
				remove = {
					type = "input",
					name = L["Remove item from white list"],
					width = "double",
					set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.items) end,
					get = false
				}
			}
		}
	}
end