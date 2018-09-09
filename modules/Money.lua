local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()

local module = AutoLooter:NewLootModule(200)
local reason = Color.GREEN .. L["Coin"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (nQuantity == 0) then
		return true, reason, string.gsub(sTitle, "\n", " "), nil
	end
end
