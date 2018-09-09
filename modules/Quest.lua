local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(800)
local reason = Color.GREEN .. L["Quest"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)

	if (PRIVATE_TABLE.DB.lootQuest and isQuestItem) or (PRIVATE_TABLE.DB.lootQuest and bindType == 4) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end
