local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local ListHelper = PRIVATE_TABLE.ListHelper

local module = AutoLooter:NewLootModule(1)

local PlaySoundFile = PlaySoundFile
local RaidNotice_AddMessage = RaidNotice_AddMessage

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if PRIVATE_TABLE.DB.alert[sTitle] then
		if PRIVATE_TABLE.DB.alertSound then
			PlaySoundFile(PRIVATE_TABLE.DB.alertSound) -- safe
		end

		RaidNotice_AddMessage(RaidWarningFrame, link, ChatTypeInfo["RAID_WARNING"])
	end
end

function module:GetOptions()
	return {
		alertlist = {
			name = L["Alert List"],
			type = "group",
			args = {
				add = {
					type = "input",
					name = L["Add item to alert list"],
					width = "double",
					set = function(info, val) ListHelper.AddItem(val, PRIVATE_TABLE.DB.alert) end,
					get = false
				},
				remove = {
					type = "input",
					name = L["Remove item from alert list"],
					width = "double",
					set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.alert) end,
					get = false
				},
				sound = {
					type = "input",
					name = L["Set alert sound"],
					width = "double",
					set = function(info, val) PRIVATE_TABLE.DB.alertSound = val end,
					get = false
				}
			}
		}
	}
end