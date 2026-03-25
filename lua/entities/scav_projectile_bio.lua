AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = ""
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.BBMins = Vector(-8, -8, -8)
ENT.BBMaxs = Vector(8, 8, 8)
ENT.Model = "models/weapons/w_bugbait.mdl"
PrecacheParticleSystem("scav_disease_1")
PrecacheParticleSystem("scav_exp_disease_1")
ENT.Gravity = Vector(0, 0, -600)
ENT.Speed = 2500
ENT.PhysType = 1
ENT.RemoveDelay = 0.2
ENT.NoDrawOnDeath = true

function ENT:OnInit()
	self.Created = CurTime()
	self:SetMaterial("models/flesh")
	self:DrawShadow(false)
	self.lasttrace = CurTime()
	
	if SERVER then
		self.filter = {self.Owner}
		return
	end
	
	self:EmitSound("physics/flesh/flesh_squishy_impact_hard2.wav")
	self.Weapon = self:GetOwner():GetActiveWeapon()
	self.Owner = self:GetOwner()
	self.Created = CurTime()
	ParticleEffectAttach("scav_disease_1", PATTACH_ABSORIGIN_FOLLOW, self, 0)
end

function ENT:Think()
	self:SetAngles(self:GetVelocity():Angle())
end

function ENT:OnImpact(hitent)
	if IsValid(hitent) then table.insert(self.filter, hitent) end
	local pos = self:GetPos()
	local dir = self.vel:GetNormalized()
	local ent = ents.FindInSphere(self:GetPos(), 300)
	self:EmitSound("physics/flesh/flesh_squishy_impact_hard3.wav")
	self:EmitSound("physics/flesh/flesh_squishy_impact_hard3.wav")
	ParticleEffect("scav_exp_disease_1", pos, angle_zero, game.GetWorld())
	for _, v in ipairs(ent) do
		if not IsValid(v) then continue end
		if not (v:IsPlayer() or v:IsNPC() or v:IsNextBot()) or v:IsFriendlyToPlayer(self.Owner) then continue end

		local intensity = (300 - pos:Distance(v:GetPos() + v:OBBCenter())) / 15
		v:InflictStatusEffect("Disease", intensity, 2)
	end
	return true
end
