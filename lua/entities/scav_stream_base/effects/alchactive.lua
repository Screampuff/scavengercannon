local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 2

PrecacheParticleSystem("alch_active")

function ENT:OnInit()
	if CLIENT then
		ParticleEffectAttach("alch_active",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
end

function ENT:BuildDLight()
	self.dlight = DynamicLight(0)
	self.dlight.Pos = self:GetPos()
	self.dlight.r = 100
	self.dlight.g = 0
	self.dlight.b = 170
	self.dlight.Brightness = 2
	self.dlight.Size = 400
	self.dlight.Decay = 700
	self.dlight.DieTime = CurTime() + 1
end

function ENT:UpdateDLight()
	if self.dlight then
		self.dlight.Pos = self:GetPos()
		self.dlight.Brightness = 2
		self.dlight.Size = 400
		self.dlight.DieTime = CurTime() + 1
	else
		self:BuildDLight()
	end
end

function ENT:OnKill()
	self:SetParent()
end

function ENT:OnThink()
	if (self.dt.DeathTime == 0) && IsValid(self.Weapon) then
		local angpos = self:GetMuzzlePosAng()
		if !angpos then
			return
		end
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		if CLIENT then
			self:UpdateDLight()
		end
	else
		self:SetPos(Vector(-30000,-30000,-30000))
	end
end

function ENT:OnViewMode()
end

function ENT:OnWorldMode()
end

scripted_ents.Register(ENT,"scav_stream_alchactive")