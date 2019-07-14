--[[
	Description: Loot only what you want and keep your precious bag slots free of trash.
	Author: Eliote
--]]

local ADDON_NAME, PRIVATE_TABLE = ...
local MOD_VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

local L = PRIVATE_TABLE.GetTable("L")
local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")
local AUTO_LOOTER = PRIVATE_TABLE.GetTable("AUTO_LOOTER")
local DataBase = PRIVATE_TABLE.GetTable("DB")
local Util = PRIVATE_TABLE.GetTable("Util")
local Color = PRIVATE_TABLE.GetTable("Color")
local MODULES = PRIVATE_TABLE.GetTable("MODULES")
local Broker = PRIVATE_TABLE.GetTable("Broker")

local print = Util.print

-- global calls runs 30% slower -- http://www.lua.org/gems/sample.pdf
local GetNumLootItems = GetNumLootItems
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local LootSlot = LootSlot
local ConfirmLootSlot = ConfirmLootSlot
local ConfirmLootRoll = ConfirmLootRoll
--

local sortedLootModules = {}
local sortedModules = {}

function AUTO_LOOTER.Enable(bool)
	DataBase.enable = Util.GetBoolean(bool, not DataBase.enable)

	if DataBase.enable then
		AUTO_LOOTER:RegisterEvent("CONFIRM_LOOT_ROLL")
		AUTO_LOOTER:RegisterEvent("LOOT_OPENED")
		DataBase.enable = true
		print(L["Enabled"])
	else
		AUTO_LOOTER:UnregisterEvent("CONFIRM_LOOT_ROLL")
		AUTO_LOOTER:UnregisterEvent("LOOT_OPENED")
		DataBase.enable = false
		print(L["Disabled"])
	end
end

function AUTO_LOOTER:ReloadOptions()
	PRIVATE_TABLE.DB = self.db.profile
	DataBase = PRIVATE_TABLE.DB

	AUTO_LOOTER.Enable(DataBase.enable)
end

function AUTO_LOOTER:CreateProfile()
	self.options = {
		type = "group",
		name = "AutoLooter",
		args = {
			config = {
				type = "execute",
				name = L["Show/Hide UI"],
				func = function() ConfigUI.CreateConfigUI() end,
				hidden = true
			},
			general = {
				name = L["General"],
				type = "group",
				args = {
					enable = {
						type = "toggle",
						name = L["Enable"],
						set = function(info, val) AUTO_LOOTER.Enable(val) end,
						get = function(info) return DataBase.enable end
					},
					printout = {
						type = "toggle",
						name = L["Printout items looted"],
						set = function(info, val) DataBase.printout = Util.GetBoolean(val) end,
						get = function(info) return DataBase.printout end
					},
					printoutIgnored = {
						type = "toggle",
						name = L["Printout items ignored"],
						set = function(info, val) DataBase.printoutIgnored = Util.GetBoolean(val) end,
						get = function(info) return DataBase.printoutIgnored end
					},
					close = {
						type = "toggle",
						name = L["Close after loot"],
						set = function(info, val) DataBase.close = Util.GetBoolean(val) end,
						get = function(info) return DataBase.close end
					},
					autoConfirmRoll = {
						type = "toggle",
						name = L["Auto confirm loot roll"],
						set = function(info, val) DataBase.autoConfirmRoll = Util.GetBoolean(val) end,
						get = function(info) return DataBase.autoConfirmRoll end
					},
					showMinimap = {
						type = "toggle",
						name = L["Show/Hide minimap button"],
						width = "double",
						set = function(info, val) Broker.SetMinimapVisibility(val) end,
						get = function(info) return not DataBase.minimap.hide end
					}
				}
			},
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

-- CONFIRM_LOOT_ROLL
function AUTO_LOOTER:CONFIRM_LOOT_ROLL(_, id, rolltype)
	if DataBase.autoConfirmRoll then
		ConfirmLootRoll(id, rolltype)
	end
end