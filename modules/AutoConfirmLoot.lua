local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Util = PRIVATE_TABLE.Util
local ConfirmLootRoll = ConfirmLootRoll

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("AutoConfirm", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")

function module:CanEnable()
	return AutoLooter.db.profile.autoConfirmRoll
end

function module:InitializeDb()
	self.db = AutoLooter.db
end

function module:OnEnable()
	self:RegisterEvent("CONFIRM_LOOT_ROLL") -- embeded AceEvent is automatically deregistered upon module disable
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
					set = function(info, value) self:SetProfileVar("autoConfirmRoll", Util.GetBoolean(value)) end,
					get = function(info) return AutoLooter.db.profile.autoConfirmRoll end
				},
			}
		},
	}
end