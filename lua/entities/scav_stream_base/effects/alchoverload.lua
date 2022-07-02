local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 2

PrecacheParticleSystem("alch_overload")
PrecacheParticleSystem("alch_overload_vm")

function ENT:OnInit()
	if CLIENT then
		self.sound = CreateSound(self,"ambient/machines/electric_machine.wav")
		self.sound:Play()
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
	self.dlight.Decay = 500
	self.dlight.DieTime = CurTime() + 1
end

function ENT:UpdateDLight()
	if self.dlight then
		self.dlight.Pos = self:GetPos()
		self.dlight.Brightness = math.Rand(0.3,2)
		self.dlight.Size = 400
		self.dlight.DieTime = CurTime() + 1
	else
		self:BuildDLight()
	end
end

function ENT:OnKill()
	self:SetParent()
	if self.sound then
		self.sound:Stop()
	end
	if CLIENT then
		local wep = self.Weapon
		local vm = self:GetViewModel()
		if IsValid(wep) then
			wep:StopParticles()
		end
		if IsValid(vm) then
			vm:StopParticles()
		end
	end
end

function ENT:OnThink()
	if (self:GetDeathTime() == 0) then
		if CLIENT then
			local angpos = self:GetMuzzlePosAng()
			self:SetPos(angpos.Pos)
			self:SetAngles(angpos.Ang)
			self:UpdateDLight()
		end
	else
		self:SetPos(Vector(-30000,-30000,-30000))
	end
end

function ENT:OnViewMode()
	local wep = self.Weapon
	local vm = self:GetViewModel()
	vm:StopParticles()
	ParticleEffectAttach("alch_overload_vm",PATTACH_ABSORIGIN_FOLLOW,vm,0)
end

function ENT:OnWorldMode()
	local wep = self.Weapon
	local vm = self:GetViewModel()
	wep:StopParticles()
	ParticleEffectAttach("alch_overload",PATTACH_ABSORIGIN_FOLLOW,wep,0)
end

scripted_ents.Register(ENT,"scav_stream_alchoverload")
