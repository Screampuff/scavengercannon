AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = ""
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.Model = "models/Effects/combineball.mdl"
ENT.Speed = 2500
ENT.BBMins = Vector(-8, -8, -8)
ENT.BBMaxs = Vector(8, 8, 8)
ENT.PhysInstantaneous = true
PrecacheParticleSystem("scav_shockwave_1")
PrecacheParticleSystem("scav_exp_shockwave")
PrecacheParticleSystem("scav_exp_water_shockwave")

function ENT:OnInit()
	if SERVER then
		self.filter = {self.Owner}
	else
		ParticleEffectAttach("scav_shockwave_1", PATTACH_ABSORIGIN_FOLLOW, self, 0)
		self:EmitSound("ambient/weather/thunder5.wav")
		self.Weapon = self:GetOwner():GetActiveWeapon()
		self.Owner = self:GetOwner()
	end
	self:DrawShadow(false)
	self.lasttrace = CurTime()
end

function ENT:Think()
	self.lasttrace = CurTime()
	if CLIENT then return end

	local tab = ents.FindInSphere(self:GetPos(), 300)
	for _, v in ipairs(tab) do
		if (v:GetMoveType() == MOVETYPE_VPHYSICS) and v:GetPhysicsObject():IsValid() then
			v:GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormalized() * 50000)
			v:SetPhysicsAttacker(self.Owner)
		end
	end
end

function ENT:OnImpact(hitent)
	if IsValid(hitent) then table.insert(self.filter, hitent) end
	local normal = self:GetVelocity():GetNormalized()
	local pos = self:GetPos()
	local dir = self.vel:GetNormalized()
	local ent = ents.FindInSphere(pos, 300)
	for _, v in ipairs(ent) do
		local intensity = (300 - pos:Distance(pos + v:OBBCenter())) / 15
		if IsValid(v) and (v:IsPlayer() or v:IsNPC() or v:IsNextBot()) and not v:IsFriendlyToPlayer(self.Owner) then
			v:InflictStatusEffect("Deaf", intensity, 0)
			local dmg = DamageInfo()
			dmg:SetDamage(intensity)
			dmg:SetDamageType(DMG_SONIC)
			dmg:SetAttacker(self.Owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(normal * intensity * 5000)
			v:SetVelocity(normal * intensity * 300)
			v:TakeDamageInfo(dmg)
		end
	end
	ParticleEffect("scav_exp_shockwave", pos, angle_zero, Entity(0))
	return true
end

if CLIENT then
	--ENT.mat = Material("sprites/heatwave")

	function ENT:Draw()
		--render.SetMaterial(self.mat)
		--render.DrawSprite(self:GetPos(), 32, 32, color_white)
	end
end

if SERVER then
	ENT.PhysType = 1
end
