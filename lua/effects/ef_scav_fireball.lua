AddCSLuaFile()
EFFECT.mins = Vector(-32,-32,-32)
EFFECT.maxs = Vector(32,32,32)

function EFFECT:Init(data)
	self.Created = UnPredictedCurTime()
	self.vel = data:GetStart()
	self:SetAngles((self.vel:GetNormalized()):Angle())
	if IsMounted(440) then --TF2
		timer.Simple(.00625,function() ParticleEffectAttach("projectile_fireball",PATTACH_ABSORIGIN_FOLLOW,self,0) end) --slight delay helps weapon not flash so violently when firing at things very close to you
	else
		ParticleEffectAttach("scav_projectile_fireball",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
	self.Owner = data:GetEntity()
	self.lasttrace = UnPredictedCurTime()
end

function EFFECT:BuildDLight()
	self.dlight = DynamicLight(0)
	self.dlight.Pos = self:GetPos()
	self.dlight.r = 255
	self.dlight.g = 120
	self.dlight.b = 50
	self.dlight.Brightness = 1.5
	self.dlight.Size = 300
	self.dlight.Decay = 500
	self.dlight.DieTime = CurTime() + 1
end

function EFFECT:UpdateDLight()
	if self.dlight then
		self.dlight.Pos = self:GetPos()
		self.dlight.Brightness = 1.5
		self.dlight.Size = 300
		self.dlight.DieTime = CurTime() + 1
	else
		self:BuildDLight()
	end
end

local tracep = {}
	tracep.mins = EFFECT.mins
	tracep.maxs = EFFECT.maxs
	tracep.mask = MASK_SHOT
	
function EFFECT:Think()
	local vel = self.vel*math.max(UnPredictedCurTime()-self.lasttrace,0)
	tracep.start = self:GetPos()
	tracep.filter = self.Owner
	tracep.endpos = self:GetPos()+vel
	tr = util.TraceHull(tracep)
	if tr.Hit then
		util.Decal("fadingscorch",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		if IsMounted(440) then --TF2
			sound.Play("weapons/dragons_fury_impact.wav",self:GetPos(),75)
		else
			sound.Play("ambient/fire/mtov_flame2.wav",self:GetPos(),75,150,1)
		end
		return false
	end
	self.lasttrace = CurTime()
	self:SetPos(self:GetPos()+vel)
	if GetConVar("cl_scav_high"):GetBool() then
		self:UpdateDLight()
	end
	return true
end

function EFFECT:Render()
	if self.Created+0.01 > UnPredictedCurTime() then
		return
	end
end