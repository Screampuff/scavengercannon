include('shared.lua')
ENT.mat = Material("effects/scav_shine6")
ENT.grav1 = Vector(0,0,50)

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:Think()
	self:NextThink(CurTime()+0.1)
	return true
end