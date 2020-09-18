local ADDON_NAME, PRIVATE_TABLE = ...

local AutoLooter = LibStub("AceAddon-3.0"):GetAddon("AutoLooter")

local prototype = {}
PRIVATE_TABLE.ToggleableModulePrototype = prototype

function prototype:UpdateState()
	if (AutoLooter.db.profile.enable and self:CanEnable()) then
		if not self:IsEnabled() then self:Enable() end
	else
		if self:IsEnabled() then self:Disable() end
	end
end

function prototype:OnInitialize()
	if self.InitializeDb then self:InitializeDb() end
	local db = self:GetDb() or
			error("When using this ToggleableModulePrototype you need to implement GetDb() or" ..
			 " implement InitializeDb() and set the 'self.db' var there")

	db.RegisterCallback(self, "OnProfileChanged", self.UpdateState, self)
	db.RegisterCallback(self, "OnProfileCopied", self.UpdateState, self)
	db.RegisterCallback(self, "OnProfileReset", self.UpdateState, self)

	-- OnInitialize (and only it) should call SetEnabledState
	self:SetEnabledState(AutoLooter.db.profile.enable and self:CanEnable())
	AutoLooter.RegisterCallback(self, "OnEnable", self.UpdateState, self)
	AutoLooter.RegisterCallback(self, "OnDisable", self.UpdateState, self)
end

function prototype:GetDb()
	return self.db
end

function prototype:SetProfileVar(var, value)
	self:GetDb().profile[var] = value
	self:UpdateState()
end

PRIVATE_TABLE.ToggleableModulePrototype.super = PRIVATE_TABLE.ToggleableModulePrototype


