local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Base", "AceEvent-3.0")

function AutoLooter.FormatLoot(icon, link, quantity)
	return Util.GetItemText(icon, link, quantity, AutoLooter.db.profile.printoutIconOnly)
end

local function isWoWAutoLootEnabled()
	return GetCVar("autoLootDefault") == "1"
end

function module:GetOptions()
	return {
		general = {
			args = {
				enable = {
					type = "toggle",
					name = function() return (isWoWAutoLootEnabled() and Color.RED or "") .. L["Enable AutoLooter"] end,
					desc = L["ENABLE_AUTO_LOOTER_DESC"],
					order = 0,
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val) LibStub("AceAddon-3.0"):GetAddon("AutoLooter").Toggle(val) end,
					get = function(info) return AutoLooter.db.profile.enable end
				},
				close = {
					type = "toggle",
					name = L["Close after loot"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val) AutoLooter.db.profile.close = Util.GetBoolean(val) end,
					get = function(info) return AutoLooter.db.profile.close end
				},
				lootEarly = {
					type = "toggle",
					name = L["Fast loot"],
					set = function(info, val) AutoLooter.db.profile.lootEarly = Util.GetBoolean(val) end,
					get = function(info) return AutoLooter.db.profile.lootEarly end
				},
			}
		},
		chat = {
			name = L["Chat"],
			type = "group",
			args = {
				printout = {
					type = "toggle",
					name = L["Printout items looted"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val) AutoLooter.db.profile.printout = Util.GetBoolean(val) end,
					get = function(info) return AutoLooter.db.profile.printout end
				},
				printoutIgnored = {
					type = "toggle",
					name = L["Printout items ignored"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val) AutoLooter.db.profile.printoutIgnored = Util.GetBoolean(val) end,
					get = function(info) return AutoLooter.db.profile.printoutIgnored end
				},
				printoutIconOnly = {
					type = "toggle",
					name = L["Printout items icon only"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val) AutoLooter.db.profile.printoutIconOnly = Util.GetBoolean(val) end,
					get = function(info) return AutoLooter.db.profile.printoutIconOnly end
				},
				printoutReason = {
					type = "toggle",
					name = L["Printout reason of loot"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val) AutoLooter.db.profile.printoutReason = Util.GetBoolean(val) end,
					get = function(info) return AutoLooter.db.profile.printoutReason end
				},
				printoutChatFrame = {
					type = "multiselect",
					name = L["Printout chat frame"],
					values = function()
						local values = {}
						for i = 1, NUM_CHAT_WINDOWS do
							local chatName = GetChatWindowInfo(i)
							if chatName and chatName ~= "" then
								values[chatName] = chatName
							end
						end
						return values
					end,
					set = function(info, key, val)
						AutoLooter.db.char.chatFrameNames[key] = val
						if key == DEFAULT_CHAT_FRAME.name then
							AutoLooter.db.char.chatFrameNames[-1] = false
						end
					end,
					get = function(info, key, ...)
						if AutoLooter.db.char.chatFrameNames[key] then return true end
						if key == DEFAULT_CHAT_FRAME.name and AutoLooter.db.char.chatFrameNames[-1] == true then return true end
					end
				}
			}
		}
	}
end