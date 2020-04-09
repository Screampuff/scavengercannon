local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"


function ENT:OnInit()
	self.sound = CreateSound(self,"ambient/gas/steam_loop1.wav")
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
	local sprites = {"particle/smokesprites_0001","particle/smokesprites_0002","particle/smokesprites_0003","particle/smokesprites_0004","effects/fleck_glass1","effects/fleck_glass2","effects/fleck_glass3"}
	
	local function partthink(part)
		local tr	
			part.tracep.start = part.lastpos
			part.tracep.mask = MASK_SHOT
			part.tracep.endpos = part.lastpos+part:GetVelocity()*(CurTime()-part.lastmove)
			tr = util.TraceLine(part.tracep)
			
		part.lastmove = CurTime()
		part.lastpos = part:GetPos()
		if tr.Hit then
			part:SetVelocity(vector_origin)
			if part.sprite < 4 then
				part:SetEndSize(48)
				part:SetEndAlpha(0)
			else
				part:SetVelocity(VectorRand()*100)
			end
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
			local sprite = math.random(1,7)
			local part = self.em:Add(sprites[sprite],pos)
			if part then
				local velscale = math.Rand(1,2*i)*2*forcescale
				part:SetVelocity(VectorRand()*math.random(0,10)+aimvec*50*velscale+vel)
				part:SetColor(170,220,255)
				part:SetDieTime(2/velscale)
				part:SetStartSize(2)
				if sprite > 4 then
					part:SetEndSize(4)
				else
					part:SetEndSize(8+math.random(0,48))
				end
				part.sprite = sprite
				part:SetStartAlpha(100)
				part:SetEndAlpha(20)
				part:SetGravity(Vector(0,0,math.random(-96/((2*i)*velscale),0)))
				part:SetRoll(math.Rand(0,6.28))
				part:SetRollDelta(math.Rand(-6.28,6.28))
				part:SetThinkFunction(partthink)
				part.lastpos = part:GetPos()
				part.lastmove = CurTime()
				part.tracep = {}
				part.tracep.filter = self.Owner
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
scripted_ents.Register(ENT,"scav_stream_freezegas")