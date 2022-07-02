ENT.Type = "anim"
ENT.Base = "scav_vprojectile_base"
ENT.PrintName = ""
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.BBMins = Vector(-8,-8,-8)
ENT.BBMaxs = Vector(8,8,8)
ENT.Model = "models/weapons/w_bugbait.mdl"
PrecacheParticleSystem("scav_disease_1")
PrecacheParticleSystem("scav_exp_disease_1")
ENT.Gravity = Vector(0,0,-600)
ENT.Speed = 2500
ENT.PhysType = 1
ENT.RemoveDelay = 0.2
ENT.NoDrawOnDeath = true

function ENT:OnInit()
	self.Created = CurTime()
	if SERVER then
		self.filter = {self.Owner}
	else
		self:EmitSound("physics/flesh/flesh_squishy_impact_hard2.wav")
		self.Weapon = self:GetOwner():GetActiveWeapon()
		self.Owner = self:GetOwner()
		self.Created = CurTime()
		ParticleEffectAttach("scav_disease_1",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
	self:SetMaterial("models/flesh")
	self:DrawShadow(false)
	self.lasttrace = CurTime()
end

function ENT:Think()
	self:SetAngles(self:GetVelocity():Angle())
end

function ENT:OnImpact(hitent)
	table.insert(self.filter,hitent)
	local pos = self:GetPos()
	local dir = self.vel:GetNormalized()
	local ent = ents.FindInSphere(self:GetPos(),300)
	self:EmitSound("physics/flesh/flesh_squishy_impact_hard3.wav")
	self:EmitSound("physics/flesh/flesh_squishy_impact_hard3.wav")
	ParticleEffect("scav_exp_disease_1",pos,Angle(0,0,0),game.GetWorld())
	for k,v in ipairs(ent) do
		local intensity = (300-pos:Distance(v:GetPos()+v:OBBCenter()))/15
		if (v:IsPlayer() or v:IsNPC()) and not v:IsFriendlyToPlayer(self.Owner) then
			v:InflictStatusEffect("Disease",intensity,2)
		end
	end
	return true
end
