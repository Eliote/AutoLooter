local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Base", "AceEvent-3.0")

function AutoLooter.FormatLoot(icon, link, quantity)
	return Util.GetItemText(icon, link, quantity, PRIVATE_TABLE.DB.printoutIconOnly)
end

function module:GetOptions()
	return {
		general = {
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					set = function(info, val) LibStub("AceAddon-3.0"):GetAddon("AutoLooter").Toggle(val) end,
					get = function(info) return PRIVATE_TABLE.DB.enable end
				},
				printout = {
					type = "toggle",
					name = L["Printout items looted"],
					set = function(info, val) PRIVATE_TABLE.DB.printout = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.printout end
				},
				printoutIgnored = {
					type = "toggle",
					name = L["Printout items ignored"],
					set = function(info, val) PRIVATE_TABLE.DB.printoutIgnored = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.printoutIgnored end
				},
				close = {
					type = "toggle",
					name = L["Close after loot"],
					set = function(info, val) PRIVATE_TABLE.DB.close = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.close end
				},
				printoutIconOnly = {
					type = "toggle",
					name = L["Printout items icon only"],
					set = function(info, val) PRIVATE_TABLE.DB.printoutIconOnly = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.printoutIconOnly end
				},
				printoutReason = {
					type = "toggle",
					name = L["Printout reason of loot"],
					set = function(info, val) PRIVATE_TABLE.DB.printoutReason = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.printoutReason end
				}
			}
		},
	}
end