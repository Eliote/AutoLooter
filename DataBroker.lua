local ADDON_NAME, PRIVATE_TABLE = ...

local L = PRIVATE_TABLE.GetTable("L")
local Util = PRIVATE_TABLE.GetTable("Util")
local Color = PRIVATE_TABLE.GetTable("Color")
local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")
local Broker = PRIVATE_TABLE.GetTable("Broker")

local print = Util.print

-- thanks to Pseudopath "http://wow.curseforge.com/profiles/Pseudopath/"
local AL_LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
	type = "launcher",
	icon = "Interface\\Icons\\Inv_misc_bag_01",
	label = ADDON_NAME
})
local LDBIcon = LibStub("LibDBIcon-1.0")

function AL_LDB.OnTooltipShow(tip)
	tip:AddLine(Color.WHITE .. ADDON_NAME)
	tip:AddLine(" ")
	tip:AddLine(Color.YELLOW .. L["Left-click"] .. "|r " .. L["to Show/Hide UI"])
	tip:AddLine(Color.YELLOW .. L["Right-click"] .. "|r " .. L["to Enable/Disable loot all"])
end

function AL_LDB.OnClick(self, button)
	if button == "LeftButton" then
		ConfigUI.CreateConfigUI();
	elseif button == "RightButton" then
		PRIVATE_TABLE.DB.lootAll = not PRIVATE_TABLE.DB.lootAll
		print(L["Loot everything"], ": ", Util.OnOff(PRIVATE_TABLE.DB.lootAll))
	end
end

function Broker.Init()
	LDBIcon:Register(ADDON_NAME, AL_LDB, PRIVATE_TABLE.DB.minimap)
end

function Broker.SetMinimapVisibility(show)
	PRIVATE_TABLE.DB.minimap.hide = not show

	if (show) then
		LDBIcon:Show(ADDON_NAME)
	else
		LDBIcon:Hide(ADDON_NAME)
	end
end