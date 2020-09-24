local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("Price", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 1000

local reason = Color.GREEN .. L["Price"]

function module:CanEnable()
	return AutoLooter.db.profile.price > 0
end

function module:InitializeDb()
	self.db = AutoLooter.db
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice = GetItemInfo(link)
	if iPrice and (AutoLooter.db.profile.price > 0) and (iPrice >= AutoLooter.db.profile.price) then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				priceGroup = {
					name = L["Price (in coppers)"],
					type = "group",
					inline = true,
					args = {
						price = {
							type = "range",
							name = function()
								local formatedPrice = "[" .. Color.RED .. L["Off"] .. "|r]"
								if AutoLooter.db.profile.price > 0 then
									formatedPrice = GetMoneyString(AutoLooter.db.profile.price)
								end
								return formatedPrice
							end,
							desc = function()
								if AutoLooter.db.profile.price > 0 then
									return L["Loot everything with a price greater or equal to this value"]
								end
							end,
							min = 0,
							max = 10000000,
							softMax = 1000000,
							step = 1,
							width = "full",
							order = 1000,
							set = function(info, value) module:SetProfileVar("price", value) end,
							get = function(info) return AutoLooter.db.profile.price end
						}
					}
				}

			}
		}
	}
end