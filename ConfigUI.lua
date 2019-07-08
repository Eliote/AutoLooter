local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")
local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")
local Util = PRIVATE_TABLE.GetTable("Util")

local AceGUI = LibStub("AceGUI-3.0")
local frame

ConfigUI.raritysMenu = {
	[-1] = "|cFFFF0000" .. L["Off"],
	[0] = Util.GetColorForRarity(0) .. _G["ITEM_QUALITY0_DESC"],
	[1] = Util.GetColorForRarity(1) .. _G["ITEM_QUALITY1_DESC"],
	[2] = Util.GetColorForRarity(2) .. _G["ITEM_QUALITY2_DESC"],
	[3] = Util.GetColorForRarity(3) .. _G["ITEM_QUALITY3_DESC"],
	[4] = Util.GetColorForRarity(4) .. _G["ITEM_QUALITY4_DESC"]
}

local function GetTabs()
	local tabs = {}
	local modules = PRIVATE_TABLE.MODULES

	for _, module in pairs(modules) do
		if (module.GetConfigTabs) then
			local moduleTabs = module.GetConfigTabs()

			local cType = type(moduleTabs)
			if (cType == "table") then
				for _, tab in pairs(moduleTabs) do
					tabs[tab] = 1
				end
			elseif (cType == "string") then
				tabs[moduleTabs] = 1
			end
		end
	end

	local returnTable = {}
	for name in pairs(tabs) do table.insert(returnTable, { text = name, value = name }) end
	return returnTable
end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
	container:ReleaseChildren()

	local modules = PRIVATE_TABLE.MODULES

	for _, module in pairs(modules) do
		if (module.CreateConfigGroup) then module.CreateConfigGroup(container, event, group) end
	end
end

function ConfigUI.CreateConfigUI()
	if frame and frame:IsShown() then
		frame:Release()
		return
	end

	frame = AceGUI:Create("Frame")
	frame:SetTitle("AutoLooter")
	--frame:SetStatusText("Example Container Frame")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	-- Fill Layout - the TabGroup widget will fill the whole frame
	frame:SetLayout("Fill")

	-- Create the TabGroup
	local tab = AceGUI:Create("TabGroup")
	tab:SetLayout("Flow")
	-- Setup which tabs to show
	tab:SetTabs(GetTabs())
	-- Register callback
	tab:SetCallback("OnGroupSelected", SelectGroup)
	-- Set initial Tab (this will fire the OnGroupSelected callback)
	tab:SelectTab(L["General"])

	-- add to the frame container
	frame:AddChild(tab)

	local old_CloseSpecialWindows
	if not old_CloseSpecialWindows then
		old_CloseSpecialWindows = CloseSpecialWindows
		CloseSpecialWindows = function()
			CloseSpecialWindows = old_CloseSpecialWindows

			if frame and frame:IsShown() then
				frame:Release()
				return true
			end
			return false
		end
	end
end
