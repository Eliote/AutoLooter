local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util
local SKINNABLE_TEXT = UNIT_SKINNABLE_LEATHER

local module = AutoLooter:NewModule("Skinning", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 1200

local reason = Color.DARK_BLUE .. L["Skinning"]

local skinnableUnitsCache = {}

local nop = function() end
local IsSecret = issecretvalue or nop

function module:CanEnable()
	return module.db.profile.enableSkinningLoot
end

function module:InitializeDb()
	local defaults = { profile = { enableSkinningLoot = false } }
	self.db = AutoLooter.db:RegisterNamespace("SkinningModule", defaults)
	module:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "UPDATE_MOUSEOVER_UNIT")
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive, lootSlot)
	if (module.db.profile.enableSkinningLoot and module:IsLootSkinning(lootSlot)) then
		return true, reason, AutoLooter.FormatLoot(icon, link, nQuantity), nil
	end
end

function module:AddIdToCache(id)
	if (not id) then return end
	--print("unit added: " .. id)
	skinnableUnitsCache[id] = true
end

function module:IsLootSkinning(lootSlot)
	local sources = { AutoLooter.GetLootSourceInfo(lootSlot) }
	-- if any of the sources for a slot is from a skinnable unit, we need to loot it
	for i = 1, #sources, 2 do
		local guid = sources[i]
		if (module:IsGUIDFromSkinnable(guid)) then
			return true
		end
	end
	return false
end

function module:IsGUIDFromSkinnable(guid)
	local id = module:GetIDFromGUID(guid)
	if (skinnableUnitsCache[id]) then
		return true
	end

	if not (C_TooltipInfo and C_TooltipInfo.GetHyperlink) then
		return false
	end

	local data = C_TooltipInfo.GetHyperlink("unit:" .. guid)
	if (module:IsTooltipDataSkinnable(data)) then
		module:AddIdToCache(id)
		return true
	end

	return false
end

function module:GetIDFromGUID(guid)
	if not guid or IsSecret(guid) then
		return
	end

	-- [unitType]-0-[serverID]-[instanceID]-[zoneUID]-[ID]-[spawnUID]
	local unitType, _, _, _, _, id = strsplit("-", guid)
	if unitType == "Creature" or unitType == "Vehicle" then
		return id
	end
end

function module:UPDATE_MOUSEOVER_UNIT()
	if not UnitExists("mouseover") or not UnitIsDead("mouseover") then
		return
	end

	local guid = UnitGUID("mouseover")
	if not guid or IsSecret(guid) then
		return
	end

	local id = module:GetIDFromGUID(guid)
	if skinnableUnitsCache[id] then
		return
	end

	if module:IsUnitTooltipSkinnable("mouseover") then
		module:AddIdToCache(id)
	end
end

function module:IsUnitTooltipSkinnable(unit)
	if C_TooltipInfo and C_TooltipInfo.GetUnit then
		local data = C_TooltipInfo.GetUnit(unit)
		return module:IsTooltipDataSkinnable(data)
	end

	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		if line and line:GetText() == SKINNABLE_TEXT then
			local r, g, b = line:GetTextColor()
			local lineColor = CreateColor(r, g, b)
			return module:CanSkin(lineColor)
		end
	end
	return false
end

function module:IsTooltipDataSkinnable(data)
	if data and data.lines then
		for _, line in ipairs(data.lines) do
			if line.leftText == SKINNABLE_TEXT then
				return module:CanSkin(line.leftColor)
			end
		end
	end
end

function module:AreColorsSimilar(c1, c2, delta)
	local r1, g1, b1 = c1:GetRGB()
	local r2, g2, b2 = c2:GetRGB()
	delta = delta or 0.025
	local rd, gd, bd = math.abs(r1 - r2), math.abs(g1 - g2), math.abs(b1 - b2)
	return rd < delta and gd < delta and bd < delta
end

function module:CanSkin(color)
	if (color and module:AreColorsSimilar(color, RED_FONT_COLOR)) then
		return false
	end
	return true
end

function module:GetOptions()
	return {
		skinning = {
			name = L["Skinning"],
			type = "group",
			args = {
				skinningLoot = {
					type = "toggle",
					width = "double",
					name = L["Loot everything from skinnable enemies"],
					dialogControl = "AutoLooter_WrapTextCheckBox",
					set = function(info, value) self:SetProfileVar("enableSkinningLoot", Util.GetBoolean(value)) end,
					get = function(info) return self.db.profile.enableSkinningLoot end,
				},
			}
		}
	}
end