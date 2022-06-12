local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"

PrecacheParticleSystem("scav_radio")
PrecacheParticleSystem("scav_radio_vm")

function ENT:OnInit()
	self.sound = CreateSound(self,"ambient/levels/labs/equipment_beep_loop1.wav")
	self.sound:Play()
	if CLIENT then
		//self:CreateParticleEffect("scav_radio",self:GetOwner():LookupAttachment("muzzle"))
	end
end

function ENT:OnKill()

	if self.sound then
		self.sound:Stop()
	end
	if CLIENT then
		vm = self:GetViewModel()
		local wep = self.Weapon
		if IsValid(vm) then
			vm:StopParticleEmission()
		end
		if IsValid(wep) then
			wep:StopParticleEmission()
		end
	end
end

function ENT:OnThink()
	if CLIENT then
		local angpos = self:GetMuzzlePosAng()
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
	end
end

function ENT:OnViewMode()
	local vm = self:GetViewModel()
	local wep = self.Weapon
	if IsValid(wep) then
		wep:StopParticleEmission()
	end
	if IsValid(vm) then
		ParticleEffectAttach("scav_radio_vm",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment("muzzle"))
	end
end

function ENT:OnWorldMode()
	local wep = self.Weapon
	local vm = self:GetViewModel()
	if IsValid(vm) then
		vm:StopParticleEmission()
	end
	if IsValid(wep) then
		ParticleEffectAttach("scav_radio",PATTACH_POINT_FOLLOW,wep,wep:LookupAttachment("muzzle"))
	end
end

scripted_ents.Register(ENT,"scav_stream_radio")