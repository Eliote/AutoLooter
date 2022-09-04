local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Util = PRIVATE_TABLE.Util
local Color = PRIVATE_TABLE.Color

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("DataBroker")

-- thanks to Pseudopath "http://wow.curseforge.com/profiles/Pseudopath/"
local AL_LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
	type = "launcher",
	icon = "Interface\\Icons\\Inv_misc_bag_01",
	label = ADDON_NAME
})
local LDBIcon = LibStub("LibDBIcon-1.0")

local isMainLine = WOW_PROJECT_MAINLINE == WOW_PROJECT_ID
local iconMouseLeft = isMainLine and "|A:newplayertutorial-icon-mouse-leftbutton:0:0|a " or ""
local iconMouseRight = isMainLine and "|A:newplayertutorial-icon-mouse-rightbutton:0:0|a " or ""
function AL_LDB.OnTooltipShow(tip)
	tip:AddLine(Color.WHITE .. ADDON_NAME)
	tip:AddLine(" ")
	tip:AddLine(iconMouseLeft .. Color.YELLOW .. L["Left-click"] .. "|r " .. L["to Show/Hide UI"])
	tip:AddLine(iconMouseRight .. Color.YELLOW .. L["Right-click"] .. "|r " .. L["to Enable/Disable loot all"])
end

function AL_LDB.OnClick(self, button)
	if button == "LeftButton" then
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")
		local frame = AceConfigDialog.OpenFrames[ADDON_NAME]
		if (frame and frame:IsShown()) then
			AceConfigDialog:Close(ADDON_NAME)
		else
			AceConfigDialog:Open(ADDON_NAME)
		end
	elseif button == "RightButton" then
		AutoLooter.db.profile.lootAll = not AutoLooter.db.profile.lootAll
		AutoLooter.print(L["Loot everything"], ": ", Util.OnOff(AutoLooter.db.profile.lootAll))
	end
end

function module.SetMinimapVisibility(show)
	AutoLooter.db.profile.minimap.hide = not show

	if (show) then
		LDBIcon:Show(ADDON_NAME)
	else
		LDBIcon:Hide(ADDON_NAME)
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				showMinimap = {
					type = "toggle",
					name = L["Show/Hide minimap button"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, val) module.SetMinimapVisibility(val) end,
					get = function(info) return not AutoLooter.db.profile.minimap.hide end
				}
			}
		},
	}
end

function module:OnInitialize()
	LDBIcon:Register(ADDON_NAME, AL_LDB, AutoLooter.db.profile.minimap)
end