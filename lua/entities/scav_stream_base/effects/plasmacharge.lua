local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 2

PrecacheParticleSystem("scav_bigshot_charge")
PrecacheParticleSystem("scav_bigshot_charge_vm")

function ENT:OnInit()
	if CLIENT then
		//self:CreateParticleEffect("scav_bigshot_charge",0)
		//ParticleEffectAttach("scav_bigshot_charge",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
end

function ENT:BuildDLight()
	self.dlight = DynamicLight(0)
	self.dlight.Pos = self:GetPos()
	self.dlight.r = 100
	self.dlight.g = 200
	self.dlight.b = 100
	self.dlight.Brightness = 2
	self.dlight.Size = 400
	self.dlight.Decay = 500
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
	--self:SetParent()
	if self.sound then
		self.sound:Stop()
	end
	if CLIENT then
		vm = self:GetViewModel()
		if IsValid(vm) then
			vm:StopParticleEmission()
		end
		local wep = self.Weapon
		if IsValid(wep) then
			self.Weapon:StopParticleEmission()
		end
	end
end

function ENT:OnThink()
	if (self.dt.DeathTime == 0) then
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
	local vm = self:GetViewModel()
	local wep = self.Weapon
	if IsValid(wep) then
		self.Weapon:StopParticleEmission()
	end
	if IsValid(vm) then
		ParticleEffectAttach("scav_bigshot_charge_vm",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment("muzzle"))
	end
end

function ENT:OnWorldMode()
	local wep = self.Weapon
	local vm = self:GetViewModel()
	if IsValid(vm) then
		vm:StopParticleEmission()
	end
	if IsValid(wep) then
		--wep:CreateParticleEffect("scav_bigshot_charge",wep)
		ParticleEffectAttach("scav_bigshot_charge",PATTACH_POINT_FOLLOW,wep,wep:LookupAttachment("muzzle"))
	end
end

scripted_ents.Register(ENT,"scav_stream_plasmacharge")