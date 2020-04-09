AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.trmin = Vector(-24,-24,-24)
ENT.trmax = Vector(24,24,24)

function ENT:PhysicsCollide(data,physobj)

end

function ENT:StartTouch()
end

function ENT:EndTouch()
end

function ENT:Touch(hitent)
end

function ENT:OnTakeDamage()
end

function ENT:OnRemove()
end