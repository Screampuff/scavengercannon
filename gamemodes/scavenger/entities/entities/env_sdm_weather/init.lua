AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


function ENT:KeyValue(key,value)
	key = string.lower(key)
	if key == "skyname" then
		self:SetNetworkedString("skyname",value)
	elseif key == "absskypath" then
		self.dt.AbsSkyPath = tobool(value)
	--FOG PARAMETERS
	elseif key == "fogstart" then
		self:SetFogParameter("fogstart",value)
		self:SetSkyFogParameter("fogstart",value)
	elseif key == "fogend" then
		self:SetFogParameter("fogend",value)
		self:SetSkyFogParameter("fogend",value)
	elseif key == "fogenable" then
		self:SetFogParameter("fogenable",value)
		self:SetSkyFogParameter("fogenable",value)
	elseif key == "fog_farz" then
		self:SetFogParameter("farz",value)
	elseif key == "fogcolor" then
		self:SetFogParameter("fogcolor",value)
		self:SetSkyFogParameter("fogcolor",value)
	elseif key == "fogcolor2" then
		self:SetFogParameter("fogcolor2",value)
		self:SetSkyFogParameter("fogcolor2",value)
	elseif key == "fogdir" then
		self:SetFogParameter("fogdir",value)
		self:SetSkyFogParameter("fogdir",value)
	elseif key == "fog_use_angles" then
		self:SetFogParameter("use_angles",value)
		self:SetSkyFogParameter("use_angles",value)
	elseif key == "fogblend" then
		self:SetFogParameter("fogblend",value)
		self:SetSkyFogParameter("fogblend",value)
	elseif key == "fogdir" then
		self:SetFogParameter("fogdir",value)
	elseif key == "precipitation" then
		self.Precipitation = value
	end
end

function ENT:SetEnabled(state)
	if state then
		self.Disabled = false
	else
		self.Disabled = false
		self.TouchingEnts = {}
	end
end

function ENT:Think()
	if self.Disabled then
		return
	end
end

function ENT:Input(name,value,activator)
	name = string.lower(name)
	if name == "enable" then
		self:SetEnabled(true)
	elseif name == "disable" then
		self:SetEnabled(false)
	elseif name == "toggle" then
		self:SetEnabled(self.Disabled)
	end
end

function ENT:SetPrecipitation(flags)
	self.dt.Precipitation = flags
end

function ENT:SetFogParameter(key,value)
	local fog = ents.FindByClass("env_fog_controller")[1]
	if not IsValid(fog) then
		fog = ents.Create("env_fog_controller")
	end
	fog:SetKeyValue(key,value)
end

function ENT:SetSkyFogParameter(key,value)
	local skyfog = ents.FindByClass("sky_camera")[1]
	if IsValid(skyfog) then
		skyfog:SetKeyValue(key,value)
	end
end


