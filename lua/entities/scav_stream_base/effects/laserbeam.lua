local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0

function ENT:OnInit()	
	if CLIENT then
		self.em = ParticleEmitter(self:GetPos())
	else
		self:EmitSound("weapons/stunstick/stunstick_impact1.wav",75,100)
		self.sound = CreateSound(self,"ambient/energy/electric_loop.wav")
		self.sound:Play()
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

if CLIENT then
	local beammat = Material("sprites/bluelaser1")
	local beamglowmat1 = Material("sprites/blueglow1")
	local beamglowmat2 = Material("sprites/blueglow2")
	local mins = Vector(-2,-2,-2)
	local maxs = Vector(2,2,2)
	local partgrav = Vector(0,0,96)
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		local ang = angpos.Ang
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		self:UpdateDLight()
		local tr = self:GetTrace(10000,nil,mins,maxs)
		local part = self.em:Add("particle/smokesprites_000"..math.random(1,9),tr.HitPos)
		if part then
			if tr.Entity:IsNPC() or tr.Entity:IsPlayer() or (_ZetasInstalled and tr.Entity:GetClass() == "npc_zetaplayer") then
				part:SetColor(100,100,100)
			end
			part:SetDieTime(1)
			part:SetStartSize(2)
			part:SetEndSize(8+math.random(0,16))
			part:SetStartAlpha(255)
			part:SetEndAlpha(20)
			part:SetGravity(partgrav)
			part:SetRoll(math.Rand(0,6.28))
			part:SetRollDelta(math.Rand(-6.28,6.28))
		end
	end
	
	function ENT:BuildDLight()
		self.dlight = DynamicLight(0)
		self.dlight.Pos = self:GetPos()
		self.dlight.r = 100
		self.dlight.g = 100
		self.dlight.b = 200
		self.dlight.Brightness = 2
		self.dlight.Size = 200
		self.dlight.Decay = 500
		self.dlight.DieTime = CurTime() + 1
	end

	function ENT:UpdateDLight()
		if self.dlight then
			self.dlight.Pos = self:GetPos()
			self.dlight.Brightness = 2
			self.dlight.Size = 200
			self.dlight.DieTime = CurTime() + 1
		else
			self:BuildDLight()
		end
	end
	
	local lasercol = Color(255,255,255,127)
	
	function ENT:Draw2()
		--cam.Start3D(EyePos(),EyeAngles())
		local angpos = self:GetMuzzlePosAng()
		local trace = self:GetTrace(10000,nil,mins,maxs)
		local ang = angpos.Ang
		local pos1 = angpos.Pos
		local pos2 = trace.HitPos
		render.SetMaterial(beammat)
		render.DrawBeam(pos1,pos2,math.random(20,30),0,1,lasercol)
		render.SetMaterial(beamglowmat2)
		render.DrawSprite(pos1,math.random(20,30),math.random(20,30),lasercol)
		--render.SetMaterial(self.mat3)
		if trace.Entity:IsNPC() or trace.Entity:IsPlayer() or (_ZetasInstalled and trace.Entity:GetClass() == "npc_zetaplayer") then
			local size = math.random(20,50)
			render.DrawSprite(pos2+(pos1-pos2):GetNormalized()*8,size,size,color_white)
		else
			render.DrawSprite(pos2+(pos1-pos2):GetNormalized()*8,math.random(20,30),math.random(20,30),lasercol)
		end
		--cam.End3D()
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_laser",true)
