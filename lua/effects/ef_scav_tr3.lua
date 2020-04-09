AddCSLuaFile()

EFFECT.mat = Material("sprites/bpist_tr1")
EFFECT.mat2 = Material("effects/scav_shine_HR")
EFFECT.lifetime = 0.1
EFFECT.col = Color(255,128,0,255)

function EFFECT:Init(data)
	self.Weapon = data:GetEntity()
	self.Owner = self.Weapon.Owner
	self.Created = CurTime()
	self.endpos = data:GetOrigin()
	self:SetPos(self:GetTracerShootPos(data:GetStart(),self.Weapon,1))
	//self:SetRenderBoundsWS(self:GetPos(),self.endpos)
	local startpos = self:GetTracerShootPos(self:GetPos(),self.Weapon,1)
	local ef = EffectData()
	ef:SetOrigin(self.endpos)
	ef:SetNormal((startpos-self.endpos):Normalize())
	util.Effect("ManhackSparks",ef)
	self.Owner:EmitSound("Weapon_PhysCannon.Launch")
end

function EFFECT:Think()
	if self.Created+self.lifetime < CurTime() then
		return false
	end

	return true
end

function EFFECT:Render()
	self.startpos = self:GetTracerShootPos(self:GetPos(),self.Weapon,1)
	self.dir = self.endpos-self.startpos
	if CurTime() < self.Created+0.02 then
		render.SetMaterial(self.mat2)
		render.DrawSprite(self:GetTracerShootPos(self:GetPos(),self.Weapon,1),16,16,self.col)
	end
	render.SetMaterial(self.mat)
	render.DrawBeam(self.startpos,self.endpos,8,0,1,color_white)
end