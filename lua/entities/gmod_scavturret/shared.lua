ENT.Type            = "anim"
ENT.Base            = "base_wire_entity"

ENT.PrintName       = "Scav Turret"
ENT.Author          = ""
ENT.Contact         = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:GetAimVector()
	return self.Entity:GetAngles():Forward() * -1
end

function ENT:GetShootPos()
	return self.Entity:GetAttachment(1).Pos
end

function ENT:GetProjectileShootPos()
	return self.Entity:GetAttachment(1).Pos+self:GetAimVector() * 48 + self:GetVelocity() * 0.1
end

function ENT:GetActiveWeapon()
	return self
end

function ENT:GetEyeTraceNoCursor()
	local tab = {}
	tab.start = self:GetShootPos()
	tab.endpos = self:GetShootPos()+self:GetAimVector()*10000
	tab.mask = MASK_SHOT
	tab.filter = self
	return util.TraceLine(tab)
end