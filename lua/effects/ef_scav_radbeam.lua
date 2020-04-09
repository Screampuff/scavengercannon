AddCSLuaFile()

EFFECT.mat = Material("effects/blueblacklargebeam")
EFFECT.col = Color(200,255,0,255)
EFFECT.col2 = Color(190,255,0,255)
EFFECT.em = ParticleEmitter(vector_origin)

function EFFECT:Init(data)
	self.Created = CurTime()
	self.Weapon = data:GetEntity()
	if !self.Weapon || !self.Weapon:IsValid() then
		return false
	end
	self.Owner = self.Weapon:GetOwner()
	
	local tracep = {}
	//if self.Owner == GetViewEntity() then
	//	self:SetPos(self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
	//else
	//	self:SetPos(self.Owner:GetActiveWeapon():GetAttachment(self.Owner:GetActiveWeapon():LookupAttachment("muzzle")).Pos)
	//end
	//self:SetPos(self:GetTracerShootPos2(data:GetOrigin()))
	self.endpos = data:GetStart()
	self:SetPos(self:GetTracerShootPos2(self:GetPos()))
	ScavData.SetRenderBoundsFromStartEnd(self,self:GetPos(),self.endpos)
	local seg = (self.endpos-self:GetPos())/30
	for i=1,30 do
		local part = self.em:Add("particle/Particle_Glow_05",self:GetPos()+seg*i)
		if part then
			part:SetColor(190,255,0)
			part:SetVelocity(VectorRand()*10)
			part:SetDieTime(2)
			part:SetStartSize(2)
			part:SetEndSize(2)
			part:SetStartAlpha(128)
			part:SetEndAlpha(0)
			part:SetRoll(math.Rand(0,6.28))
			part:SetRollDelta(math.Rand(-6.28,6.28))
		end
	end
--	self.em:Finish()
	ParticleEffect("scav_exp_rad",self.endpos,Angle(0,0,0),Entity(0))
end

function EFFECT:Think()
	if !self.Weapon || !self.Weapon:IsValid() then
		return false
	end
	if self.Created+0.5 < CurTime() then
		return false
	end
	return true
end

function EFFECT:GetTracerShootPos2(start)
	if !self.Weapon:IsValid() then
		return start
	end
	if (self.Owner == GetViewEntity()) then
		return (self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
	elseif self.Owner != GetViewEntity() then
		return (self.Weapon:GetAttachment(self.Weapon:LookupAttachment("muzzle")).Pos)
	else
		return (self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos+self.Owner:GetAimVector():Angle():Right()*36-self.Owner:GetAimVector():Angle():Up()*36)
	end
end

function EFFECT:Render()
	if !self.hassetpos then
		self.startpos = (self:GetTracerShootPos2(self:GetPos()))
		self.hassetpos = true
	end
	render.SetMaterial(self.mat)
	render.DrawBeam(self.startpos,self.endpos || self:GetPos(),Lerp((CurTime()-self.Created)/0.5,32,0),0,1,self.col)
end