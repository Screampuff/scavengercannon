AddCSLuaFile()
//EFFECT.mat = Material("effects/scav_shine5")
EFFECT.mins = Vector(-3,-3,-3)
EFFECT.maxs = Vector(3,3,3)
//EFFECT.sprites = {"effects/blood","effects/fleck_cement1","effects/fleck_cement2"}
//EFFECT.em = ParticleEmitter(vector_origin)

function EFFECT:Init(data)
	self.Created = UnPredictedCurTime()
	self.vel = data:GetStart()
	self:SetAngles((self.vel:GetNormalized()):Angle())
	ParticleEffectAttach("portal_1_projectile_stream",PATTACH_ABSORIGIN_FOLLOW,self,0)
	self.Owner = data:GetEntity()
	self.lasttrace = UnPredictedCurTime()
	//self:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()-self.Owner:GetAimVector():Angle():Up()*10)
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
		sound.Play("ambient/levels/canals/toxic_slime_sizzle2.wav",self:GetPos(),75)
		//ParticleEffect("scav_exp_plasma",tr.HitPos,Angle(0,0,0),Entity(0))
		return false
	end
	self.lasttrace = CurTime()
	self:SetPos(self:GetPos()+vel)
	return true
end

//EFFECT.col = Color(200,200,255,128)

function EFFECT:Render()
	if self.Created+0.01 > UnPredictedCurTime() then
		return
	end
end