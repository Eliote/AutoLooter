local _, PRIVATE_TABLE = ...

local isDragonFlight = (LE_EXPANSION_LEVEL_CURRENT >= 9) -- DRAGONFLIGHT = 9
if (not isDragonFlight) then
	return
end

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Util = PRIVATE_TABLE.Util
local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("DragonflightOptions")

function module:OnInitialize()
	local defaults = {
		profile = {
			showLootAnimation = true,
		}
	}
	self.db = AutoLooter.db:RegisterNamespace("DragonflightOptions", defaults)
	LootFrame:HookScript("OnEvent", module.LOOT_SLOT_CLEARED)
end

function module:LOOT_SLOT_CLEARED(event, index)
	if (event == "LOOT_SLOT_CLEARED") then
		if (module.db.profile.showLootAnimation and LootFrame.selectedSlot ~= index) then
			local frame = LootFrame.ScrollBox:FindFrameByPredicate(function(frame)
				return frame:GetSlotIndex() == index
			end);
			if frame and frame.SlideOutRightAnim then
				frame:Show() -- blizzard hides the frame in this event when not auto-looting
				frame.SlideOutRightAnim:Restart()
				frame.SlideOutRightAnim:Play()
			end
		end
	end
end

function module:GetOptions()
	return {
		general = {
			args = {
				showLootAnimation = {
					type = "toggle",
					name = L["Try to show loot animation"],
					width = "double",
					set = function(info, val)
						module.db.profile.showLootAnimation = Util.GetBoolean(val)
					end,
					get = function(info)
						return module.db.profile.showLootAnimation
					end
				},
			}
		}
	}
end