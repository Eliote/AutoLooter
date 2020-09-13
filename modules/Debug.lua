local ADDON_NAME, PRIVATE_TABLE = ...

local L = LibStub("AceLocale-3.0"):GetLocale("AutoLooter")

--- @type Color
local Color = PRIVATE_TABLE.Color
local Util = PRIVATE_TABLE.Util

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")
local DebugModule = AutoLooter:NewModule("Debug")

local hookedModules = {}

local function commaSeparated(...)
	local out = ""
	local sep = ""
	for i = 1, select("#", ...) do
		local s = tostring(select(i, ...))
		out = out .. sep .. s
		sep = ","
	end
	return out
end

local function registerHook(module, func)
	local name = module:GetName()
	if hookedModules[name] and hookedModules[name][func] then return end

	local original = module[func]
	module[func] = function(...)
		if original then
			local r = { original(...) }
			print(Color.PURPLE .. name .. "|r" .. "[" .. Color.BLUE .. func .. "|r](" .. commaSeparated(...) .. ")", Color.RED .. 'return:', commaSeparated(unpack(r)))
			return unpack(r)
		else
			print(Color.PURPLE .. name .. "|r" .. "[" .. Color.BLUE .. func .. "|r](" .. commaSeparated(...) .. ")")
		end
	end

	hookedModules[name] = hookedModules[name] or {}
	hookedModules[name][func] = { original = original }

	print("Added hook " .. Color.PURPLE .. name .. "|r[" .. Color.BLUE .. func .. "|r]")
end

local function removeHook(module, func)
	local name = module:GetName()
	if hookedModules[name] and hookedModules[name][func] then
		module[func] = hookedModules[name][func].original
		hookedModules[name][func] = nil
		print("Removed hook " .. Color.PURPLE .. name .. "|r[" .. Color.BLUE .. func .. "|r]")
	end
end

local function LoadState()
	if DebugModule.db.global.enableDebug then
		DebugModule:Enable()
	else
		DebugModule:Disable()
	end
end

local function updateAutoLooterHooks()
	local enabled = {}
	for k, v in pairs(DebugModule.db.global.autoLooterHook) do
		if DebugModule.db.global.enableDebug and v == true then
			enabled[k] = true
			registerHook(AutoLooter, k)
		end
	end
	local hooked = hookedModules[AutoLooter:GetName()]
	if hooked then
		for k, v in pairs(hooked) do
			if (not enabled[k]) then
				removeHook(AutoLooter, k)
			end
		end
	end
end

local function updateModulesHooks()
	for moduleName, hooks in pairs(DebugModule.db.global.modulesHook) do
		local enabled = {}
		for hook, v in pairs(hooks) do
			if DebugModule.db.global.enableDebug and v == true then
				enabled[hook] = true
				registerHook(AutoLooter:GetModule(moduleName), hook)
			end
		end
		local hooked = hookedModules[moduleName]
		if hooked then
			for k, v in pairs(hooked) do
				if (not enabled[k]) then
					removeHook(AutoLooter:GetModule(moduleName), k)
				end
			end
		end
	end
end

local function onProfileChange(event, table, profileName, ...)
	if (DebugModule.db.global.enableDebug) then
		print(Color.GOLD .. event .. "|r", profileName, table, ...)
	end
end

function DebugModule:OnInitialize()
	local defaults = { global = { enableDebug = false, autoLooterHook = {}, modulesHook = {} } }
	self.db = AutoLooter.db:RegisterNamespace("DebugModule", defaults)
	AutoLooter.db.RegisterCallback(self, "OnProfileShutdown", onProfileChange)
	AutoLooter.db.RegisterCallback(self, "OnProfileChanged", onProfileChange)
	AutoLooter.db.RegisterCallback(self, "OnProfileCopied", onProfileChange)
	AutoLooter.db.RegisterCallback(self, "OnProfileReset", onProfileChange)

	self:SetEnabledState(self.db.global.enableDebug)

	updateAutoLooterHooks()
	updateModulesHooks()
end

function DebugModule:OnEnable()
	updateAutoLooterHooks()
	updateModulesHooks()
end

function DebugModule:OnDisable()
	updateAutoLooterHooks()
	updateModulesHooks()
end

local options = {
	name = L["Debug"],
	type = "group",
	order = -1,
	args = {
		enable = {
			type = "toggle",
			name = L["Enable Debug"],
			get = function() return DebugModule.db.global.enableDebug end,
			set = function(info, value)
				DebugModule.db.global.enableDebug = value
				LoadState()
			end
		},
		hookAutoLooter = {
			type = "multiselect",
			name = L["Hook functions of AutoLooter"],
			values = function()
				local t = {}
				for k, f in pairs(AutoLooter) do
					if type(f) == "function" then
						t[k] = k
					end
				end
				return t
			end,
			get = function(info, key) return DebugModule.db.global.autoLooterHook[key] end,
			set = function(info, key, value)
				DebugModule.db.global.autoLooterHook[key] = value
				updateAutoLooterHooks()
			end
		},
		modules = {
			type = "multiselect",
			name = L["Modules State"],
			values = function()
				local t = {}
				for _, m in AutoLooter:IterateModules() do
					t[m:GetName()] = m:GetName()
				end
				return t
			end,
			get = function(info, key) return AutoLooter:GetModule(key):IsEnabled() end,
			disabled = true
		}
	}
}

local function createOptions()
	for _, module in AutoLooter:IterateModules() do
		local name = module:GetName()
		options.args[module:GetName()] = {
			type = "group",
			name = module:GetName(),
			args = {
				modules = {
					type = "multiselect",
					name = L["Hook Functions"],
					values = function()
						local t = {}
						for k, f in pairs(module) do
							if type(f) == "function" then
								t[k] = k
							end
						end
						return t
					end,
					get = function(info, key)
						return DebugModule.db.global.modulesHook[name] and DebugModule.db.global.modulesHook[name][key]
					end,
					set = function(info, key, value)
						DebugModule.db.global.modulesHook[name] = DebugModule.db.global.modulesHook[name] or {}
						DebugModule.db.global.modulesHook[name][key] = value
						updateModulesHooks()
					end
				}
			}
		}
	end
	return options
end

function DebugModule:GetOptions()
	return {
		debug = createOptions()
	}
end