local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Util = PRIVATE_TABLE.Util
local ConfirmLootRoll = ConfirmLootRoll

local module = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("AutoConfirm", "AceEvent-3.0")

local function SetEnabled(enable)
	PRIVATE_TABLE.DB.autoConfirmRoll = enable

	if (PRIVATE_TABLE.DB.autoConfirmRoll) then
		module:Enable()
	else
		module:Disable()
	end
end

function module:OnEnable()
	self:RegisterEvent("CONFIRM_LOOT_ROLL") -- embeded AceEvent is automatically deregistered upon module disable
end

function module:OnInitialize()
	SetEnabled(PRIVATE_TABLE.DB.autoConfirmRoll)
end

function module:CONFIRM_LOOT_ROLL(_, id, rolltype)
	ConfirmLootRoll(id, rolltype)
end

function module:GetOptions()
	return {
		general = {
			args = {
				autoConfirmRoll = {
					type = "toggle",
					name = L["Auto confirm loot roll"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, value) SetEnabled(Util.GetBoolean(value)) end,
					get = function(info) return PRIVATE_TABLE.DB.autoConfirmRoll end
				},
			}
		},
	}
end