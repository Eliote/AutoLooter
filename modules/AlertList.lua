local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local ListHelper = PRIVATE_TABLE.GetTable("ListHelper")

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

module.cli = {
	alert = {
		type = "input",
		name = L["Add item to alert list"],
		set = function(info, val) ListHelper.AddItem(val, PRIVATE_TABLE.DB.alert) end,
		get = false
	},
	removeA = {
		type = "input",
		name = L["Remove item from alert list"],
		set = function(info, val) ListHelper.RemoveItem(val, PRIVATE_TABLE.DB.alert) end,
		get = false
	},
	alertSound = {
		type = "input",
		name = L["Set alert sound"],
		set = function(info, val) PRIVATE_TABLE.DB.alertSound = val end,
		get = false
	}
}