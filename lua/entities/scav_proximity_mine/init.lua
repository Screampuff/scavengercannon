AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:OnTakeDamage(dmginfo)
	if !self.exploded && (dmginfo:GetDamageType() != DMG_PHYSGUN) then
		timer.Simple(0.2, function() if IsValid(self) and not self.exploded then self:Explode() end end)
	end
end


ENT.constraint = NULL

function ENT:PhysicsCollide(data,physobj)
	if !self.dt.sticky then
		return
	end
	local ent = data.HitEntity
	if !(self.constraint && self.constraint:IsValid()) && (((ent:GetPhysicsObjectCount() == 1) && !(ent:IsPlayer() || ent:IsNPC())) || ent:IsWorld()) then
		timer.Simple(0, function() self:Constrain(ent,data.HitPos-self:OBBCenter()) end)
	end
end

function ENT:Constrain(hitent,weldpos)
	if weldpos then
		self:SetPos(weldpos)
	end
	self.constraint = constraint.Weld(self,hitent,0,0,2000,false)
end

function ENT:SetState(state)
	if state != self.dt.state then
		self:StopParticles()
		self.dt.state = state
		if state == 1 then --friendly
			if self.dt.showrings then
				ParticleEffectAttach("scav_proxmine_green",PATTACH_ABSORIGIN_FOLLOW,self,0)
			end
			self.sound1:Stop()
		elseif state == 2 then --enemy
			if self.dt.showrings then
				ParticleEffectAttach("scav_proxmine_red",PATTACH_ABSORIGIN_FOLLOW,self,0)
			end
			if !self.dt.silent then
				self.sound1:PlayEx(15,255)
			end
		end
	end
end

function ENT:Explode()
	if self:IsValid() && !self.exploded then
		self.exploded = true
		local edata = EffectData()
		edata:SetOrigin(self:GetPos())
		edata:SetNormal(vector_up)
		util.Effect("ef_scav_exp",edata)
		util.BlastDamage(self,self.Owner||self,self:GetPos(),self.Range,self.Damage)
		self:Remove()
	end
end

function ENT:OnRemove()
	self.sound1:Stop()
end