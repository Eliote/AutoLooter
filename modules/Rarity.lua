local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(700)
local reason = Color.GREEN .. L["Rarity"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.rarity > -1) and nRarity and (nRarity >= PRIVATE_TABLE.DB.rarity) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end

local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")

function module:GetOptions()
	return {
		general = {
			args = {
				rarity = {
					type = "select",
					name = L["Rarity"],
					values = {
						[-1] = "|cFFFF0000" .. L["Off"],
						[0] = Util.GetColorForRarity(0) .. _G["ITEM_QUALITY0_DESC"],
						[1] = Util.GetColorForRarity(1) .. _G["ITEM_QUALITY1_DESC"],
						[2] = Util.GetColorForRarity(2) .. _G["ITEM_QUALITY2_DESC"],
						[3] = Util.GetColorForRarity(3) .. _G["ITEM_QUALITY3_DESC"],
						[4] = Util.GetColorForRarity(4) .. _G["ITEM_QUALITY4_DESC"]
					},
					set = function(info, val) PRIVATE_TABLE.DB.rarity = val end,
					get = function(info) return PRIVATE_TABLE.DB.rarity end
				}
			}
		}
	}
end