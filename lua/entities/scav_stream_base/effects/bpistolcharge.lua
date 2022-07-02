local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0
ENT.Pitch = 100
PrecacheParticleSystem("scav_bp_charge")
		
function ENT:OnInit()	
	if CLIENT then
		self.em = ParticleEmitter(self:GetPos())
		self.sound = CreateSound(self,"ambient/energy/electric_loop.wav")
		self.sound:PlayEx(100,self.Pitch)
		ParticleEffectAttach("scav_bp_charge",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
end

function ENT:OnKill()
	if CLIENT and self.sound then
		self.sound:Stop()
	end
end

function ENT:OnSetupDataTables()
	self:NetworkVar("Float",0,"level")
end

if SERVER then
	function ENT:OnThink()

	end
end

if CLIENT then
	local chargemat = Material("effects/scav_shine_HR")
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		if angpos.Pos then
			local pos = angpos.Pos
			local ang = angpos.Ang
			self:SetPos(angpos.Pos)
			self:SetAngles(angpos.Ang)
			self:UpdateDLight()
		end
		local desiredpitch = self:Getlevel()*15+100
		self.Pitch = math.Approach(self.Pitch,desiredpitch,self.Weapon.ChargeRate*20*FrameTime())
		if not self.Killed then
			self.sound:PlayEx(100,self.Pitch)
		end
	end
	
	function ENT:BuildDLight()
		self.dlight = DynamicLight(0)
		self.dlight.Pos = self:GetPos()
		self.dlight.r = 255
		self.dlight.g = 128
		self.dlight.b = 0
		self.dlight.Brightness = 1
		self.dlight.Size = 100
		self.dlight.Decay = 500
		self.dlight.DieTime = CurTime() + 1
	end

	function ENT:UpdateDLight()
		if self.dlight then
			self.dlight.Pos = self:GetPos()
			self.dlight.Brightness = 1
			self.dlight.Size = 100
			self.dlight.DieTime = CurTime() + 1
		else
			self:BuildDLight()
		end
	end
	
	local glowcol = Color(255,128,0,255)
	
	function ENT:GetChargeglowScale()
		local ctime = CurTime()
		local refvar = self.Created
		local scale = math.Round(self:Getlevel()*(math.abs(math.sin(ctime*64))+1))
		return scale
	end
	
	function ENT:Draw2()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		render.SetMaterial(chargemat)
		local scale = self:GetChargeglowScale()
		render.DrawSprite(pos,scale,scale,glowcol)
	end
end

scripted_ents.Register(ENT,"scav_stream_bpcharge",true)
