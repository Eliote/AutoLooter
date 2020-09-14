local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Price", "AceEvent-3.0")
module.priority = 1000

local reason = Color.GREEN .. L["Price"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)
	if iPrice and (AutoLooter.db.profile.price > 0) and (iPrice >= AutoLooter.db.profile.price) then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				price = {
					type = "range",
					name = function()
						local formatedPrice = "[" .. Color.RED .. L["Off"] .. "|r]"
						if AutoLooter.db.profile.price > 0 then
							formatedPrice = GetMoneyString(AutoLooter.db.profile.price)
						end
						return L["Price (in coppers)"] .. " | " .. formatedPrice end,
					min = 0,
					max = 10000000,
					softMax = 1000000,
					step = 1,
					width = "double",
					order = 1000,
					set = function(info, val) AutoLooter.db.profile.price = val end,
					get = function(info) return AutoLooter.db.profile.price end
				}
			}
		}
	}
end