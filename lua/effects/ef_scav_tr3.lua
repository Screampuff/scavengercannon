AddCSLuaFile()

EFFECT.mat = Material("sprites/bpist_tr1")
EFFECT.mat2 = Material("effects/scav_shine_HR")
EFFECT.lifetime = 0.1
EFFECT.col = Color(255, 128, 0, 255)

function EFFECT:Init(data)
	self.Weapon = data:GetEntity()
	if not IsValid(self.Weapon) then self:Remove() return end
	
	self.Created = CurTime()
	self.endpos = data:GetOrigin()
	self:SetPos(self:GetTracerShootPos(data:GetStart(), self.Weapon, 1))
	--self:SetRenderBoundsWS(self:GetPos(), self.endpos)
	local startpos = self:GetTracerShootPos(self:GetPos(), self.Weapon, 1)
	local ef = EffectData()
		ef:SetOrigin(self.endpos)
		ef:SetNormal((startpos - self.endpos):GetNormalized())
	util.Effect("ManhackSparks", ef)

	self.super = tobool(data:GetScale())
	
	self.Owner = self.Weapon.Owner
	if IsValid(self.Owner) then 
		self.Owner:EmitSound(self.super and "Weapon_MegaPhysCannon.Launch" or "Weapon_PhysCannon.Launch", self.super and 255 or nil)
	end

	if not self.super then return end

	self.mat = Material("sprites/scav_tr_phys")

	util.Effect("ManhackSparks", ef)
	util.Effect("ManhackSparks", ef)

	self.midpos = (self:GetPos() + self.endpos) / 2 + VectorRand() * 5
end

function EFFECT:Think()
	if self.Created + self.lifetime < CurTime() then
		return false
	end

	return true
end

function EFFECT:Render()
	self.startpos = self:GetTracerShootPos(self:GetPos(), self.Weapon, 1)
	self.dir = self.endpos - self.startpos
	if not self.super and CurTime() < self.Created + 0.02 then
		render.SetMaterial(self.mat2)
		render.DrawSprite(self:GetTracerShootPos(self:GetPos(), self.Weapon, 1), 16, 16, self.col)
	end
	render.SetMaterial(self.mat)
	render.DrawBeam(self.startpos, self.endpos, 8, 0, 1, color_white)

	if not self.super then return end

	render.StartBeam(3)
		render.AddBeam(self.startpos, 4, 0, color_white)
		render.AddBeam(self.midpos, 4, 0.5, color_white)
		render.AddBeam(self.endpos, 4, 1, color_white)
	render.EndBeam()
	render.DrawBeam(self.startpos, self.endpos, 8, 0, 1, color_white)
end
