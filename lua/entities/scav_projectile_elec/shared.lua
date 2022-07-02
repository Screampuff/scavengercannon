ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = "electricity beam"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.Model = "models/Effects/combineball.mdl"
ENT.BBMins = Vector(-8,-8,-8)
ENT.BBMaxs = Vector(8,8,8)
ENT.PhysType = 1
ENT.Speed = 1500
ENT.RemoveDelay = 0.2
ENT.PhysInstantaneous = true
--ENT.TouchTrigger = false

PrecacheParticleSystem("scav_electrocute")
PrecacheParticleSystem("scav_exp_elec")

function ENT:OnInit()
	if SERVER then
		self.filter = {self,self.Owner}
	else
		self.Weapon = self:GetOwner():GetActiveWeapon()
		self.Owner = self:GetOwner()
		if self.Weapon:IsWeapon() then
			self.points = {ScavData.GetTracerShootPos(self:GetOwner(),self:GetPos())}
		else
			self.points = {self:GetPos()}
		end
	end
	self:DrawShadow(false)
	self.lasttrace = CurTime()
end

local tracep = {}
		tracep.mask = bit.bor(MASK_SHOT,CONTENTS_WATER)
		tracep.mins = ENT.BBMins
		tracep.maxs = ENT.BBMaxs
		
function ENT:Think()
	if CLIENT then
		if not self.points then
			return
		end
		if CurTime()-self.Created > 0.1 then
			table.insert(self.points,1,self:GetPos()+VectorRand()*8)
			if self.points[10] then
				table.remove(self.points,10)
			end
		end
	else
		if self:WaterLevel() > 0 then
			ScavData.Electrocute(self,self.Owner,self:GetPos(),500,500,true)
			ParticleEffect("scav_exp_elec",self:GetPos(),Angle(0,0,0),game.GetWorld())
			self.electrocuted = true
			self:DelayedDeath(0.2)
		end
		local vel = self:GetVelocity()*(CurTime()-self.lasttrace)
		tracep.start = self:GetPos()
		tracep.filter = self.filter
		tracep.endpos = self:GetPos()+vel
		local tr = util.TraceHull(tracep)
		if tr.HitWorld then
			if (tr.MatType == MAT_SLOSH) and not self.electrocuted then
				ScavData.Electrocute(self,self.Owner,tr.HitPos,500,500,true)
				ParticleEffect("scav_exp_elec",tr.HitPos,Angle(0,0,0),game.GetWorld())
				self.electrocuted = true
				self:DelayedDeath(0.2)
			end	
		end
	end
	self.lasttrace = CurTime()
end
