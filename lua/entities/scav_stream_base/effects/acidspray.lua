local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"

PrecacheParticleSystem("scav_exp_acid")

function ENT:OnInit()
	if SERVER then
		self.sound = CreateSound(self,"ambient/water/water_flow_loop1.wav")
		self.sound:PlayEx(0.4,100)
	else
		self.em = ParticleEmitter(self:GetPos())
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

if CLIENT then

	local function partthink(self)
		local tr	
		self.tracep.start = self.lastpos
		self.tracep.mask = MASK_SHOT
		self.tracep.endpos = self.lastpos+self:GetVelocity()*(CurTime()-self.lastmove)
		tr = util.TraceLine(self.tracep)
		self.lastmove = CurTime()
		self.lastpos = self:GetPos()
		if tr.Hit then
			if math.random(1,6) == 1 then
				ParticleEffect("scav_exp_acid",tr.HitPos,tr.HitNormal:Angle(),Entity(0))
			end
			util.Decal("fadingscorch",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
			//self:SetVelocity(vector_origin)
			//self:SetEndSize(48)
			self:SetEndAlpha(0)
			local dir = self:GetVelocity():GetNormalized()
			self:SetVelocity((dir-(2*tr.HitNormal*dir:Dot(tr.HitNormal)))*self:GetVelocity():Length()*0.5)
			
			local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),tr.HitPos)
			if part then
				part:SetDieTime(1)
				part:SetStartSize(2)
				part:SetEndSize(8+math.random(0,16))
				part:SetStartAlpha(255)
				part:SetEndAlpha(20)
				part:SetGravity(Vector(0,0,96))
				part:SetRoll(math.Rand(0,6.28))
				part:SetRollDelta(math.Rand(-6.28,6.28))
			end
--			self.em:Finish()
			sound.Play("ambient/levels/canals/toxic_slime_sizzle"..math.random(2,4)..".wav",tr.HitPos,50,100)
		end
		self:SetNextThink(CurTime()+0.1)
	end

	local partgrav = Vector(0,0,-96)
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		local forcescale = 1
		if self.Weapon && self.Weapon:IsValid() && (self.Weapon:GetClass() == "scav_gun") then
			forcescale = self.Weapon.dt.ForceScale
		end
		local pos = angpos.Pos
		local vel = self.Player:GetVelocity()
		local aimvec = self.Player:GetAimVector()
		for i=1,3 do
			local part = self.em:Add("effects/scav_shine5",pos)
			if part then
				local velscale = math.Rand(1,2*i)*forcescale
				part:SetColor(211,234,134)
				part:SetVelocity((aimvec+VectorRand()*0.1):GetNormalized()*100*velscale+vel)
				part:SetDieTime(2/velscale)
				part:SetStartSize(2)
				part:SetEndSize(2+math.random(0,8))
				part:SetStartAlpha(128)
				part:SetEndAlpha(0)
				part:SetGravity(partgrav)
				part:SetRoll(math.Rand(0,6.28))
				part:SetRollDelta(math.Rand(-6.28,6.28))
				part:SetThinkFunction(partthink)
				part.lastpos = part:GetPos()
				part.lastmove = CurTime()
				part.tracep = {}
				part.em = self.em
				part:SetNextThink(CurTime()+0.1)		
			end
		end
--		self.em:Finish()
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
	
end

scripted_ents.Register(ENT,"scav_stream_aspray")