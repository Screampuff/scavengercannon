local typetranslate = {
	[1] = "scav_muzzleflare", --normal
	[2] = "scav_muzzleflare2", --pulse rifle
	[3] = "scav_muzzleflare3", --dark energy (blue)
	[4] = "scav_muzzleflare4", --green energy
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
	if !self.Weapon || !self.Weapon:IsValid() then
		return false
	end
	self:SetPos(self:GetTracerShootPos(self.Owner:GetShootPos(),self.Weapon,1))
	self:SetParent(self.Weapon)
	if (self.Owner == GetViewEntity()) && self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()
		ParticleEffectAttach(typetranslate[effecttype].."_vm",PATTACH_POINT_FOLLOW,vm,vm:LookupAttachment("muzzle"))
	else
		ParticleEffectAttach(typetranslate[effecttype],PATTACH_POINT_FOLLOW,self.Weapon,self.Weapon:LookupAttachment("muzzle"))
	end

	self.dlight = DynamicLight(0)

		self.dlight.Pos = self:GetPos()
		self.dlight.r = 140
		self.dlight.g = 130
		self.dlight.b = 100
		self.dlight.Brightness = 2
		self.dlight.Size = 200
		self.dlight.Decay = 500
		self.dlight.DieTime = CurTime() + 1
		//self.shootpos = self:GetTracerShootPos(self.Owner:GetShootPos(),self.Weapon,1)	
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end