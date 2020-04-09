EFFECT.Created = 0
EFFECT.Ent = NULL

local scalevec = 0
local partgrav = Vector(0,0,-50)

function EFFECT:Init(data)
	self.Created = UnPredictedCurTime()
	self.Ent = data:GetEntity()
	self.LifeTime = math.max(0.5,data:GetScale())
	self.em = ParticleEmitter(self:GetPos())
	if IsValid(self.Ent) then
		self:SetParent(self.Ent)
		self.Ent:SetModelScale(scalevec,0)
		self.Ent:SetNoDraw(false)
	end
end

function EFFECT:Think()
	local scaleamt = math.Clamp((UnPredictedCurTime()-self.Created)*4,0.05,1)
	if !IsValid(self.Ent) || (UnPredictedCurTime() > self.Created+self.LifeTime) then
		return false
	end
	scalevec = scaleamt
	self.Ent:SetModelScale(scalevec,0)
	if self.em then
		local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),self.Ent:GetPos()+self.Ent:OBBCenter())
        if part then
            part:SetColor(180,180,180)
            local vel = VectorRand()*math.random(40,80)
            local lifeoffset = math.Rand(0,1)
            part:SetRoll(math.Rand(0,3.14))
            part:SetRollDelta(math.Rand(-1,1))
            part:SetVelocity(vel)
            part:SetAirResistance(100)
            part:SetGravity(partgrav)
            part:SetDieTime(lifeoffset+1)
            part:SetStartSize(16)
            part:SetEndSize(40)
            part:SetStartAlpha(60)
            part:SetEndAlpha(0)
        end
	end
--        self.em:Finish()
	return true
end

function EFFECT:Render()
	return true
end
        