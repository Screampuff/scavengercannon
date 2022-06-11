AddCSLuaFile()

local mat_beam = Material("sprites/bpist_tr1")
//EFFECT.mat2 = Material("effects/scav_shine_HR")
local mat_flare = Material("effects/scav_shine_HR")
local col = Color(255,128,0,255)
local col_almostopaque = Color(255,255,255,254)
EFFECT.lifetime = 0.2

function EFFECT:Init(data)
	self:SetColor(col_almostopaque)
	self.Weapon = data:GetEntity()
	self.Owner = self.Weapon.Owner
	self.Created = CurTime()
	self.endpos = data:GetOrigin()
	self:SetPos(self:GetTracerShootPos(data:GetStart(),self.Weapon,1))
	ScavData.SetRenderBoundsFromStartEnd(self,self:GetPos(),self.endpos)
	local startpos = self:GetTracerShootPos(self:GetPos(),self.Weapon,1)
	local ef = EffectData()
	ef:SetOrigin(self.endpos)
	local dir = (startpos-self.endpos):GetNormalized()
	ef:SetNormal(dir)
	util.Effect("ManhackSparks",ef)
	ParticleEffect("scav_exp_bp",self.endpos,dir:Angle(),Entity(0))
	if GetConVar("cl_scav_high"):GetBool() then
		self:BuildDLight()
	end
	self.VPHandle = util.GetPixelVisibleHandle()
end

function EFFECT:BuildDLight()
	self.dlight = DynamicLight(0)
	self.dlight.Pos = self.endpos
	self.dlight.r = 255
	self.dlight.g = 128
	self.dlight.b = 0
	self.dlight.Brightness = 1
	self.dlight.Size = 67
	self.dlight.Decay = 201
	self.dlight.DieTime = CurTime()+1
end

function EFFECT:Think()
	if self.Created+self.lifetime < CurTime() then
		return false
	end

	return true
end

function EFFECT:Render()
	if !self.startpos then
		self.startpos = self:GetTracerShootPos(self:GetPos(),self.Weapon,1)
		self.dir = self.endpos-self.startpos
		self.lifetime = self.endpos:Distance(self.startpos)/10000
	end
	local ctime = CurTime()
	if ctime < self.Created+0.02 then
		render.SetMaterial(mat_flare)
		render.DrawSprite(self:GetTracerShootPos(self.endpos,self.Weapon,1),16,16,col)
	end
	render.SetMaterial(mat_beam)
	render.DrawBeam(Lerp((ctime-self.Created)/self.lifetime,self.startpos,self.endpos),self.endpos,Lerp((ctime-self.Created)/self.lifetime,32,0),0,0.1,color_white)
end