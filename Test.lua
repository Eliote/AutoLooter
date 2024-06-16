local _, PRIVATE_TABLE = ...

local module = AutoLooter:NewModule("TestModule", PRIVATE_TABLE.ToggleableModulePrototype)
local C = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

function module:CanEnable()
	return true
end

function module:InitializeDb()
	local defaults = { profile = { debugPrint = false } }
	self.db = AutoLooter.db:RegisterNamespace("TestModule", defaults)
end

function module.PrintDebug(...)
	if (module.db.profile.debug) then
		AutoLooter.print(...)
	end
end

local function RunCatching(func)
	local success, msg = pcall(func)
	if (not success) then
		AutoLooter.print(C.RED, "Error: |r", C.YELLOW, msg)
	end
end

function module.Test(func, name)
	local original_GetNumLootItems = AutoLooter.GetNumLootItems
	local original_GetLootSlotType = AutoLooter.GetLootSlotType
	local original_GetLootSlotInfo = AutoLooter.GetLootSlotInfo
	local original_GetLootSlotLink = AutoLooter.GetLootSlotLink
	local original_LootSlot = AutoLooter.LootSlot
	local original_ConfirmLootSlot = AutoLooter.ConfirmLootSlot

	local result = {
		LootSlot = {}
	}

	local lootTable = {
		-- lootIcon, lootName, lootQuantity, currencyID, lootQuality, locked, isQuestItem, questID, isActive
		{
			info = { 627315, "Capelo da Garça Vermelha", 1, nil, 3, false, nil, nil },
			link = "|cff1eff00|Hitem:214255::::::::70:270:::::::::|h[Capelo da Garça Vermelha]|h|r",
			type = Enum.LootSlotType.Item,
		},
		{
			info = { 0, GetCoinText(10203):gsub(", ", "\n"), 0, nil, nil, false, nil, nil },
			link = GetCoinText(10203),
			type = Enum.LootSlotType.Money,
		},
		{
			info = { 4638724, "Bronze", 20, 2778, 1, false, nil, nil },
			link = "|cffffffff|Hcurrency:2778:0|h[Bronze]|h|r",
			type = Enum.LootSlotType.Currency,
		},
		{
			info = { 134414, "Pedra de Regresso", 1, nil, 1, false, nil, nil },
			link = "|cffffffff|Hitem:6948::::::::70:270:::::::::|h[Pedra de Regresso]|h|r",
			type = Enum.LootSlotType.Item,
		},
	}

	AutoLooter.GetNumLootItems = function()
		local r = #lootTable
		module.PrintDebug("GetNumLootItems() -> ", r)
		return r
	end
	AutoLooter.GetLootSlotType = function(index)
		local r = lootTable[index].type
		module.PrintDebug("GetLootSlotType: (", index, ") -> ", r)
		return r
	end
	AutoLooter.GetLootSlotInfo = function(index)
		local r = lootTable[index].info
		module.PrintDebug("GetLootSlotInfo: (", index, ") -> ", unpack(r))
		return unpack(r)
	end
	AutoLooter.GetLootSlotLink = function(index)
		local r = lootTable[index].link
		module.PrintDebug("GetLootSlotLink: (", index, ") -> ", r)
		return r
	end
	AutoLooter.LootSlot = function(index)
		result.LootSlot[index] = true
		module.PrintDebug("LootSlot: (", index, ")")
	end
	AutoLooter.ConfirmLootSlot = function(index)
		module.PrintDebug("ConfirmLootSlot: (", index, ")")
	end

	local success, msg = pcall(func, result)
	if (success) then
		AutoLooter.print(name, " ", C.GREEN, "Success!|r")
	else
		AutoLooter.print(name, " ", C.RED, "Error: |r", C.YELLOW, msg)
	end

	AutoLooter.GetNumLootItems = original_GetNumLootItems
	AutoLooter.GetLootSlotType = original_GetLootSlotType
	AutoLooter.GetLootSlotInfo = original_GetLootSlotInfo
	AutoLooter.GetLootSlotLink = original_GetLootSlotLink
	AutoLooter.LootSlot = original_LootSlot
	AutoLooter.ConfirmLootSlot = original_ConfirmLootSlot
end

local function CreateDefConf()
	AutoLooter.db.profile = {
		items = {},
		ignore = {},
		alert = {},
		enable = true,
		printout = true,
		printoutIgnored = true,
		printType = true,
		lootAll = false,
		lootQuest = false,
		close = false,
		rarity = {},
		price = 0,
		alertSound = "Sound/creature/Murloc/mMurlocAggroOld.ogg",
		typeTable = {},
		ignoreGreys = false,
		autoConfirmRoll = false,
		ignoreBop = false,
		printoutReason = true,
		lootEarly = false,
		printLoginCommands = false,
		printoutIconOnly = true,
	}
end

local function UpdateStates()
	AutoLooter:ResetModulesCache()
	for _, m in AutoLooter:IterateModules() do
		if (m.UpdateState) then
			m:UpdateState()
		end
	end

end

local function MockingProfile(func)
	local tmp = AutoLooter.db.profile
	RunCatching(function()
		CreateDefConf()
		func()
		UpdateStates()
	end)
	AutoLooter.db.profile = tmp
end

local tests = {
	BaseTest = function(result)
		MockingProfile(function()
			UpdateStates()
			AutoLooter:Loot()
		end)
		assert(not result.LootSlot[1], "Slot 1 should NOT be looted!")
		assert(result.LootSlot[2], "Slot 2 SHOULD be looted!") -- money is always looted
		assert(result.LootSlot[3], "Slot 3 SHOULD be looted!") -- currency is always looted
		assert(not result.LootSlot[4], "Slot 1 should NOT be looted!")
	end,
	BackList = function(result)
		MockingProfile(function()
			AutoLooter.db.profile.ignore = { [214255] = "[Capelo da Garça Vermelha]" }
			AutoLooter.db.profile.lootAll = true
			UpdateStates() -- [mockingProfile] will update it again after the test
			AutoLooter:Loot()
		end)
		AutoLooter:GetModule("BlackList"):UpdateState()
		assert(not result.LootSlot[1], "Slot 1 should NOT be looted!")
		assert(result.LootSlot[2], "Slot 2 SHOULD be looted!")
		assert(result.LootSlot[3], "Slot 3 SHOULD be looted!")
		assert(result.LootSlot[4], "Slot 3 SHOULD be looted!")
	end,
	WhiteList = function(result)
		MockingProfile(function()
			AutoLooter.db.profile.lootAll = false
			AutoLooter.db.profile.items = { [214255] = "[Capelo da Garça Vermelha]" }
			UpdateStates() -- [mockingProfile] will update it again after the test
			AutoLooter:Loot()
		end)
		assert(result.LootSlot[1], "Slot 1 SHOULD be looted!")
		assert(result.LootSlot[2], "Slot 2 SHOULD be looted!")
		assert(result.LootSlot[3], "Slot 3 SHOULD be looted!")
		assert(not result.LootSlot[4], "Slot 1 should NOT be looted!")
	end
}

function module.RunTests()
	for k, v in pairs(tests) do
		AutoLooter.print("Executing test: ", k)
		module.Test(v, k)
	end
end

function module:GetOptions()
	local t = {
		debug = {
			order = 1,
			type = "toggle",
			name = "Debug",
			set = function(_, value) self:SetProfileVar("debug", Util.GetBoolean(value)) end,
			get = function(_) return self.db.profile.debug end
		},
		All = {
			order = 2,
			type = "execute",
			name = "Execute All Tests",
			func = function() module.RunTests() end
		}
	}

	local o = 3
	for k, v in pairs(tests) do
		t[k] = {
			order = o,
			type = "execute",
			name = k,
			func = function() module.Test(v, k) end
		}
		o = o + 1;
	end

	return {
		test = {
			name = "Test",
			type = "group",
			args = t
		}
	}
end