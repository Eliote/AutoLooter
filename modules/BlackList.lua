local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local ListHelper = PRIVATE_TABLE.GetTable("ListHelper")

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

function module:GetOptions()
	return {
		blacklist = {
			name = L["Blacklist"],
			type = "group",
			args = {
				add = {
					type = "input",
					name = L["Add item to ignore list"],
					width = "double",
					set = function(info, val) ListHelper.AddItem(val, PRIVATE_TABLE.DB.ignore) end,
					get = false
				},
				remove = {
					type = "input",
					name = L["Remove item from ignore list"],
					width = "double",
					set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.ignore) end,
					get = false
				},
			}
		}
	}
end