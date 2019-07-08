local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(1100)
local reason = Color.GREEN .. L["Type"]

local function LootType(iType, iSubType, iRarity)
	if PRIVATE_TABLE.DB.ignoreGreys and iRarity == 0 then return false end

	local t = PRIVATE_TABLE.DB.typeTable[iType]
	if t then return t[iSubType] or t["(Legacy Types)"] end

	return false
end

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)

	if LootType(itemType, itemSubType, nRarity) then
		local typeSubtype = (PRIVATE_TABLE.DB.printoutType and Color.YELLOW .. "(" .. itemType .. "/" .. itemSubType .. ")|r") or ""

		return true, reason, typeSubtype .. Util.GetItemText(icon, link, nQuantity), nil
	end
end

local function GetSaved(defTable, itemClass, itemSubClass)
	if not defTable then return false end

	local t = defTable[itemClass]
	if t then return t[itemSubClass] or false end
	return false
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


-- Config
local AceGUI = LibStub("AceGUI-3.0")
local tab = L["Type"]

function module.GetConfigTabs()
	return tab
end

local function DropDown_OnValueChanged(this, event, checked)
	local data = this.userdata

	data.table[this:GetText()] = checked
	data.own:SetText(data.tableName .. " (" .. Util.CountChecked(data.table) .. ")")
end

local function SetAll(this, value)
	local data = this.userdata

	for k, v in pairs(data.table) do
		data.table[k] = value

		for _, item in data.own.pullout:IterateItems() do
			if item.SetValue then item:SetValue(value) end
		end
	end
	data.own:SetText(data.tableName .. " (" .. Util.CountChecked(data.table) .. ")")
end

local function SELECT_ALL_OnClick(this)
	SetAll(this, true)
end

local function REMOVE_ALL_OnClick(this)
	SetAll(this, false)
end

local function createRightWidgets()
	local group = AceGUI:Create("SimpleGroup")
	group:SetLayout("List")

	PRIVATE_TABLE.DB.typeTable = CreateAHTable(PRIVATE_TABLE.DB.typeTable)

	for k, v in Util.orderedPairs(PRIVATE_TABLE.DB.typeTable) do
		local dropDown = AceGUI:Create("Dropdown")

		for k2, v2 in Util.orderedPairs(v) do
			local item = AceGUI:Create("Dropdown-Item-Toggle")
			item:SetText(k2)
			item:SetValue(v2)

			item.userdata.table = v
			item.userdata.tableName = k
			item.userdata.own = dropDown
			item:SetCallback("OnValueChanged", DropDown_OnValueChanged)

			dropDown.pullout:AddItem(item)
		end

		dropDown.pullout:AddItem(AceGUI:Create("Dropdown-Item-Separator"))

		local n = Util.CountTable(v)

		if n > 1 then
			local item = AceGUI:Create("Dropdown-Item-Execute")
			item.userdata.table = v
			item.userdata.tableName = k
			item.userdata.own = dropDown
			item:SetText(L["Select all"])
			item:SetCallback("OnClick", SELECT_ALL_OnClick)

			dropDown.pullout:AddItem(item)

			item = AceGUI:Create("Dropdown-Item-Execute")
			item.userdata.table = v
			item.userdata.tableName = k
			item.userdata.own = dropDown
			item:SetText(L["Remove all"])
			item:SetCallback("OnClick", REMOVE_ALL_OnClick)

			dropDown.pullout:AddItem(item)
		end

		dropDown:SetMultiselect(true)

		dropDown:SetWidth(250)
		dropDown:SetText(k .. " (" .. Util.CountChecked(v) .. ")")

		group:AddChild(dropDown)
	end

	return group
end

function module.CreateConfigGroup(container, event, group)
	if (group == tab) then
		local printOutType = AceGUI:Create("CheckBox")
		printOutType:SetLabel(L["Printout items type"])
		printOutType:SetValue(PRIVATE_TABLE.DB.printoutType)
		printOutType:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.printoutType = Util.GetBoolean(checked) end)
		container:AddChild(printOutType)

		local ignoreGreys = AceGUI:Create("CheckBox")
		ignoreGreys:SetLabel(L["Ignore greys when looting by type"])
		ignoreGreys:SetValue(PRIVATE_TABLE.DB.ignoreGreys)
		ignoreGreys:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.ignoreGreys = Util.GetBoolean(checked) end)
		ignoreGreys:SetWidth(250)
		container:AddChild(ignoreGreys)

		container:AddChild(createRightWidgets())
	end
end

module.cli = {
	printoutType = {
		type = "toggle",
		name = L["Printout items type"],
		set = function(info, val) PRIVATE_TABLE.DB.printoutType = Util.GetBoolean(val) end,
		get = function(info) return PRIVATE_TABLE.DB.printoutType end
	},
	ignoreGreys = {
		type = "toggle",
		name = L["Ignore greys when looting by type"],
		set = function(info, val) PRIVATE_TABLE.DB.ignoreGreys = Util.GetBoolean(val) end,
		get = function(info) return PRIVATE_TABLE.DB.ignoreGreys end
	}
}