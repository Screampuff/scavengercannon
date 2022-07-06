AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.dettime = 2
PrecacheParticleSystem("scav_smoketrail_2")


function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.dettime = CurTime()+2
	self.firstbounce = 0
	if SERVER then
		for k,v in ipairs(ents.GetAll()) do
			if v:IsNPC() then
				v:AddEntityRelationship(self,2,99)
			end
		end
		self.DangerPoint = self:CreateDangerSound()
	else
		ParticleEffectAttach("scav_smoketrail_2",PATTACH_ABSORIGIN_FOLLOW,self,0)
		--self.em = ParticleEmitter(self:GetPos())
	end
end

function ENT:Use()
end

function ENT:PhysicsUpdate()
end

function ENT:OnTakeDamage()
end

function ENT:PhysicsCollide(data,physobj)
end 

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch(hitent)
end

if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
	function ENT:Think()
		self:NextThink(CurTime()+0.1)
		return true
	end
end

if SERVER then

	ENT.drag = 1
	ENT.NextSound = 0

	function ENT:CreateDangerSound()
		local DangerSound = ents.Create("ai_sound")
		DangerSound:SetParent(self)
		DangerSound:SetLocalPos(vector_origin)
		DangerSound:SetKeyValue("soundtype", bit.bor(8,33554432) ) --danger, explosion
		DangerSound:SetKeyValue("duration",0.5)
		DangerSound:SetKeyValue("volume",130)
		return DangerSound
	end

	function ENT:Think()
		if self.NextSound < CurTime() then --staggering the sound emission to give the appearance of reaction times in the NPCs
			self.DangerPoint:Fire("EmitAISound",nil,0)
			self.NextSound = CurTime()+0.5
			--debugoverlay.Sphere(self.DangerSound:GetPos(),100,0.5,color_red,false)
		end
		if (self.dettime < CurTime()) or self.shouldexplode then
			if not self.expl then
				self.expl = true
				local edata = EffectData()
				edata:SetOrigin(self:GetPos())
				edata:SetNormal(vector_up)
				util.Effect("ef_scav_exp",edata)
				util.ScreenShake(self:GetPos(),100,1,1,800)
				util.BlastDamage(self,self.Owner,self:GetPos(),200,80)
				self:Remove()
			end
		end
		if not self.bounce then
			self:NextThink(CurTime()+0.05)
			return true
		end
	end

	function ENT:PhysicsCollide(data,physobj)
		self.drag = self.drag+1
		self:GetPhysicsObject():SetDragCoefficient(self.drag)
		if not self.bounce and IsValid(data.HitEntity) and (data.HitEntity:IsPlayer() or data.HitEntity:IsNPC() or data.HitEntity:IsNextBot()) then
			self:SetMoveType(MOVETYPE_NONE)
			self.shouldexplode = data.HitEntity
		end
		if data.Speed > 50 then
			self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(1,3)..".wav")
		end
		if data.HitEntity:IsWorld() then
			self.bounce = true
		end
	end

	function ENT:Touch(hitent)
	end

end
