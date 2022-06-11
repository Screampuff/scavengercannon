AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.trmin = Vector(-72,-72,-72)
ENT.trmax = Vector(72,72,72)
ENT.lifetime = 4

function ENT:PhysicsCollide(data,physobj)
	if data.HitEntity && data.HitEntity:IsValid() then
		local dir = physobj:GetVelocity():GetNormalized()
		physobj:SetVelocity((dir-(-2*data.HitNormal*dir:Dot(-1*data.HitNormal)))*1500)
		
		local tracep = {}
			tracep.start = self:GetPos()
			tracep.endpos = self:GetPos()+physobj:GetVelocity():GetNormalized()*1000
			tracep.filter = {self,self.Owner,game.GetWorld(),data.HitEntity}
			tracep.mask = MASK_SHOT
			tracep.mins = self.trmin
			tracep.maxs = self.trmax
			local tr = util.TraceHull(tracep)		
		if tr.Entity && tr.Entity:IsNPC() || tr.Entity:IsPlayer() && (tr.HitPos() != self:GetPos()) then
			local mins = tr.Entity:OBBMaxs()
			local maxs = tr.Entity:OBBMins()
			pos = tr.Entity:GetPos()+Vector(math.Rand(mins.x,maxs.x),math.Rand(mins.y,maxs.y),math.Rand(mins.z,maxs.z))
			physobj:SetVelocity((pos-self:GetPos()):GetNormalized()*1500)
		end
		if data.HitObject:IsValid() then
			data.HitObject:ApplyForceOffset(data.OurOldVelocity*100,data.HitPos)
		end
		
		if data.HitEntity != self.Owner then
			//data.HitEntity:TakeDamage(1000,self.Owner,self)
			local dmg = DamageInfo()
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(vector_origin)
			dmg:SetDamagePosition(data.HitPos)
			dmg:SetDamageType(DMG_DISSOLVE)
			dmg:SetDamage(1000)
			data.HitEntity:TakeDamageInfo(dmg)
			if data.HitEntity:IsPlayer() || data.HitEntity:IsNPC() then
				data.HitEntity:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
			end
		end
		--[[
		if (data.HitEntity:Health() <= 1000) && data.HitEntity:IsPlayer() && data.HitEntity:GetRagdollEntity() && data.HitEntity:GetRagdollEntity():IsValid() then

		end
		
		if (data.HitEntity:Health() <= 1000) && data.HitEntity:IsNPC() then
			local dis = ents.Create("env_entity_dissolver")
			dis:SetPos(self:GetPos())
			dis:SetKeyValue("magnitude",0)
			dis:SetKeyValue("dissolvetype",0)
			dis:SetEntity("target",data.HitEntity)
			data.HitEntity:SetKeyValue("targetname","willdissolve")
			dis:Spawn()
			dis:Fire("Dissolve","willdissolve",0)
			dis:Fire("Kill",1,"1")
			data.HitEntity:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
		end
		]]
	
		
		
		
		
	end
	local ef = EffectData()
	ef:SetOrigin(data.HitPos)
	ef:SetNormal(data.HitNormal)
	util.Effect("cball_bounce",ef)
	self:EmitSound("weapons/physcannon/energy_bounce"..math.random(1,2)..".wav")
	
end

--[[
hook.Add("PlayerDeath","scavcomballkill",
	function(pl,inflictor,attacker)
		if inflictor:IsValid() && (inflictor:GetClass() == "scav_projectile_comball") then
			local dissolver = ents.Create("env_entity_dissolver")
			dissolver:SetPos(pl:GetPos())
			dissolver:SetKeyValue("magnitude",0)
			dissolver:SetKeyValue("dissolvetype",0)
			dissolver:SetEntity("target",pl)
			pl:GetRagdollEntity():SetKeyValue("targetname","dissolved")
			dissolver:Spawn()
			dissolver:Fire("Dissolve","dissolved",0)
			dissolver:Fire("Kill",1,"1")
			pl:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
		end
	end)
	]]
	
function ENT:Think()
	if (!self.grabbedtime && (self.lifetime+self.Created < CurTime())) || (self.grabbedtime && self.grabbedtime+7 < CurTime()) then
		local ef = EffectData()
		ef:SetOrigin(self:GetPos())
		util.Effect("cball_explode",ef)
		self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav")
		if self.sound then
			self.sound:Stop()
		end
		self:Remove()
	end
end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch(hitent)
end

function ENT:OnTakeDamage()
end

function ENT:OnRemove()
end

hook.Add("GravGunOnPickedUp","scav_comballpickup",function(pl,ent) if ent:GetClass() == "scav_projectile_comball" then ent.Owner = pl ent.sound:Play() ent.grabbedtime = CurTime() end end)
hook.Add("GravGunOnDropped","scav_comballdrop",function(pl,ent) if ent:GetClass() == "scav_projectile_comball" then ent.Owner = pl ent.sound:Stop() ent.lifetime = (ent.lifetime+CurTime()-ent.grabbedtime) end end)
//local function dissolvesound(ent,inflictor,killer)
//	if (inflictor:GetClass() == "scav_projectile_comball") || (killer:GetClass() == "scav_projectile_comball") then
//		ent:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4,5)..".wav")
//	end
//end

//hook.Add("PlayerDeath","ScavComBallKillSound",dissolvesound)
//hook.Add("OnNPCKilled","ScavComBallKillSound",dissolvesound)