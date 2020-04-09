ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = ""
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.Model = "models/Effects/combineball.mdl"
ENT.Speed = 2500
ENT.BBMins = Vector(-8,-8,-8)
ENT.BBMaxs = Vector(8,8,8)
ENT.PhysInstantaneous = true
PrecacheParticleSystem("scav_shockwave_1")
PrecacheParticleSystem("scav_exp_shockwave")
PrecacheParticleSystem("scav_exp_water_shockwave")

function ENT:OnInit()
	if SERVER then
		self.filter = {self.Owner}
	else
		ParticleEffectAttach("scav_shockwave_1",PATTACH_ABSORIGIN_FOLLOW,self,0)
		self:EmitSound("ambient/weather/thunder5.wav")
		self.Weapon = self:GetOwner():GetActiveWeapon()
		self.Owner = self:GetOwner()
	end
	self:DrawShadow(false)
	self.lasttrace = CurTime()
end

function ENT:Think()
	if SERVER then
		local tab = ents.FindInSphere(self:GetPos(),300)
		for k,v in ipairs(tab) do
			if (v:GetMoveType() == MOVETYPE_VPHYSICS) && v:GetPhysicsObject():IsValid() then
				v:GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormalized()*50000)
				v:SetPhysicsAttacker(self.Owner)
			end
		end
	end
	self.lasttrace = CurTime()
end

function ENT:OnImpact(hitent)
	table.insert(self.filter,hitent)
	local normal = self:GetVelocity():GetNormalized()
	local pos = self:GetPos()
	local dir = self.vel:GetNormalized()
	local ent = ents.FindInSphere(pos,300)
	for k,v in ipairs(ent) do
		local intensity = (300-pos:Distance(pos+v:OBBCenter()))/15
		if (v:IsPlayer() || v:IsNPC()) && !v:IsFriendlyToPlayer(self.Owner) then
			v:InflictStatus("Deaf",intensity,0)
			local dmg = DamageInfo()
			dmg:SetDamage(intensity)
			dmg:SetDamageType(DMG_SONIC)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(normal*intensity*5000)
			v:SetVelocity(normal*intensity*300)
			v:TakeDamageInfo(dmg)
		end
	end
	ParticleEffect("scav_exp_shockwave",pos,Angle(0,0,0),Entity(0))
	return true
end