local AceGUI = LibStub("AceGUI-3.0")

local chunk = 170 -- this makes checkboxes in different lines align

local function getClosestChunkSize(width)
	local d = math.ceil(width / chunk)
	return chunk * d
end

local function OnWidthSet(self, width)
	local newWidth = getClosestChunkSize(self.text:GetStringWidth() + 30)
	if newWidth > 0 and math.abs(newWidth - width) > 1 then
		self.text:SetWidth(newWidth)
		self:SetWidth(newWidth)
	end
end

local function Constructor()
	local checkBox = AceGUI:Create("CheckBox")
	local originalOnWithSet = checkBox.OnWidthSet
	checkBox.OnWidthSet = function(self, width)
		originalOnWithSet(self, width)
		OnWidthSet(self, width)
	end
	return checkBox
end

AceGUI:RegisterWidgetType("AutoLooter_WrapTextCheckBox", Constructor, 1)