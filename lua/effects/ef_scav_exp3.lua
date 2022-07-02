AddCSLuaFile()

--EFFECT.coltab = {["scav_gun"] = Color(200,200,255),["blackhole_gun"] = Color(128,0,0),["capture_device"] = Color(0,255,0),["alchemy_gun"] = Color(128,0,156)}
function EFFECT:Init(data)
	local dlight = DynamicLight(0)
	if (dlight) then
		--local r, g, b, a = self:GetColor()
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 200
		dlight.Brightness = 8
		dlight.Size = 2048
		dlight.Decay = 4096
		dlight.DieTime = CurTime() + 0.5
	end
	self:EmitSound("ambient/explosions/explode_4.wav",125)
	self.em = ParticleEmitter(self:GetPos())
		--self:EmitSound("ambient/energy/ion_cannon_shot3.wav")
		local part = self.em:Add("effects/scav_shine5",self:GetPos())
		if part then
			part:SetColor(255,255,200)
			part:SetDieTime(0.3)
			part:SetStartSize(64)
			part:SetEndSize(512)
			part:SetStartAlpha(255)
			part:SetEndAlpha(255)
			part.Owner = data:GetEntity()
		end
--		self.em:Finish()
		for i=1,60 do
			local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),self:GetPos()+Vector(math.Rand(-128,128),math.Rand(-128,128),math.Rand(-128,128)))
			if part then
				part:SetColor(40,40,40)
				local vel = Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000))
				local lifeoffset = math.Rand(0,1)
				part:SetVelocity(vel)
				part:SetAirResistance(500)
				part:SetGravity(Vector(0,0,-50))
				part:SetDieTime(lifeoffset+10)
				part:SetStartSize(32)
				part:SetEndSize(1024)
				part:SetStartAlpha(255)
				part:SetEndAlpha(20)
			end
--			self.em:Finish()
		end
		local normal = data:GetNormal()
		for i=1,30 do
			local ef = EffectData()
			ef:SetOrigin(self:GetPos()+normal*48+VectorRand()*32)
			ef:SetStart((normal+VectorRand()*0.2)*math.random(8,16)*100)
			util.Effect("ef_scav_debris",ef)
		end
	ParticleEffect("scav_exp_fireball3_a",self:GetPos(),Angle(0,0,0),Entity(0))
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
