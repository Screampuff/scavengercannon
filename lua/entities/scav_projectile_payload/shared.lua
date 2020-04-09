ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "payload bomb"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.dettime = 2

function ENT:Initialize()
	self.Entity:PhysicsInitBox(Vector(-24,-24,-24),Vector(24,24,24))
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	if SERVER then
		for k,v in ipairs(ents.GetAll()) do
			if v:IsNPC() then
				v:AddEntityRelationship(self,2,99)
			end
		end
	else
		self:EmitSound("items/cart_explode_trigger.wav")
	end
end

function ENT:Use()
end

function ENT:PhysicsUpdate()
	self:SetLocalAngles((self:GetPhysicsObject():GetVelocity()*-1):Angle())
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

