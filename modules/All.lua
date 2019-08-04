local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("All", "AceEvent-3.0")
module.priority = 100000

local reason = Color.GREEN .. L["All"]
local reasonLog = Color.ORANGE .. L["Ignored"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if PRIVATE_TABLE.DB.lootAll then
		-- loot everything left
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	else
		-- logs everything left
		local _, _, _, _, _, itemType, itemSubType = GetItemInfo(link)
		local typeSubtype = (PRIVATE_TABLE.DB.printoutType and Color.YELLOW .. "(" .. itemType .. "/" .. itemSubType .. ")|r") or ""

		return false, reasonLog, typeSubtype .. AutoLooter.FormatLoot(icon, link, nQuantity), true
	end
end

function module.Finish()
	if (PRIVATE_TABLE.DB.close) then
		CloseLoot()
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				lootAll = {
					type = "toggle",
					name = L["Loot everything"],
					set = function(info, val) PRIVATE_TABLE.DB.lootAll = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.lootAll end
				}
			}
		}
	}
end