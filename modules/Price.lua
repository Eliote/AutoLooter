local ADDON_NAME, PRIVATE_TABLE = ...
local L = PRIVATE_TABLE.GetTable("L")

local Color = AutoLooter:GetColorTable()
local Util = AutoLooter:GetUtil()

local module = AutoLooter:NewLootModule(1000)
local reason = Color.GREEN .. L["Price"]

function module.CanLoot(link, icon, sTitle, nQuantity, currencyID, nRarity, locked, isQuestItem, questId, isActive)
	local _, _, _, _, _, itemType, itemSubType, _, _, _, iPrice, _, _, bindType = GetItemInfo(link)
	if iPrice and (PRIVATE_TABLE.DB.price > 0) and (iPrice >= PRIVATE_TABLE.DB.price) then
		return true, reason, Util.GetItemText(icon, link, nQuantity), nil
	end
end


-- Config
local AceGUI = LibStub("AceGUI-3.0")
local tab = L["Price"]

function module.GetConfigTabs()
	return tab
end

function module.CreateConfigGroup(container, event, group)
	if (group == tab) then
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
		container:AddChild(price)
	end
end

module.cli = {
	price = {
		type = "range",
		name = L["Price (in coppers)"],
		min = 0,
		max = 10000000,
		step = 1,
		set = function(info, val) PRIVATE_TABLE.DB.price = val end,
		get = function(info) return PRIVATE_TABLE.DB.price end
	}
}