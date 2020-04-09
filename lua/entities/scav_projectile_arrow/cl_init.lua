include('shared.lua')
ENT.mat = Material("effects/scav_shine6")
ENT.red = Color(255,0,0,255)
ENT.blue = Color(0,0,255,255)

function ENT:Draw()
	self:DrawModel()
	//render.SetMaterial(self.mat)
	//render.DrawSprite(self:GetPos(),48,48,self.col)
end

function ENT:Initialize()
	if self:GetSkin() == 0 then
		self.col = self.red
	else
		self.col = self.blue
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.lastupdate = CurTime()
end