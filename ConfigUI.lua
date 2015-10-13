local ADDON_NAME, PRIVATE_TABLE = ...;
local L = PRIVATE_TABLE.GetTable("L")
local ConfigUI = PRIVATE_TABLE.GetTable("ConfigUI")
local AUTO_LOOTER = PRIVATE_TABLE.GetTable("AUTO_LOOTER")
local Util = PRIVATE_TABLE.GetTable("Util")

local AceGUI = LibStub("AceGUI-3.0")
local frame

ConfigUI.raritysMenu = {
	[-1] = "|cFFFF0000" .. L["Off"],
	[0] = Util.GetColorForRarity(0) .. _G["ITEM_QUALITY0_DESC"],
	[1] = Util.GetColorForRarity(1) .. _G["ITEM_QUALITY1_DESC"],
	[2] = Util.GetColorForRarity(2) .. _G["ITEM_QUALITY2_DESC"],
	[3] = Util.GetColorForRarity(3) .. _G["ITEM_QUALITY3_DESC"],
	[4] = Util.GetColorForRarity(4) .. _G["ITEM_QUALITY4_DESC"]
}

AceGUI:RegisterLayout("Custom_Layout",
	function(content, children)
		children[1]:SetWidth(content:GetWidth() or 0)
		children[1].frame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -10)
		children[1].frame:Show()

		children[2]:SetWidth(content:GetWidth() or 0)
		children[2].frame:SetPoint("TOPLEFT", content, "TOPLEFT", 235, -10)
		children[2].frame:Show()
	end)

local function Rarity_OnValueChanged(self, event, value)
	PRIVATE_TABLE.DB.rarity = value
end

local function CreateLeftWidgets()
	local enable = AceGUI:Create("CheckBox")
	enable = AceGUI:Create("CheckBox")
	enable:SetLabel(L["Enable AutoLooter"])
	enable:SetValue(PRIVATE_TABLE.DB.enable)
	enable:SetCallback("OnValueChanged", function(self, event, checked) AUTO_LOOTER.Enable(checked) end)

	local printOut = AceGUI:Create("CheckBox")
	printOut:SetLabel(L["Printout items looted"])
	printOut:SetValue(PRIVATE_TABLE.DB.printout)
	printOut:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.printout = AUTO_LOOTER.GetBoolean(checked) end)

	local printOutIgnored = AceGUI:Create("CheckBox")
	printOutIgnored:SetLabel(L["Printout items ignored"])
	printOutIgnored:SetValue(PRIVATE_TABLE.DB.printoutIgnored)
	printOutIgnored:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.printoutIgnored = AUTO_LOOTER.GetBoolean(checked) end)

	local printOutType = AceGUI:Create("CheckBox")
	printOutType:SetLabel(L["Printout items type"])
	printOutType:SetValue(PRIVATE_TABLE.DB.printoutType)
	printOutType:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.printoutType = AUTO_LOOTER.GetBoolean(checked) end)

	local lootAll = AceGUI:Create("CheckBox")
	lootAll:SetLabel(L["Loot everything"])
	lootAll:SetValue(PRIVATE_TABLE.DB.lootAll)
	lootAll:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.lootAll = AUTO_LOOTER.GetBoolean(checked) end)

	local close = AceGUI:Create("CheckBox")
	close:SetLabel(L["Close after loot"])
	close:SetValue(PRIVATE_TABLE.DB.close)
	close:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.close = AUTO_LOOTER.GetBoolean(checked) end)

	local lootQuest = AceGUI:Create("CheckBox")
	lootQuest:SetLabel(L["Loot quest itens"])
	lootQuest:SetValue(PRIVATE_TABLE.DB.lootQuest)
	lootQuest:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.lootQuest = AUTO_LOOTER.GetBoolean(checked) end)

	local ignoreGreys = AceGUI:Create("CheckBox")
	ignoreGreys:SetLabel(L["Ignore greys when looting by type"])
	ignoreGreys:SetValue(PRIVATE_TABLE.DB.ignoreGreys)
	ignoreGreys:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.ignoreGreys = AUTO_LOOTER.GetBoolean(checked) end)
	ignoreGreys:SetWidth(250)

	local autoConfirmRoll = AceGUI:Create("CheckBox")
	autoConfirmRoll:SetLabel(L["Auto confirm loot roll"])
	autoConfirmRoll:SetValue(PRIVATE_TABLE.DB.autoConfirmRoll)
	autoConfirmRoll:SetCallback("OnValueChanged", function(self, event, checked) PRIVATE_TABLE.DB.autoConfirmRoll = AUTO_LOOTER.GetBoolean(checked) end)

	local rarity = AceGUI:Create("Dropdown")
	rarity:SetList(ConfigUI.raritysMenu)
	rarity:SetValue(PRIVATE_TABLE.DB.rarity)
	rarity:SetCallback("OnValueChanged", Rarity_OnValueChanged)
	rarity:SetLabel(L["Rarity"])
	rarity:SetWidth(120)

	local price = AceGUI:Create("EditBox")
	price.editbox:SetNumeric(true)
	price:SetMaxLetters(7)
	price:SetText(PRIVATE_TABLE.DB.price)
	price:SetLabel(L["Price"])

	price:SetCallback("OnEnterPressed", function(self)
		local number = tonumber(self:GetText())
		if not number then
			number = 0
		end

		PRIVATE_TABLE.DB.price = number
	end)

	price:SetWidth(120)

	local group = AceGUI:Create("SimpleGroup")
	group:SetWidth(250)
	group:AddChild(enable)
	group:AddChild(printOut)
	group:AddChild(printOutIgnored)
	group:AddChild(printOutType)
	group:AddChild(lootAll)
	group:AddChild(lootQuest)
	group:AddChild(close)
	group:AddChild(ignoreGreys)
	group:AddChild(autoConfirmRoll)
	group:AddChild(rarity)
	group:AddChild(price)

	return group
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

		dropDown:SetWidth(180)
		dropDown:SetText(k .. " (" .. Util.CountChecked(v) .. ")")

		group:AddChild(dropDown)
	end

	return group
end

function ConfigUI.CreateConfigUI()
	if frame and frame:IsShown() then
		frame:Release()
		return
	end

	frame = AceGUI:Create("Frame")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	frame:SetWidth(460)
	frame:SetHeight(400)
	frame:SetTitle("AutoLooter")
	frame:EnableResize(false)
	frame:SetStatusText("")

	frame:AddChild(CreateLeftWidgets())
	frame:AddChild(createRightWidgets())

	frame:SetLayout("Custom_Layout")

	local old_CloseSpecialWindows
	if not old_CloseSpecialWindows then
		old_CloseSpecialWindows = CloseSpecialWindows
		CloseSpecialWindows = function()
			CloseSpecialWindows = old_CloseSpecialWindows

			if frame then
				frame:Hide()
				return true
			end
			return false
		end
	end
end
