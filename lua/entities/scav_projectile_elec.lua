AddCSLuaFile()

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

if CLIENT then

	local mat = Material("trails/electric")
	local mat2 = Material("effects/scav_elec1")


	function ENT:Draw()
		if not self.points then
			return
		end
		render.SetMaterial(mat)
		render.StartBeam(#self.points)
		for i=1,#self.points do
			render.AddBeam(self.points[i],10-i,((i-1)/10),color_white)
		end
		render.EndBeam()
		render.SetMaterial(mat2)
		if self.points[1] then
			render.DrawSprite(self.points[1],32,32,color_white)
		end
	end

end

if SERVER then

	ENT.lifetime = 4
	ENT.RemoveOnImpact = true

	function ENT:OnImpact(hitent)
		local pos = self:GetPos()
		if hitent:IsWorld() then
			return true
		end
		ParticleEffectAttach("scav_electrocute",PATTACH_ABSORIGIN_FOLLOW,hitent,0)
		table.insert(self.filter,hitent)
		local dir = self:GetVelocity():GetNormalized()
		local ent = ents.FindInSphere(pos,300)
		local nextent
		local dist
		for k,v in ipairs(ent) do
			if IsValid(v) and ((v:IsPlayer() and v:Alive()) or v:IsNPC() or v:IsNextBot()) and (v ~= self.Owner) and (v ~= hitent) and (not nextent or (dist > v:GetPos():Distance(pos))) and not table.HasValue(self.filter,v) then
				nextent = v
				dist = v:GetPos():Distance(self:GetPos())
			end
		end
		if nextent and (nextent:IsNPC() or nextent:IsPlayer() or nextent:IsNextBot()) then
			local entpos = nextent:GetPos()+nextent:OBBCenter()
			self:GetPhysicsObject():SetVelocity((entpos-pos):GetNormalized()*1500)
		end
		local dmg = DamageInfo()
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamageForce(vector_origin)
		dmg:SetDamage(40)
		dmg:SetDamageType(DMG_SHOCK)
		dmg:SetDamagePosition(pos)
		if hitent:IsPlayer() then
			hitent:InflictStatusEffect("Shock",20,20)
		end
		hitent:TakeDamageInfo(dmg)
		--self:SetNetworkedVector("vel",self.vel)
		hitent:Fire("StartRagdollBoogie",2,0) --TODO: a bug in ragdoll code means the duration is stuck at 5 seconds. Find a way to manually spawn a env_ragdoll_boogie?
		return true
	end

	function ENT:OnPhys(data,physobj)
		sound.Play("ambient/energy/zap"..math.random(1,3)..".wav",self:GetPos())
		ParticleEffect("scav_exp_elec",data.HitPos-data.HitNormal,Angle(0,0,0),game.GetWorld())
	end

	function ENT:OnTouch(ent)
		sound.Play("ambient/energy/zap"..math.random(1,3)..".wav",self:GetPos())
		ParticleEffect("scav_exp_elec",self:GetPos(),Angle(0,0,0),game.GetWorld())
	end

end
