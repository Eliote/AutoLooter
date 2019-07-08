local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(600)
local reason = Color.ORANGE .. L["Ignored"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.ignoreBop and link and select(14, GetItemInfo(link)) == 1) then
		if (PRIVATE_TABLE.DB.printoutIgnored) then
			return false, reason, "(BoP)" .. Util.GetItemText(icon, link, nQuantity), true
		else
			return false, nil, nil, true
		end
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
		local ignoreBop = AceGUI:Create("CheckBox")
		ignoreBop:SetLabel(L["Ignore BoP"])
		ignoreBop:SetValue(PRIVATE_TABLE.DB.ignoreBop)
		ignoreBop:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.ignoreBop = Util.GetBoolean(checked) end)
		container:AddChild(ignoreBop)
	end
end

module.cli = {
	ignoreBop = {
		type = "toggle",
		name = L["Ignore BoP"],
		set = function(info, val) PRIVATE_TABLE.DB.ignoreBop = Util.GetBoolean(val) end,
		get = function(info) return PRIVATE_TABLE.DB.ignoreBop end
	}
}