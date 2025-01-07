local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local module = AutoLooter:NewModule("ChatLoot", PRIVATE_TABLE.ToggleableModulePrototype, "AceEvent-3.0")
module.priority = 10

local currentPlayerName

function module:CanEnable()
	return module.db.profile.printItemsYouReceive or module.db.profile.printItemsOthersReceive
end

function module:InitializeDb()
	local defaults = { profile = { printItemsYouReceive = false, printItemsOthersReceive = false, delay = 600 } }
	module.db = AutoLooter.db:RegisterNamespace("ChatLootModule", defaults)

	local player = UnitFullName("player")
	local realm = GetRealmName()
	currentPlayerName = player .. "-" .. realm
	module:RegisterEvent("CHAT_MSG_LOOT", "LOOT_EVENT")
	module:RegisterEvent("CHAT_MSG_CURRENCY", "LOOT_EVENT")
end

local lootPrintBucket = {}
local printTimer
local lastTimer = 0

local function IsMe(name)
	return name == nil or name == "" or name == currentPlayerName
end

local function PrintLoots()
	for name, t in pairs(lootPrintBucket) do
		local loot = ""
		for _, v in pairs(t.items) do
			loot = loot .. Util.GetItemText(v.icon, v.link, v.amount, AutoLooter.db.profile.printoutIconOnly)
		end
		local color = t.color or CreateColor(1, 1, 1, 1)
		if (IsMe(name)) then
			AutoLooter.print(color:WrapTextInColorCode(L["You"]), ": ", loot)
		else
			local nameOnly = string.match(name, "(.-)%-") or name
			AutoLooter.print(color:WrapTextInColorCode(nameOnly), ": ", loot)
		end
	end

	lootPrintBucket = {}
	printTimer = nil
end

local function InitTimer()
	local now = GetTime()

	local timerDelay = module.db.profile.delay / 1000
	local halfDelay = timerDelay / 2.0

	-- to prevent multiple events in the same, or nearly the same, frame.
	if (now - lastTimer < halfDelay) then
		return
	end

	if (printTimer) then
		printTimer:Cancel()
		printTimer = nil
	end

	printTimer = C_Timer.NewTimer(timerDelay, PrintLoots, 1)
	lastTimer = now
end

local function AddItem(playerBucket, icon, link, amount)
	InitTimer()
	local existing = playerBucket.items[link]
	if (existing) then
		existing.amount = existing.amount + amount
		return
	end
	playerBucket.items[link] = { icon = icon, link = link, amount = amount }
end

-- Events: CHAT_MSG_LOOT, CHAT_MSG_CURRENCY, CHAT_MSG_MONEY
function module:LOOT_EVENT(event, text, playerName, _, _, _, _, _, _, _, _, _, guid)
	if (playerName == nil or playerName == "") then
		playerName = currentPlayerName
	end
	if (playerName == currentPlayerName and not module.db.profile.printItemsYouReceive) then
		return
	end
	if (playerName ~= currentPlayerName and not module.db.profile.printItemsOthersReceive) then
		return
	end

	local playerBucket = lootPrintBucket[playerName] or { items = {} }
	lootPrintBucket[playerName] = playerBucket

	if (not playerBucket.color) then
		local playerLocation
		if (guid and guid ~= "") then
			playerLocation = PlayerLocation:CreateFromGUID(guid)
		elseif (IsMe(playerName)) then
			playerLocation = PlayerLocation:CreateFromUnit("player")
		end
		if (playerLocation) then
			local className, classFilename, classID = C_PlayerInfo.GetClass(playerLocation)
			playerBucket.color = C_ClassColor and C_ClassColor.GetClassColor(classFilename) or GetClassColorObj(classFilename)
		end
	end

	for link, amount in string.gmatch(text, "(|c%x*|H.-|h|r)(x?%d*)") do
		-- Since [gmatch] can't make optional captures. We do this to make sure there's a 'x%d+' in the string.
		amount = string.match(amount, "x(%d+)") or 1
		if (event == "CHAT_MSG_LOOT") then
			local item = Item:CreateFromItemID(Util.getId(link))
			item:ContinueOnItemLoad(function()
				local icon = item:GetItemIcon()
				--AutoLooter.print(playerName, ": ", Util.GetItemText(icon, link, amount, AutoLooter.db.profile.printoutIconOnly))
				AddItem(playerBucket, icon, link, amount)
			end)
		elseif (event == "CHAT_MSG_CURRENCY") then
			local info = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
			AddItem(playerBucket, info.iconFileID, link, amount)
		end
	end
end

function module:GetOptions()
	return {
		chat = {
			args = {
				chatLootGroup = {
					name = L["Received Items"],
					type = "group",
					inline = true,
					order = 1000,
					args = {
						printItemsYouReceive = {
							type = "toggle",
							name = L["Print items you receive"],
							dialogControl = "AutoLooter_WrapTextCheckBox",
							set = function(info, value)
								module:SetProfileVar("printItemsYouReceive", Util.GetBoolean(value))
							end,
							get = function(info)
								return module.db.profile.printItemsYouReceive
							end
						},
						printItemsOthersReceive = {
							type = "toggle",
							name = L["Print items others receive"],
							dialogControl = "AutoLooter_WrapTextCheckBox",
							set = function(info, value)
								module:SetProfileVar("printItemsOthersReceive", Util.GetBoolean(value))
							end,
							get = function(info)
								return module.db.profile.printItemsOthersReceive
							end
						},
						printItemsReceivedDelay = {
							type = "range",
							name = L["Received items group Delay (ms)"],
							desc = L["All items received between this delay will be grouped"],
							disabled = function()
								return not module:CanEnable()
							end,
							min = 100,
							max = 10000,
							step = 100,
							width = "full",
							set = function(info, value)
								module:SetProfileVar("delay", value)
							end,
							get = function(info)
								return module.db.profile.delay
							end
						},
					}
				}
			}
		}
	}
end
