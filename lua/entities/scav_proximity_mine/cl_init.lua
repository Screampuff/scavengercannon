include('shared.lua')
ENT.mat = Material("effects/brightglow_y")
ENT.ready = false
		
function ENT:Draw()
	render.SetMaterial(self.mat)
	if self.ready then
		//if (self.inrange) then
		//	render.DrawSprite(self:GetPos(),32,32,Color(255,0,0,180))
		//else
		//	render.DrawSprite(self:GetPos(),32,32,Color(255,200,95,180))
		//end
	end
	self.Entity:DrawModel()
end

function ENT:PhysicsUpdate()
end