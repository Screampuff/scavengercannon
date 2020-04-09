ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "scavenger arrow/bolt"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = "DON'T FUCKING SPAWN THIS SHIT I'M SERIOUS"
ENT.lastupdate = 0

function ENT:Use()
end

function ENT:Think()
	if self.selfkill == 1 and SERVER then
		self:Remove()
	end
		self:NextThink(CurTime()+0.01)
	return true
end

function ENT:PhysicsUpdate()
end

function ENT:OnTakeDamage()
end


function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch(hitent)
end

function ENT:OnRemove()
end
