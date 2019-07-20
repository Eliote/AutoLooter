local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(1000)
local reason = Color.GREEN .. L["Price"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)
	if iPrice and (PRIVATE_TABLE.DB.price > 0) and (iPrice >= PRIVATE_TABLE.DB.price) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				price = {
					type = "range",
					name = L["Price (in coppers)"],
					min = 0,
					max = 10000000,
					softMax = 1000000,
					step = 1,
					width = "double",
					set = function(info, val) PRIVATE_TABLE.DB.price = val end,
					get = function(info) return PRIVATE_TABLE.DB.price end
				}
			}
		}
	}
end