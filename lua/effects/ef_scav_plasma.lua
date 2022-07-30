AddCSLuaFile()
--EFFECT.mat = Material("effects/scav_shine5")
EFFECT.mins = Vector(-8,-8,-8)
EFFECT.maxs = Vector(8,8,8)
--EFFECT.sprites = {"effects/blood","effects/fleck_cement1","effects/fleck_cement2"}
--EFFECT.em = ParticleEmitter(vector_origin)
local color_yellowgreen = Color(85,255,0,255)

function EFFECT:Init(data)
	self.Created = UnPredictedCurTime()
	self.vel = data:GetStart()
	self:SetAngles((self.vel:GetNormalized()):Angle())
	self.Owner = data:GetEntity()
	self.lasttrace = UnPredictedCurTime()-0.1
	self.TracePos = self:GetPos()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:SetMaterial("models/scavplasma")
	--self:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()-self.Owner:GetAimVector():Angle():Up()*10)
	self.LastPos = self:GetPos()
	self:SetColor(color_yellowgreen)
	ParticleEffectAttach("scav_plasma_1",PATTACH_ABSORIGIN_FOLLOW,self,0)
end

function EFFECT:SetTracePos(pos)
	self.TracePos = pos
end

function EFFECT:GetTracePos()
	return self.TracePos
end

function EFFECT:Think()
	if self.Killed then
		return true
	end
	local vel = self.vel*math.max(UnPredictedCurTime()-self.lasttrace,0)
	local tracep = {}
	tracep.start = self:GetPos()
	tracep.filter = self.Owner
	tracep.endpos = self:GetPos()+vel
	tracep.mins = self.mins
	tracep.maxs = self.maxs
	tracep.mask = MASK_SHOT
	tr = util.TraceHull(tracep)
	if tr.Hit then
		util.Decal("fadingscorch",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		sound.Play("ambient/levels/canals/toxic_slime_sizzle3.wav",self:GetPos(),75)
		if IsValid(tr.Entity) then
			sound.Play("physics/cardboard/cardboard_box_strain2.wav",self:GetPos(),100)
		end
		ParticleEffect("scav_exp_plasma",tr.HitPos,Angle(0,0,0),Entity(0))
		self:SetPos(tr.HitPos)
		self.Killed = true
		SafeRemoveEntityDelayed(self,0.1)
	else
		self:SetTracePos(tr.HitPos)
	end
	self.lasttrace = CurTime()
	self.LastPos = self:GetPos()
	if CurTime()-self.Created < 0.25 then
		self:SetPos(LerpVector(math.Clamp((CurTime()-self.Created)*4,0,1),self:GetPos(),self:GetTracePos()))
	else
		self:SetPos(self:GetTracePos())
	end
	return true
end

--EFFECT.col = Color(200,200,255,128)

function EFFECT:Render()
	self:DrawModel()
	if self.Created+0.01 > UnPredictedCurTime() then
		return
	end
end
