local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(1100)
local reason = Color.GREEN .. L["Type"]

local function LootType(iType, iSubType, iRarity)
	if PRIVATE_TABLE.DB.ignoreGreys and iRarity == 0 then return false end

	local t = PRIVATE_TABLE.DB.typeTable[iType]
	if t then return t[iSubType] or t["(Legacy Types)"] end

	return false
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)

	if LootType(itemType, itemSubType, nRarity) then
		local typeSubtype = (PRIVATE_TABLE.DB.printoutType and Color.YELLOW .. "(" .. itemType .. "/" .. itemSubType .. ")|r") or ""

		return true, reason, typeSubtype .. Util.GetItemText(icon, link, nQuantity), nil
	end
end
