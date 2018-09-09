local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(900)
local reason = Color.GREEN .. L["Token"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)

	if not iPrice then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end
