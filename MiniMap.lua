local ADDON_NAME, PRIVATE_TABLE = ...;
local Util = PRIVATE_TABLE.GetTable("Util")
local Color = PRIVATE_TABLE.GetTable("Color")
local L = PRIVATE_TABLE.GetTable("L")
local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")

local print = Util.print
--local AUTO_LOOTER = PRIVATE_TABLE.GetTable("AUTO_LOOTER")

-- Call this in a mod's initialization to move the minimap button to its saved position (also used in its movement)
-- ** do not call from the mod's OnLoad, VARIABLES_LOADED or later is fine. **
function AutoLooter_MinimapButton_Reposition()
	AutoLooter_MinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52 - (80 * cos(PRIVATE_TABLE.DB.minimapPos)), (80 * sin(PRIVATE_TABLE.DB.minimapPos)) - 52)
end

-- Only while the button is dragged this is called every frame
function AutoLooter_MinimapButton_DraggingFrame_OnUpdate()

	local xpos, ypos = GetCursorPosition()
	local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin - xpos / UIParent:GetScale() + 70 -- get coordinates as differences from the center of the minimap
	ypos = ypos / UIParent:GetScale() - ymin - 70

	PRIVATE_TABLE.DB.minimapPos = math.deg(math.atan2(ypos, xpos)) -- save the degrees we are relative to the minimap center
	AutoLooter_MinimapButton_Reposition() -- move the button
end

-- Put your code that you want on a minimap button click here.  arg1="LeftButton", "RightButton", etc
function AutoLooter_MinimapButton_OnClick(self, button)
	if button == "LeftButton" then
		ConfigUI.CreateConfigUI()
	elseif button == "RightButton" then
		PRIVATE_TABLE.DB.lootAll = not PRIVATE_TABLE.DB.lootAll
		print(L["Loot everything"], ": ", Util.OnOff(PRIVATE_TABLE.DB.lootAll))
	end
end

function AutoLooter_MinimapButton_OnEnter(self)
	if (self.dragging) then
		return
	end

	GameTooltip:SetOwner(self or UIParent, "ANCHOR_LEFT")
	GameTooltip:SetText(Color.WHITE .. "AutoLooter|r\r"
			.. Color.YELLOW .. L["Left-click"] .. "|r " .. L["to Show/Hide UI"] .. "\r"
			.. Color.YELLOW .. L["Right-click"] .. "|r " .. L["to Enable/Disable loot all"] .. "\r"
			.. L["Hold and drag to move"])
end
