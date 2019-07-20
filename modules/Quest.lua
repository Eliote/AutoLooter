local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(800)
local reason = Color.GREEN .. L["Quest"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, itemClassID, itemSubClassID, bindType = GetItemInfo(link)

	if (PRIVATE_TABLE.DB.lootQuest) then
		if(isQuestItem or bindType == 4 or itemClassID == LE_ITEM_CLASS_QUESTITEM) then
			return true, reason, Util.GetItemText(icon, link, nQuantity), nil
		end
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				lootQuest = {
					type = "toggle",
					name = L["Loot quest itens"],
					set = function(info, val) PRIVATE_TABLE.DB.lootQuest = Util.GetBoolean(val) end,
					get = function(info) return PRIVATE_TABLE.DB.lootQuest end
				}
			}
		}
	}
end