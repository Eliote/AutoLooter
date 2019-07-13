local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(800)
local reason = Color.GREEN .. L["Quest"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, itemClassID, itemSubClassID, bindType = GetItemInfo(link)

	if (PRIVATE_TABLE.DB.lootQuest and isQuestItem) or (PRIVATE_TABLE.DB.lootQuest and bindType == 4) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end

	if (PRIVATE_TABLE.DB.lootKey and itemClassID == LE_ITEM_CLASS_KEY) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end


-- Config
local AceGUI = LibStub("AceGUI-3.0")
local tab = L["General"]

function module.GetConfigTabs()
	return tab
end

function module.CreateConfigGroup(container, event, group)
	if (group == tab) then
		local lootQuest = AceGUI:Create("CheckBox")
		lootQuest:SetLabel(L["Loot quest itens"])
		lootQuest:SetValue(PRIVATE_TABLE.DB.lootQuest)
		lootQuest:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.lootQuest = Util.GetBoolean(checked) end)
		container:AddChild(lootQuest)

		local lootKey = AceGUI:Create("CheckBox")
		lootKey:SetLabel(L["Loot key (legacy/bug)"])
		lootKey:SetValue(PRIVATE_TABLE.DB.lootKey)
		lootKey:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.lootKey = Util.GetBoolean(checked) end)
		container:AddChild(lootKey)
	end
end

module.cli = {
	lootQuest = {
		type = "toggle",
		name = L["Loot quest itens"],
		set = function(info, val) PRIVATE_TABLE.DB.lootQuest = Util.GetBoolean(val) end,
		get = function(info) return PRIVATE_TABLE.DB.lootQuest end
	}
}