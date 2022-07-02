include('shared.lua')
local rendercol = Color(255,255,255,255)
local mat = Material("effects/scav_shine5")

function ENT:Draw()
	render.SetMaterial(mat)
	--render.DrawSprite(self:GetPos()-(self:GetLocalAngles():Forward()*16),64,64,Color(255,200,95,255))
	--render.DrawSprite(self:GetPos(),64,64,rendercol)
end

function ENT:OnRemove()
end
