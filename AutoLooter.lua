--[[
	Description: Loot only what you want and keep your precious bag slots free of trash.
	Author: Eliote
--]]

local ADDON_NAME, PRIVATE_TABLE = ...
local MOD_VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

local AUTO_LOOTER = LibStub("AceAddon-3.0"):NewAddon("AutoLooter", "AceEvent-3.0")

local L = PRIVATE_TABLE.L
local DataBase = PRIVATE_TABLE.DB
local Util = PRIVATE_TABLE.Util
local Color = PRIVATE_TABLE.Color
local MODULES = PRIVATE_TABLE.MODULES
local Broker = PRIVATE_TABLE.Broker

local print = Util.print

-- global calls runs 30% slower -- http://www.lua.org/gems/sample.pdf
local GetNumLootItems = GetNumLootItems
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local LootSlot = LootSlot
local ConfirmLootSlot = ConfirmLootSlot
--

local sortedLootModules = {}
local sortedModules = {}

function AUTO_LOOTER.Toggle(bool)
	DataBase.enable = Util.GetBoolean(bool, not DataBase.enable)

	if DataBase.enable then
		AUTO_LOOTER:Enable()
		AUTO_LOOTER:RegisterEvent("LOOT_OPENED")
		DataBase.enable = true
		print(L["Enabled"])
	else
		AUTO_LOOTER:Disable()
		AUTO_LOOTER:UnregisterEvent("LOOT_OPENED")
		DataBase.enable = false
		print(L["Disabled"])
	end
end

function AUTO_LOOTER:ReloadOptions()
	PRIVATE_TABLE.DB = self.db.profile
	DataBase = PRIVATE_TABLE.DB

	AUTO_LOOTER.Toggle(DataBase.enable)
end

function AUTO_LOOTER:CreateProfile()
	self.options = {
		type = "group",
		name = "AutoLooter",
		args = {
			config = {
				type = "execute",
				name = L["Show/Hide UI"],
				func = function() LibStub("AceConfigDialog-3.0"):Open(ADDON_NAME) end,
				hidden = true
			},
			general = {
				name = L["General"],
				type = "group",
				args = {}
			}
		}
	}

	self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profile.order = -1

	for _, module in pairs(MODULES) do
		if (module.GetOptions) then
			Util.mergeTable(self.options.args, module:GetOptions())
		end
	end

	local AceConfig = LibStub("AceConfig-3.0")
	AceConfig:RegisterOptionsTable("AutoLooter", self.options, { "al", "autolooter", "atl" })

	local AceDialog = LibStub("AceConfigDialog-3.0")
	self.optionsFrame = AceDialog:AddToBlizOptions("AutoLooter")

	Broker.Init()
end

function AUTO_LOOTER:OnInitialize()
	local defaults = {
		profile = {
			items = {},
			ignore = {},
			alert = {},
			enable = true,
			printout = true,
			printoutIgnored = false,
			printType = false,
			lootAll = false,
			lootQuest = true,
			close = false,
			rarity = 2,
			price = 40000,
			alertSound = "Sound/creature/Murloc/mMurlocAggroOld.ogg",
			typeTable = {}, --CreateAHTable(),
			ignoreGreys = false,
			autoConfirmRoll = false,
			minimap = { hide = false },
			ignoreBop = false
		}
	}
	self.db = LibStub("AceDB-3.0"):New("AutoLooterDB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "ReloadOptions")
	self.db.RegisterCallback(self, "OnProfileCopied", "ReloadOptions")
	self.db.RegisterCallback(self, "OnProfileReset", "ReloadOptions")

	AUTO_LOOTER:ReloadOptions()
	AUTO_LOOTER:CreateProfile()

	for n in pairs(MODULES) do
		table.insert(sortedModules, n)
		if (MODULES[n].CanLoot) then
			table.insert(sortedLootModules, n)
		end
	end
	table.sort(sortedModules)
	table.sort(sortedLootModules)

	DEFAULT_CHAT_FRAME:AddMessage(Color.BLUE .. "AutoLooter" .. Color.WHITE .. " || v" .. MOD_VERSION .. " || " .. Color.YELLOW .. "/autolooter /al /atl|r")
end

local function Loot(index, itemName, itemLink)
	LootSlot(index)
	ConfirmLootSlot(index) -- In case it's a Bind on Pickup
end

local function PrintReason(reason, contents)
	local items = ""
	local sep = ""
	for _, content in pairs(contents) do
		items = sep .. items .. content
		sep = " "
	end

	print(reason, "|r: ", items)
end

-- LOOT OPENED
function AUTO_LOOTER:LOOT_OPENED(_, arg1)
	if (arg1 == 1) then return end

	local reasonMap = {}

	for nIndex = 1, GetNumLootItems() do
		local icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(nIndex)
		local sItemLink = GetLootSlotLink(nIndex)

		for k, moduleIndex in ipairs(sortedLootModules) do
			local module = MODULES[moduleIndex]
			local loot, reason, reasonContent, forceBreak = module.CanLoot(sItemLink, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)

			if (reason) then
				reasonMap[reason] = reasonMap[reason] or {}
				table.insert(reasonMap[reason], reasonContent)
			end

			if loot then
				Loot(nIndex, sTitle, sItemLink)
				break
			end

			if forceBreak then break end
		end
	end

	for _, moduleIndex in ipairs(sortedModules) do
		local module = MODULES[moduleIndex]
		if (module.Finish) then module.Finish() end
	end

	for reason, contents in pairs(reasonMap) do
		PrintReason(reason, contents)
	end
end