local typetranslate = {
	[1] = "water_splash_01_droplets", --normal
--	[2] = "scav_muzzleflare2", --pulse rifle
--	[3] = "scav_muzzleflare3", --dark energy (blue)
--	[4] = "scav_muzzleflare4", --green energy
	}

function EFFECT:Init(data)

	self.Created = CurTime()
	local effecttype = math.Round(data:GetScale())
	self.Weapon = data:GetEntity()
	if self.Weapon:IsWeapon() then
		self.Owner = self.Weapon.Owner
	else
		self.Owner = self.Weapon
	end
	if not IsValid(self.Weapon) then
		return false
	end
	self:SetPos(self:GetTracerShootPos(self.Owner:GetShootPos(),self.Weapon,1))
	self:SetParent(self.Weapon)
	if (self.Owner == GetViewEntity()) and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()
		--ParticleEffectAttach(typetranslate[effecttype].."_vm",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment("muzzle"))
		ParticleEffectAttach(typetranslate[effecttype],PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment("muzzle"))
	else
		ParticleEffectAttach(typetranslate[effecttype],PATTACH_POINT_FOLLOW,self.Weapon,self.Weapon:LookupAttachment("muzzle"))
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end
