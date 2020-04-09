include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:Think()
		self:NextThink(CurTime()+0.1)		
	return true
end