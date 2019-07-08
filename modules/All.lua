local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")
local AUTO_LOOTER = PRIVATE_TABLE.GetTable("AUTO_LOOTER")
local Broker = PRIVATE_TABLE.GetTable("Broker")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(100000)
local reason = Color.GREEN .. L["All"]
local reasonLog = Color.ORANGE .. L["Ignored"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if PRIVATE_TABLE.DB.lootAll then -- loot everything left
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	elseif (PRIVATE_TABLE.DB.printoutIgnored) then -- logs everything left
		local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)
		local typeSubtype = (PRIVATE_TABLE.DB.printoutType and Color.YELLOW .. "(" .. itemType .. "/" .. itemSubType .. ")|r") or ""

		return false, reasonLog, typeSubtype .. Util.GetItemText(icon, link, nQuantity), true
	end
end

function module.Finish()
	if (PRIVATE_TABLE.DB.close) then
		CloseLoot()
	end
end

-- Config
local AceGUI = LibStub("AceGUI-3.0")
local tabGeneral = L["General"]
local tabs = { tabGeneral }

function module.GetConfigTabs()
	return tabs
end

function module.CreateConfigGroup(container, event, group)
	if (group == tabGeneral) then
		local enable = AceGUI:Create("CheckBox")
		enable:SetLabel(L["Enable AutoLooter"])
		enable:SetValue(PRIVATE_TABLE.DB.enable)
		enable:SetCallback("OnValueChanged", function(self, event, checked) AUTO_LOOTER.Enable(checked) end)
		container:AddChild(enable)

		local lootAll = AceGUI:Create("CheckBox")
		lootAll:SetLabel(L["Loot everything"])
		lootAll:SetValue(PRIVATE_TABLE.DB.lootAll)
		lootAll:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.lootAll = Util.GetBoolean(checked) end)
		container:AddChild(lootAll)

		local close = AceGUI:Create("CheckBox")
		close:SetLabel(L["Close after loot"])
		close:SetValue(PRIVATE_TABLE.DB.close)
		close:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.close = Util.GetBoolean(checked) end)
		container:AddChild(close)

		local printOut = AceGUI:Create("CheckBox")
		printOut:SetLabel(L["Printout items looted"])
		printOut:SetValue(PRIVATE_TABLE.DB.printout)
		printOut:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.printout = Util.GetBoolean(checked) end)
		container:AddChild(printOut)

		local printOutIgnored = AceGUI:Create("CheckBox")
		printOutIgnored:SetLabel(L["Printout items ignored"])
		printOutIgnored:SetValue(PRIVATE_TABLE.DB.printoutIgnored)
		printOutIgnored:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.printoutIgnored = Util.GetBoolean(checked) end)
		container:AddChild(printOutIgnored)

		local autoConfirmRoll = AceGUI:Create("CheckBox")
		autoConfirmRoll:SetLabel(L["Auto confirm loot roll"])
		autoConfirmRoll:SetValue(PRIVATE_TABLE.DB.autoConfirmRoll)
		autoConfirmRoll:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.autoConfirmRoll = Util.GetBoolean(checked) end)
		container:AddChild(autoConfirmRoll)

		local showMinimap = AceGUI:Create("CheckBox")
		showMinimap:SetLabel(L["Show minimap button"])
		showMinimap:SetValue(not PRIVATE_TABLE.DB.minimap.hide)
		showMinimap:SetCallback("OnValueChanged", function(self, event, checked) Broker.SetMinimapVisibility(checked) end)
		container:AddChild(showMinimap)
	end
end

module.cli = {
	lootAll = {
		type = "toggle",
		name = L["Loot everything"],
		set = function(info, val) PRIVATE_TABLE.DB.lootAll = Util.GetBoolean(val) end,
		get = function(info) return PRIVATE_TABLE.DB.lootAll end
	}
}