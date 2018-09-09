local ADDON_NAME, PRIVATE_TABLE = ...;
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
