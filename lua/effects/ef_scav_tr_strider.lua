
local speed = 8000
local width = 2.5

local mat = Material("effects/gunshiptracer")

function EFFECT:Init(data)
	self.Weapon = data:GetEntity()
	self.Owner = self.Weapon.Owner
	self.startpos = self:GetTracerShootPos2(data:GetStart(),self.Weapon,1)
	self.endpos = data:GetOrigin()
	ScavData.SetRenderBoundsFromStartEnd(self,self.startpos,self.endpos)
	self.Created = UnPredictedCurTime()
	local dist = self.startpos:Distance(self.endpos)
	if (dist == 0) then
		self:Remove()
		return
	end
	self.Length = math.Rand(64,128)
	self.beamlength = self.Length/dist
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
	local progb2 = progress
	local progb1 = math.Clamp(progress+self.beamlength,0,1)
	beamstartvec.x = self.startpos.x+(self.endpos.x-self.startpos.x)*progb1
	beamstartvec.y = self.startpos.y+(self.endpos.y-self.startpos.y)*progb1
	beamstartvec.z = self.startpos.z+(self.endpos.z-self.startpos.z)*progb1
	beamendvec.x = self.startpos.x+(self.endpos.x-self.startpos.x)*progb2
	beamendvec.y = self.startpos.y+(self.endpos.y-self.startpos.y)*progb2
	beamendvec.z = self.startpos.z+(self.endpos.z-self.startpos.z)*progb2
	render.SetMaterial(mat)
	render.DrawBeam(beamstartvec,beamendvec,width,1,0,col)
end
