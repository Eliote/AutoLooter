local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local ListHelper = PRIVATE_TABLE.GetTable("ListHelper")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(400)
local reason = Color.GREEN .. L["Listed"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.items[sTitle]) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end

function module:GetOptions()
	return {
		whitelist = {
			name = L["Whitelist"],
			type = "group",
			args = {
				add = {
					type = "input",
					name = L["Add item to white list"],
					set = function(info, val) ListHelper.AddItem(val, PRIVATE_TABLE.DB.items) end,
					get = false,
					width = "double",
					usage = L["[link/id/name] or [mouse over]"]
				},
				remove = {
					type = "input",
					name = L["Remove item from white list"],
					width = "double",
					set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.items) end,
					get = false
				}
			}
		}
	}
end