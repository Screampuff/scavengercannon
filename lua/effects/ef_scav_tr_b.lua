AddCSLuaFile()

local speed = 8000
local length = 160
local width = 3

--EFFECT.mat = Material("effects/energysplash")
local mat = Material("effects/laser_tracer")
local mat2 = Material("effects/yellowflare")
EFFECT.lifetime = 0.2
local col = Color(255,255,180,255)

function EFFECT:Init(data)
	--if 1 then
	--	util.Effect("Tracer",data)
	--	self:Remove()
	--	return
	--end
	self.Weapon = data:GetEntity()
	self.Owner = self.Weapon.Owner
	self.startpos = self:GetTracerShootPos2(data:GetStart(),self.Weapon,1)
	--print(self.startpos)
	--print(data:GetStart(),self.startpos,self.Owner == GetViewEntity())
	self.endpos = data:GetOrigin()
	ScavData.SetRenderBoundsFromStartEnd(self,self.startpos,self.endpos)
	self.Created = UnPredictedCurTime()
	local dist = self.startpos:Distance(self.endpos)
	if (dist == 0) then
		self:Remove()
		return
	end
	self.beamlength = length/dist
	self.LifeTime = dist/speed
	self.DeathTime = UnPredictedCurTime()+self.LifeTime
end

function EFFECT:GetTracerShootPos2(start)
	if not self.Weapon:IsValid() then
		return start
	end
	if (self.Owner == GetViewEntity()) then
		return (self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
	elseif self.Owner ~= GetViewEntity() then
		return self.Weapon:GetTracerOrigin() or (self.Weapon:GetAttachment(self.Weapon:LookupAttachment("muzzle")).Pos)
	else
		return (self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos+self.Owner:GetAimVector():Angle():Right()*36-self.Owner:GetAimVector():Angle():Up()*36)
	end
end

function EFFECT:Think()
	--do return false end
	if (self.Created+self.LifeTime < UnPredictedCurTime()) and (UnPredictedCurTime()-self.Created > 0.1) then
		return false
	end
	return true
end

local beamstartvec = Vector()
local beamendvec = Vector()

function EFFECT:Render()
	local progress = math.Clamp((UnPredictedCurTime()-self.Created)/self.LifeTime,0,1)
	local progb1 = progress
	local progb2 = math.Clamp(progress+self.beamlength,0,1)
	beamstartvec.x = self.startpos.x+(self.endpos.x-self.startpos.x)*progb1
	beamstartvec.y = self.startpos.y+(self.endpos.y-self.startpos.y)*progb1
	beamstartvec.z = self.startpos.z+(self.endpos.z-self.startpos.z)*progb1
	beamendvec.x = self.startpos.x+(self.endpos.x-self.startpos.x)*progb2
	beamendvec.y = self.startpos.y+(self.endpos.y-self.startpos.y)*progb2
	beamendvec.z = self.startpos.z+(self.endpos.z-self.startpos.z)*progb2

	render.SetMaterial(mat)
	render.DrawBeam(beamstartvec,beamendvec,width,1,0,col)
	local scale = 1-math.Clamp((UnPredictedCurTime()-self.Created)*10,0,1)
	if scale > 0 then
		render.SetMaterial(mat2)
		render.DrawSprite(self.endpos,scale*24,scale*24,color_white)
	end
end
