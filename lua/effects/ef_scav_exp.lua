AddCSLuaFile()
EFFECT.flames = {"effects/fire_embers1","effects/fire_embers2","effects/fire_embers3","effects/fire_cloud1","effects/fire_cloud2","effects/muzzleflash1","effects/muzzleflash2","effects/muzzleflash3","effects/muzzleflash4"}
PrecacheParticleSystem("scav_exp_1")

function EFFECT:Init(data)
	self.Created = CurTime()
	local dlight = DynamicLight(0)
	if (dlight) then
		//local r, g, b, a = self:GetColor()
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 230
		dlight.b = 200
		dlight.Brightness = 4
		dlight.Size = 512
		dlight.Decay = 2500
		dlight.DieTime = CurTime() + 2
	end
	sound.Play("weapons/scav_gun/explosion.wav",self:GetPos(),100)
	sound.Play("weapons/scav_gun/explosion.wav",self:GetPos(),100)
	ParticleEffect("scav_exp_1",self:GetPos(),data:GetNormal():Angle(),self)
end

function EFFECT:Think()
	if CurTime() > self.Created+10 then
		return false
	else
		return true
	end
end

function EFFECT:Render()
end