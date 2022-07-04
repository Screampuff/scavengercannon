AddCSLuaFile()
local PLAYER = FindMetaTable("Player")

function PLAYER:SetupEnergy()
	self.G_Energy = {}
	self.G_Energy.EnergyTime = -200
	self.G_Energy.ChargeRate = 5
	self.G_Energy.MaxEnergy = 100
	self.G_Energy.EnergyChanges = {}
	self.G_Energy.ChargeChanges = {}
	self.G_Energy.MaxEnergyChanges = {}
end

function PLAYER:ClearEnergyStateChanges()

	if not self.G_Energy then
		return
	end
	
	local echanges = self.G_Energy.EnergyChanges
	local cchanges = self.G_Energy.ChargeChanges
	local mechanges = self.G_Energy.MaxEnergyChanges
	
	for k,v in ipairs(echanges) do
		echanges[k] = nil
	end
	
	for k,v in ipairs(cchanges) do
		cchanges[k] = nil
	end
	
	for k,v in ipairs(mechanges) do
		mechanges[k] = nil
	end
	
end

function PLAYER:GetEnergy()
	if not self.G_Energy then
		self:SetupEnergy()
	end
	return math.Clamp((CurTime() - self.G_Energy.EnergyTime) * self.G_Energy.ChargeRate, 0, self.G_Energy.MaxEnergy)
end

local mostrecentlatency = 0

function PLAYER:HasEnergy(amt)
	if SERVER then
		return amt <= self:GetEnergy()
	else
		return amt <= self:GetEnergy() + mostrecentlatency * self:GetChargeRate()
	end
end

function PLAYER:GetUnPredictedEnergy()
	if SERVER or self ~= LocalPlayer() then
		return self:GetEnergy()
	else
		return math.Clamp((UnPredictedCurTime() - self.G_Energy.EnergyTime) * self.G_Energy.ChargeRate, 0, self.G_Energy.MaxEnergy)
	end
end

local predictedtimes = {}

if SERVER then
	util.AddNetworkString("scv_ene")
end

function PLAYER:SetEnergy(amt)

	if not self.G_Energy then
		self:SetupEnergy()
	end
	
	local lastenergy = self:GetEnergy()
	local entime = CurTime() - amt / self.G_Energy.ChargeRate
	self.G_Energy.EnergyTime = entime
	
	if self:GetEnergy() == lastenergy then
		return
	end
	
	if SERVER then
		net.Start("scv_ene")
			net.WriteEntity(self)
			net.WriteFloat(self.G_Energy.EnergyTime)
			net.WriteFloat(CurTime())
		net.Send(self)
	else
		table.insert(predictedtimes, 1, {entime,CurTime()})
	end
	
end

function PLAYER:GetChargeRate()
	if not self.G_Energy then
		self:SetupEnergy()
	end
	return self.G_Energy.ChargeRate
end

if SERVER then
	util.AddNetworkString("scv_enc")
end

function PLAYER:SetChargeRate(amt,dodelay) --if dodelay is true, this will be synchronized when the energy is changed in one second

	if not self.G_Energy then
		self:SetupEnergy()
	end
	
	if not dodelay then
		local en = self:GetEnergy()
		self.G_Energy.ChargeRate = amt
		self:SetEnergy(en)
		if SERVER and game.SinglePlayer() then
			net.Start("scv_enc")
				net.WriteEntity(self)
				net.WriteFloat(amt)
				net.WriteFloat(0)
			net.Send(self)
		end
	else
		self:SetChargeRateDelayed(amt,CurTime() + 1)
	end
	
end

function PLAYER:SetChargeRateDelayed(amt,activatetime)

	if not self.G_Energy then
		self:SetupEnergy()
	end
	
	table.insert(self.G_Energy.ChargeChanges,{amt,activatetime})
	
	if SERVER then
		net.Start("scv_enc")
			net.WriteEntity(self)
			net.WriteFloat(amt)
			net.WriteFloat(activatetime)
		net.Send(self)
	end
	
end

function PLAYER:GetMaxEnergy()
	if not self.G_Energy then
		self:SetupEnergy()
	end
	return self.G_Energy.MaxEnergy
end

if SERVER then
	util.AddNetworkString("scv_enm")
end

function PLAYER:SetMaxEnergy(amt,dodelay) --if dodelay is true, this will be synchronized when the energy is changed in one second
	if not self.G_Energy then
		self:SetupEnergy()
	end
	
	if not dodelay then
		self.G_Energy.MaxEnergy = amt
		if SERVER and game.SinglePlayer() then
			net.Start("scv_enm")
				net.WriteEntity(self)
				net.WriteFloat(amt)
				net.WriteFloat(0)
			net.Send(self)
		end
	else
		self:SetMaxEnergyDelayed(amt,CurTime() + 1)
	end
	
end

function PLAYER:SetMaxEnergyDelayed(amt,activatetime)
	if not self.G_Energy then
		self:SetupEnergy()
	end
	table.insert(self.G_Energy.MaxEnergyChanges,{amt,activatetime})
	if SERVER then
		net.Start("scv_enm")
			net.WriteEntity(self)
			net.WriteFloat(amt)
			net.WriteFloat(activatetime)
		net.Send(self)
	end
end

if CLIENT then

	net.Receive("scv_ene",function()
	
		local pl = net.ReadEntity()
		local entime = net.ReadFloat()
		local transmittime = net.ReadFloat()
		
		if not pl.G_Energy then
			pl:SetupEnergy()
		end

		local remove = false
		
		for k,v in pairs(predictedtimes) do
		
			if v[1] == entime and v[2] == transmittime then
				remove = true
				mostrecentlatency = CurTime() - v[2]
			end
			
			if remove then
				predictedtimes[k] = nil
			end
			
		end
		
		if not remove then
			pl.G_Energy.EnergyTime = entime
		end
		
	end)
	
	net.Receive("scv_enc",function()
	
		local pl = net.ReadEntity()
		local amt = net.ReadFloat()
		local ctime = net.ReadFloat()
		
		if not pl.G_Energy then
			pl:SetupEnergy()
		end
		
		pl:SetChargeRateDelayed(amt,ctime)
		
	end)
	
	net.Receive("scv_enm",function()
	
		local pl = net.ReadEntity()
		local amt = net.ReadFloat()
		local ctime = net.ReadFloat()
		
		if not pl.G_Energy then
			pl:SetupEnergy()
		end
		
		pl:SetMaxEnergyDelayed(amt,ctime)
		
	end)
	
end

local expired_c = {}
local expired_m = {}

function PLAYER:ProcessEnergyChanges()

	local cchanges = self.G_Energy.ChargeChanges
	local mechanges = self.G_Energy.MaxEnergyChanges
	local en = self:GetEnergy()
	
	--charge rate
	for k,v in ipairs(cchanges) do
		if v[2] <= CurTime() then
			self:SetChargeRate(v[1])
			table.insert(expired_c,k)
		end
	end
	
	local numexpcchanges = #expired_c
	for i=0,numexpcchanges - 1 do
		table.remove(cchanges,expired_c[numexpcchanges - i])
		expired_c[numexpcchanges-i] = nil
	end	
	
	--max energy
	for k,v in ipairs(mechanges) do
		if v[2] <= CurTime() then
			self:SetMaxEnergy(v[1])
			table.insert(expired_m,k)
		end
	end
	
	local numexpmchanges = #expired_m
	for i=0,numexpmchanges - 1 do
		table.remove(mechanges,expired_m[numexpmchanges-i])
	end
	
	self:SetEnergy(en)
	
end

--local LastThink = CurTime()

hook.Add("Think","G_EnergyManage",function()

	--local delta = CurTime()-LastThink
	
	for _,pl in ipairs(player.GetAll()) do
		if pl.G_Energy then
			pl:ProcessEnergyChanges()
		end
	end
	
	--LastThink = CurTime()
	
end)

if SERVER then
	hook.Add("PlayerInitialSpawn","G_EnergySpawnSetup",function(pl)
		pl:SetMaxEnergy(pl:GetMaxEnergy())
		pl:SetChargeRate(pl:GetChargeRate())
	end)
end
