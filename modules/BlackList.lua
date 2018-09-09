local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(500)
local reason = Color.ORANGE .. L["Ignored"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.ignore[sTitle]) then
		if (PRIVATE_TABLE.DB.printoutIgnored) then
			return false, reason, "(List)" .. Util.GetItemText(icon, link, nQuantity), true
		else
			return false, nil, nil, true
		end
	end
end
