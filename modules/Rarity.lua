local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(700)
local reason = Color.GREEN .. L["Rarity"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	if (PRIVATE_TABLE.DB.rarity > -1) and nRarity and (nRarity >= PRIVATE_TABLE.DB.rarity) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end


-- Config
local AceGUI = LibStub("AceGUI-3.0")
local tab = L["Rarity"]
local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")

function module.GetConfigTabs()
	return tab
end

local function Rarity_OnValueChanged(self, event, value)
	PRIVATE_TABLE.DB.rarity = value
end

function module.CreateConfigGroup(container, event, group)
	if (group == tab) then
		local rarity = AceGUI:Create("Dropdown")
		rarity:SetList(ConfigUI.raritysMenu)
		rarity:SetValue(PRIVATE_TABLE.DB.rarity)
		rarity:SetCallback("OnValueChanged", Rarity_OnValueChanged)
		rarity:SetLabel(L["Rarity"])
		rarity:SetWidth(120)
		container:AddChild(rarity)
	end
end

module.cli = {
	rarity = {
		type = "select",
		name = L["Rarity"],
		values = ConfigUI.raritysMenu,
		set = function(info, val) PRIVATE_TABLE.DB.rarity = val end,
		get = function(info) return PRIVATE_TABLE.DB.rarity end
	}
}