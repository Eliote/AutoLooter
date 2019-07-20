local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(100)
local reason = Color.RED .. L["Locked"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (locked) then
		if (PRIVATE_TABLE.DB.printoutIgnored) then
			return false, reason, Util.GetItemText(icon, link, nQuantity), true
		else
			return false, nil, nil, true
		end
	end
end
