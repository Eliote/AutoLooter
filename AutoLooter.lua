--[[
	Description: Loot only what you want and keep your precious bag slots free of trash.
	Author: Eliote
--]]

local ADDON_NAME, PRIVATE_TABLE = ...;
local MOD_VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

local L = PRIVATE_TABLE.GetTable("L")
local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")
local AUTO_LOOTER = PRIVATE_TABLE.GetTable("AUTO_LOOTER")
local DataBase = PRIVATE_TABLE.GetTable("DB")
local Util = PRIVATE_TABLE.GetTable("Util")
local Color = PRIVATE_TABLE.GetTable("Color")
local MODULES = PRIVATE_TABLE.GetTable("MODULES")

local print = Util.print
local formatGold = Util.formatGold

-- global calls runs 30% slower -- http://www.lua.org/gems/sample.pdf
local GetNumLootItems = GetNumLootItems
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local LootSlot = LootSlot
local GetItemInfo = GetItemInfo
local tonumber = tonumber
local CloseLoot = CloseLoot
local PlaySoundFile = PlaySoundFile
local RaidNotice_AddMessage = RaidNotice_AddMessage
local ConfirmLootSlot = ConfirmLootSlot
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local ConfirmLootRoll = ConfirmLootRoll
local string = string
--

-- LDB addition START
-- thanks to Pseudopath "http://wow.curseforge.com/profiles/Pseudopath/"
local AL_LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
	type = "launcher",
	icon = "Interface\\Icons\\Inv_misc_bag_01",
	label = ADDON_NAME
})
local LDBIcon = LibStub("LibDBIcon-1.0")

function AL_LDB.OnTooltipShow(tip)
	tip:AddLine(Color.WHITE .. ADDON_NAME)
	tip:AddLine(" ")
	tip:AddLine(Color.YELLOW .. L["Left-click"] .. "|r " .. L["to Show/Hide UI"])
	tip:AddLine(Color.YELLOW .. L["Right-click"] .. "|r " .. L["to Enable/Disable loot all"])
end

function AL_LDB.OnClick(self, button)
	if button == "LeftButton" then
		ConfigUI.CreateConfigUI();
	elseif button == "RightButton" then
		PRIVATE_TABLE.DB.lootAll = not PRIVATE_TABLE.DB.lootAll
		print(L["Loot everything"], ": ", Util.OnOff(PRIVATE_TABLE.DB.lootAll))
	end
end

-- LDB addition END

local questItemList

local function PrintLoot(descricao, cor, items, dinheiro)
	items = items:trim()
	if items ~= "" then
		if dinheiro then
			print(cor, descricao, "|r: ", "|cffffbb44[" .. items .. "]")
		else
			print(cor, descricao, "|r: ", items)
		end
	end
end

local function CreateQuestItemList()
	if not DataBase.lootQuest then return end

	local itemList = {}

	for questIndex = 1, GetNumQuestLogEntries() do
		for boardIndex = 1, GetNumQuestLeaderBoards(questIndex) do
			local leaderboardTxt, boardItemType, isDone = GetQuestLogLeaderBoard(boardIndex, questIndex)

			if not isDone and boardItemType == "item" then
				-- i, j, numItems, numNeeded, itemName
				local _, _, _, _, itemName = string.find(leaderboardTxt, "([%d]+)%s*/%s*([%d]+)%s*(.*)%s*")

				if itemName then
					itemList[itemName] = true
				end
			end
		end
	end

	return itemList
end

function AUTO_LOOTER.GetBoolean(bool, def)
	if (bool == "on" or bool == true) then
		return true
	elseif (bool == "off" or bool == false) then
		return false
	end

	if not def then return false end

	return def
end

function AUTO_LOOTER.Enable(bool)
	DataBase.enable = AUTO_LOOTER.GetBoolean(bool, not DataBase.enable)

	if DataBase.enable then
		AUTO_LOOTER:RegisterEvent("CONFIRM_LOOT_ROLL")
		AUTO_LOOTER:RegisterEvent("LOOT_OPENED")
		AUTO_LOOTER:RegisterEvent("QUEST_LOG_UPDATE") -- register UNIT_QUEST_LOG_CHANGED after first run
		questItemList = CreateQuestItemList()
		DataBase.enable = true
		print(L["Enabled"])
	else
		AUTO_LOOTER:UnregisterEvent("CONFIRM_LOOT_ROLL")
		AUTO_LOOTER:UnregisterEvent("LOOT_OPENED")
		AUTO_LOOTER:UnregisterEvent("QUEST_LOG_UPDATE")
		AUTO_LOOTER:UnregisterEvent("UNIT_QUEST_LOG_CHANGED")
		questItemList = nil
		DataBase.enable = false
		print(L["Disabled"])
	end
end

function AUTO_LOOTER.AddItem(sTitle, list)
	if not sTitle or sTitle == "" then
		sTitle = GameTooltip:GetItem()

		if not sTitle or sTitle == "" then
			for k, _ in pairs(list) do
				print(k)
			end

			return
		end
	end

	local sName = GetItemInfo(sTitle)

	if not sName then print(L["Invalid item"], ": ", sTitle); return end

	if (list[sName]) then
		print(L["Already in the list"], ": ", Color.YELLOW, sName)
		return
	end

	list[sName] = true
	print(L["Added"], ": ", Color.YELLOW, sName)
end

function AUTO_LOOTER.RemoveItem(sTitle, list)
	if not sTitle or sTitle == "" then
		sTitle = GameTooltip:GetItem()

		if not sTitle or sTitle == "" then
			for k, _ in pairs(list) do
				print(k)
			end

			return
		end
	end

	local sName = GetItemInfo(sTitle)

	if (list[sName]) then
		list[sName] = nil
		print(L["Removed"], ": ", Color.YELLOW, sName)
		return
	end

	print(L["Not listed"], ": ", Color.YELLOW, sName)
end

function AUTO_LOOTER:SetAlertSound(file)
	DataBase.alertSound = file
end

function AUTO_LOOTER.SetMinimapVisibility(show)
	DataBase.minimap.hide = not show

	print(DataBase.minimap.hide)
	if (DataBase.minimap.hide) then
		LDBIcon:Hide(ADDON_NAME)
	else
		LDBIcon:Show(ADDON_NAME)
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
			add = {
				type = "input",
				name = L["Add item to white list"],
				set = function(info, val) AUTO_LOOTER.AddItem(val, DataBase.items) end,
				get = false,
				usage = L["[link/id/name] or [mouse over]"]
			},
			ignore = {
				type = "input",
				name = L["Add item to ignore list"],
				set = function(info, val) AUTO_LOOTER.AddItem(val, DataBase.ignore) end,
				get = false
			},
			alert = {
				type = "input",
				name = L["Add item to alert list"],
				set = function(info, val) AUTO_LOOTER.AddItem(val, DataBase.alert) end,
				get = false
			},
			remove = {
				type = "input",
				name = L["Remove item from white list"],
				set = function(info, val) AUTO_LOOTER.RemoveItem(val, DataBase.items) end,
				get = false
			},
			removeI = {
				type = "input",
				name = L["Remove item from ignore list"],
				set = function(info, val) AUTO_LOOTER.RemoveItem(val, DataBase.ignore) end,
				get = false
			},
			removeA = {
				type = "input",
				name = L["Remove item from alert list"],
				set = function(info, val) AUTO_LOOTER.RemoveItem(val, DataBase.alert) end,
				get = false
			},
			enable = {
				type = "toggle",
				name = L["Enable"],
				--desc = L["Enable/Disable the addon"],
				set = function(info, val) AUTO_LOOTER.Enable(val) end,
				get = function(info) return DataBase.enable end
			},
			printout = {
				type = "toggle",
				name = L["Printout items looted"],
				set = function(info, val) DataBase.printout = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.printout end
			},
			printoutIgnored = {
				type = "toggle",
				name = L["Printout items ignored"],
				set = function(info, val) DataBase.printoutIgnored = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.printoutIgnored end
			},
			printoutType = {
				type = "toggle",
				name = L["Printout items type"],
				set = function(info, val) DataBase.printoutType = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.printoutType end
			},
			lootAll = {
				type = "toggle",
				name = L["Loot everything"],
				set = function(info, val) DataBase.lootAll = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.lootAll end
			},
			lootQuest = {
				type = "toggle",
				name = L["Loot quest itens"],
				set = function(info, val) DataBase.lootQuest = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.lootQuest end
			},
			close = {
				type = "toggle",
				name = L["Close after loot"],
				set = function(info, val) DataBase.close = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.close end
			},
			ignoreGreys = {
				type = "toggle",
				name = L["Ignore greys when looting by type"],
				set = function(info, val) DataBase.ignoreGreys = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.ignoreGreys end
			},
			ignoreBop = {
				type = "toggle",
				name = L["Ignore BoP"],
				set = function(info, val) DataBase.ignoreBop = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.ignoreBop end
			},
			autoConfirmRoll = {
				type = "toggle",
				name = L["Auto confirm loot roll"],
				set = function(info, val) DataBase.autoConfirmRoll = AUTO_LOOTER.GetBoolean(val) end,
				get = function(info) return DataBase.autoConfirmRoll end
			},
			rarity = {
				type = "select",
				name = L["Rarity"],
				values = ConfigUI.raritysMenu,
				set = function(info, val) DataBase.rarity = val end,
				get = function(info) return DataBase.rarity end
			},
			price = {
				type = "range",
				name = L["Price (in coppers)"],
				min = 0,
				max = 10000000,
				step = 1,
				set = function(info, val) DataBase.price = val end,
				get = function(info) return DataBase.price end
			},
			alertSound = {
				type = "input",
				name = L["Set alert sound"],
				set = function(info, val) AUTO_LOOTER.SetAlertSound(val) end,
				get = false
			},
			showMinimap = {
				type = "toggle",
				name = L["Show/Hide minimap button"],
				set = function(info, val) AUTO_LOOTER.SetMinimapVisibility(val) end,
				get = function(info) return not DataBase.minimap.hide end
			},
			config = {
				type = "execute",
				name = L["Show/Hide UI"],
				func = function() ConfigUI.CreateConfigUI() end
			},
		}
	}

	local AceConfig = LibStub("AceConfig-3.0")
	AceConfig:RegisterOptionsTable("AutoLooter-Commands", self.options, { "al", "autolooter", "atl" })
	AceConfig:RegisterOptionsTable("AutoLooter", { type = "group", name = "AutoLooter", args = { enable = self.options.args.enable } })
	AceConfig:RegisterOptionsTable("AutoLooter-Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))

	local AceDialog = LibStub("AceConfigDialog-3.0")
	self.optionsFrame = AceDialog:AddToBlizOptions("AutoLooter", "AutoLooter")
	self.profilesFrame = AceDialog:AddToBlizOptions("AutoLooter-Profiles", "Profiles", "AutoLooter")

	LDBIcon:Register(ADDON_NAME, AL_LDB, DataBase.minimap)
end

local function GetSaved(defTable, itemClass, itemSubClass)
	if not defTable then return false end

	local t = defTable[itemClass]
	if t then return t[itemSubClass] end
end

local function CreateAHTable(defTable)
	local out = {}

	local itemClasses = {
		LE_ITEM_CLASS_WEAPON,
		LE_ITEM_CLASS_ARMOR,
		LE_ITEM_CLASS_CONTAINER,
		LE_ITEM_CLASS_GEM,
		LE_ITEM_CLASS_ITEM_ENHANCEMENT,
		LE_ITEM_CLASS_CONSUMABLE,
		LE_ITEM_CLASS_GLYPH,
		LE_ITEM_CLASS_TRADEGOODS,
		LE_ITEM_CLASS_RECIPE,
		LE_ITEM_CLASS_BATTLEPET,
		LE_ITEM_CLASS_QUESTITEM,
		LE_ITEM_CLASS_MISCELLANEOUS,
	};

	for _, itemClass in pairs(itemClasses) do
		local t = {}
		local classInfo = GetItemClassInfo(itemClass)

		local itemSubClasses = { GetAuctionItemSubClasses(itemClass) };
		if #itemSubClasses > 0 then
			for _, itemSubClass in pairs(itemSubClasses) do
				local subclassInfo, _ = GetItemSubClassInfo(itemClass, itemSubClass)
				t[subclassInfo] = GetSaved(defTable, classInfo, subclassInfo)
			end
		else
			t[classInfo] = GetSaved(defTable, classInfo, classInfo)
		end

		--t["(Legacy Types)"] = GetSaved(defTable, itemClass, "(Legacy Types)")
		out[classInfo] = t
	end

	return out
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
			typeTable = CreateAHTable(),
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

	self.db.profile.typeTable = CreateAHTable(self.db.profile.typeTable)

	AUTO_LOOTER:ReloadOptions()

	AUTO_LOOTER:CreateProfile()

	DEFAULT_CHAT_FRAME:AddMessage(Color.BLUE .. "AutoLooter" .. Color.WHITE .. " || v" .. MOD_VERSION .. " || " .. Color.YELLOW .. "/autolooter /al /atl|r")
end

local function DoAlert(sTitle, nIndex)
	if DataBase.alert[sTitle] then
		if DataBase.alertSound then
			PlaySoundFile(DataBase.alertSound) -- safe
		end

		RaidNotice_AddMessage(RaidWarningFrame, GetLootSlotLink(nIndex), ChatTypeInfo["RAID_WARNING"])
	end
end

local function Loot(index, itemName)
	DoAlert(itemName, index)
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

	local sortedModules = {}
	for n in pairs(MODULES) do table.insert(sortedModules, n) end
	table.sort(sortedModules)

	local reasonMap = {}

	for nIndex = 1, GetNumLootItems() do
		local icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive = GetLootSlotInfo(nIndex)
		local sItemLink = GetLootSlotLink(nIndex)

		for k, moduleIndex in ipairs(sortedModules) do
			local module = MODULES[moduleIndex]
			if (module.CanLoot) then
				local loot, reason, reasonContent, forceBreak = module.CanLoot(sItemLink, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)

				if (reason) then
					reasonMap[reason] = reasonMap[reason] or {}
					table.insert(reasonMap[reason], reasonContent)
				end

				if loot then
					Loot(nIndex, sTitle)
					break
				end

				if forceBreak then break end
			end
		end
	end

	for _, moduleIndex in ipairs(sortedModules)  do
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

-- QUEST_LOG_UPDATE
function AUTO_LOOTER:QUEST_LOG_UPDATE()
	AUTO_LOOTER:UnregisterEvent("QUEST_LOG_UPDATE")

	AUTO_LOOTER:RegisterEvent("UNIT_QUEST_LOG_CHANGED")

	questItemList = CreateQuestItemList()
end

-- UNIT_QUEST_LOG_CHANGED
function AUTO_LOOTER:UNIT_QUEST_LOG_CHANGED(unitId)
	if unitId == "player" then
		questItemList = CreateQuestItemList()
	end
end