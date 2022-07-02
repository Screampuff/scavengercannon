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

