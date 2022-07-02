include('shared.lua')
--ENT.mat = Material("effects/eball_finite_life")
ENT.mat = Material("effects/ar2_altfire1")
ENT.mat2 = Material("models/Effects/comball_glow1")
killicon.AddAlias("scav_projectile_comball","prop_combine_ball")

function ENT:Draw()
	render.SetMaterial(self.mat)
	render.DrawSprite(self:GetPos(),32,32,color_white)
end
