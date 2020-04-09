AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:AddItem(ent)
	local slotnum = #self.CreatedItems
	for i=0,slotnum-1 do
		if !IsValid(self.CreatedItems[slotnum-i]) then
			table.remove(self.CreatedItems,slotnum-i)
		end
	end
	if IsValid(self.CreatedItems[4]) then
		local prop = self.CreatedItems[4]
		self:DestroyItem(prop)
		self.CreatedItems[4] = nil
	end
	table.insert(self.CreatedItems,1,ent)
end

function SWEP:DestroyItem(ent)
	timer.Simple(0, function() ParticleEffectAttach("alch_fizzle",PATTACH_ABSORIGIN_FOLLOW,ent,0) end)
	ent:SetMoveType(MOVETYPE_NONE)
	ent.NoScav = true
	ent:SetSolid(SOLID_NONE)
	ent:Fire("Kill",nil,0.3)
end

function SWEP:DestroyAllItems()
	for k,v in pairs(self.CreatedItems) do
		if IsValid(v) then
			self:DestroyItem(v)
		end
	end
end

local vector_up = Vector(0,0,1)

local function ax(pl,command,args)
	local arg = tonumber(args[1])
	if !arg then
		return
	end
	if pl:Alive() then
		wep = pl:GetActiveWeapon()
	else
		return
	end
	if IsValid(wep) && (wep:GetClass() == "weapon_alchemygun") && IsValid(wep.Ghost) then
		//local ang = plang+wep.Ghost.LocalAng
		//wep.Ghost.LocalAng:RotateAroundAxis(vector_up,arg)
		//wep.Ghost.LocalAng = ang-plang
		local plang = pl:GetAimVector():Angle()
		local _,ang = LocalToWorld(vector_origin,wep.Ghost.LocalAng,vector_origin,plang)
		ang:RotateAroundAxis(plang:Up(),arg)
		_,wep.Ghost.LocalAng = WorldToLocal(vector_origin,ang,vector_origin,plang)
		//wep.Ghost.LocalAng.y = wep.Ghost.LocalAng.y+arg
	end
end

concommand.Add("sg_alch_x",ax)

local vector_right = Vector(0,1,0)

local function ay(pl,command,args)
	local arg = tonumber(args[1])
	if !arg then
		return
	end
	if pl:Alive() then
		wep = pl:GetActiveWeapon()
	else
		return
	end
	if IsValid(wep) && (wep:GetClass() == "weapon_alchemygun") && IsValid(wep.Ghost) then
		//local ang = plang+wep.Ghost.LocalAng
		//wep.Ghost.LocalAng:RotateAroundAxis(vector_right,arg)
		//wep.Ghost.LocalAng = ang-plang
		//wep.Ghost.LocalAng.p = wep.Ghost.LocalAng.p+arg
		local plang = pl:GetAimVector():Angle()
		local _,ang = LocalToWorld(vector_origin,wep.Ghost.LocalAng,vector_origin,plang)
		ang:RotateAroundAxis(plang:Right(),arg)
		_,wep.Ghost.LocalAng = WorldToLocal(vector_origin,ang,vector_origin,plang)
	end
end

concommand.Add("sg_alch_y",ay)

function SWEP:CheckCanScav(ent)
	if IsValid(self.Owner) and self.Owner:CanScavPickup(ent) then
		return true
	end
	return false
end

function SWEP:Scavenge(ent)
	local modelname = ScavData.FormatModelname(ent:GetModel())
	ent.NoScav = true
	local ef = EffectData()
	ef:SetRadius(ent:OBBMaxs():Distance(ent:OBBMins())/2)
	ef:SetEntity(self.Owner)
	ef:SetOrigin(ent:GetPos())
	util.Effect("scav_pickup",ef,nil,true)
	local modelinfo = self:GetAlchemyInfo(modelname)
	local surfaceinfo = self:GetSurfaceInfo(modelinfo.material)
	self.dt.Ammo1 = self.dt.Ammo1+surfaceinfo.metal*modelinfo.mass
	self.dt.Ammo2 = self.dt.Ammo2+surfaceinfo.chem*modelinfo.mass
	self.dt.Ammo3 = self.dt.Ammo3+surfaceinfo.org*modelinfo.mass
	self.dt.Ammo4 = self.dt.Ammo4+surfaceinfo.earth*modelinfo.mass
	self:LearnItem(modelname,ent:GetSkin())
	ent:Remove()
end

hook.Add("EntityTakeDamage","AlchGunCredit",function(victim,dmginfo)
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()
	if (inflictor.AlchGun) then
		local ag=inflictor.AlchGun
		if ag.owner != inflictor:GetPhysicsAttacker() then --If the attacker wasn't us, it was caused by something moving the object after we made it. We're no longer interested.
			return
		end
		if IsValid(ag.gun) then
			dmginfo:SetInflictor(ag.gun)
		end
		if IsValid(ag.owner) then
			dmginfo:SetAttacker(ag.owner)
		end
	end
end)