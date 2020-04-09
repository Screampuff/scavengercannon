

function EFFECT:Init(data)
	local dlight = DynamicLight(0)
	if (dlight) then
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 200
		dlight.Brightness = 3
		dlight.Size = 128
		dlight.Decay = 2500
		dlight.DieTime = CurTime() + 1
	end
	self.em = ParticleEmitter(self:GetPos())
		for i=1,8 do
			local part = self.em:Add("effects/muzzleflash"..math.random(1,4),self:GetPos())
			if part then		
				part:SetColor(255,255,255)
				part:SetDieTime(0.1+math.Rand(0,0.2))
				part:SetStartSize(24)
				part:SetEndSize(64)
				part:SetStartAlpha(255)
				part:SetEndAlpha(math.random(0,255))
				part:SetColor(100,100,120)
				local vel = VectorRand()*60
				part:SetVelocity(vel)
				part:SetAirResistance(500)
			end
--			self.em:Finish()
		end
	sound.Play("weapons/pistol/pistol_fire3.wav",self:GetPos(),100,100)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end