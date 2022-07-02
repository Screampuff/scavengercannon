AddCSLuaFile()

--EFFECT.coltab = {["scav_gun"] = Color(200,200,255),["blackhole_gun"] = Color(128,0,0),["capture_device"] = Color(0,255,0),["alchemy_gun"] = Color(128,0,156)}
function EFFECT:Init(data)
	local dlight = DynamicLight(0)
	if (dlight) then
		--local r, g, b, a = self:GetColor()
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 200
		dlight.b = 180
		dlight.Brightness = 4
		dlight.Size = 512
		dlight.Decay = 2500
		dlight.DieTime = CurTime() + 2
	end
	self:EmitSound("ambient/explosions/explode_4.wav",125)
	self.em = ParticleEmitter(self:GetPos())
		--self:EmitSound("ambient/energy/ion_cannon_shot3.wav")
		local part = self.em:Add("effects/scav_shine5",self:GetPos())
		if part then
			part:SetColor(255,200,180)
			part:SetDieTime(0.1)
			part:SetStartSize(64)
			part:SetEndSize(256)
			part:SetStartAlpha(255)
			part:SetEndAlpha(255)
			part.Owner = data:GetEntity()
		end
--		self.em:Finish()
		for i=1,30 do
			local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),self:GetPos()+0*Vector(math.Rand(-7,7),math.Rand(-7,7),math.Rand(-7,7)))
			if part then
				part:SetColor(200,150,100)
				local vel = Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500))
				local lifeoffset = math.Rand(0,1)
				part:SetVelocity(vel)
				part:SetAirResistance(500)
				part:SetGravity(Vector(0,0,-50))
				part:SetDieTime(lifeoffset+1)
				part:SetStartSize(32)
				part:SetEndSize(128)
				part:SetStartAlpha(255)
				part:SetEndAlpha(20)
			end
--			self.em:Finish()
		end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
