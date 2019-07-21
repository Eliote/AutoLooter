local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Util = PRIVATE_TABLE.Util

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("Base", "AceEvent-3.0")

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
				}
			}
		},
	}
end