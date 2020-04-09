local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"


function ENT:OnInit()
	self.sound = CreateSound(self,"ambient/gas/cannister_loop.wav")
	self.sound:Play()
	if CLIENT then
		//self:CreateParticleEffect("scav_flamethrower",self:GetOwner():LookupAttachment("muzzle"))
		self.em = ParticleEmitter(self:GetPos())
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end



if CLIENT then
	
	local function partthink(part)
		part.tracep.start = part.lastpos
		part.tracep.mask = MASK_SHOT
		part.tracep.endpos = part.lastpos+part:GetVelocity()*(CurTime()-part.lastmove)
		tr = util.TraceLine(part.tracep)
		
		part.lastmove = CurTime()
		part.lastpos = part:GetPos()
		if tr.Hit then
			util.Decal("paintsplatblue",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
			part:SetVelocity(vector_origin)
			part:SetEndSize(48)
			part:SetEndAlpha(0)
		end
		part:SetNextThink(CurTime()+0.1)
	end
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		local pos = angpos.Pos
		local forcescale = 1
		if self.Weapon && self.Weapon:IsValid() && (self.Weapon:GetClass() == "scav_gun") then
			forcescale = self.Weapon.dt.ForceScale
		end
		local aimvec = self.Player:GetAimVector()
		local vel = self.Player:GetVelocity()
		for i=1,3 do
			local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),pos)
			if part then
				local velscale = math.Rand(1,2*i)*forcescale
				part:SetVelocity(VectorRand()*math.random(0,30)+aimvec*50*velscale+vel)
				part:SetColor(200,200,250)
				part:SetDieTime(2/velscale)
				part:SetStartSize(2)
				part:SetEndSize(8+math.random(0,16))
				part:SetStartAlpha(255)
				part:SetEndAlpha(20)
				part:SetGravity(Vector(0,0,math.random(-96/((2*i)*velscale),0)))
				part:SetRoll(math.Rand(0,6.28))
				part:SetRollDelta(math.Rand(-6.28,6.28))
				part:SetThinkFunction(partthink)
				part.lastpos = part:GetPos()
				part.lastmove = CurTime()
				part.tracep = {}
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
scripted_ents.Register(ENT,"scav_stream_extinguisher")