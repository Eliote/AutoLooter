local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.L

local Util = PRIVATE_TABLE.Util
local ConfirmLootRoll = ConfirmLootRoll

local module = AutoLooter:NewLootModule(999999998)
local AutoConfirm = LibStub("AceAddon-3.0"):GetAddon("AutoLooter"):NewModule("AutoConfirm", "AceEvent-3.0")

local function SetEnabled(enable)
	PRIVATE_TABLE.DB.autoConfirmRoll = enable

	if (PRIVATE_TABLE.DB.autoConfirmRoll) then
		AutoConfirm:Enable()
	else
		AutoConfirm:Disable()
	end
end

function AutoConfirm:OnEnable()
	self:RegisterEvent("CONFIRM_LOOT_ROLL") -- embeded AceEvent is automatically deregistered upon module disable
end

function AutoConfirm:OnInitialize()
	SetEnabled(PRIVATE_TABLE.DB.autoConfirmRoll)
end

function AutoConfirm:CONFIRM_LOOT_ROLL(_, id, rolltype)
	ConfirmLootRoll(id, rolltype)
end

function module:GetOptions()
	return {
		general = {
			args = {
				autoConfirmRoll = {
					type = "toggle",
					name = L["Auto confirm loot roll"],
					set = function(info, value) SetEnabled(Util.GetBoolean(value)) end,
					get = function(info) return PRIVATE_TABLE.DB.autoConfirmRoll end
				},
			}
		},
	}
end