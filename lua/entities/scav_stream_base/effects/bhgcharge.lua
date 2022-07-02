local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0.3
ENT.Pitch = 100
ENT.AngOffset = Angle(90,0,0)
PrecacheParticleSystem("scav_bhg_charge")
		
function ENT:OnInit()	
	if CLIENT then
		ParticleEffectAttach("scav_bhg_charge",PATTACH_ABSORIGIN_FOLLOW,self,0)
	end
end

function ENT:OnKill()
	self:StopParticles()
	if CLIENT and self.sound then
		self.sound:Stop()
	end
end

function ENT:OnSetupDataTables()
	self:NetworkVar("Float",0,"Charge")
	self:NetworkVar("Float",1,"LastWaypointSet")
end

if SERVER then
	function ENT:OnThink()

	end
end

if CLIENT then
	local chargemat = Material("effects/scav_shine_HR")
	local glowcol = Color(255,128,128,255)
	local lasercol = Color(255,0,0,255)
	local beammat = Material("trails/laser")
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		local ang = angpos.Ang
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		self:UpdateDLight()
	end
	
	function ENT:BuildDLight()
		self.dlight = DynamicLight(0)
		self.dlight.Pos = self:GetPos()
		self.dlight.r = 255
		self.dlight.g = 128
		self.dlight.b = 128
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
	
	
	
	function ENT:GetChargeglowScale()
		if self.Killed then
			return 0
		end
		local ctime = CurTime()
		local refvar = self.Created
		local scale = math.max(0,math.Round(self:GetCharge()*15*(math.abs(math.sin(ctime*64))+1)))
		return scale
	end
	
	local beam_mins = Vector(-4,-4,-4)
	local beam_maxs = Vector(4,4,4)
	
	function ENT:Draw2()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		render.SetMaterial(chargemat)
		local scale = self:GetChargeglowScale()
		render.DrawSprite(pos,scale,scale,glowcol)
		render.SetMaterial(beammat)
		local endpos
		if self:IsInViewMode() and (self.Player:GetViewModel():GetActivity() ~= ACT_VM_FIDGET) then
			endpos = self:GetModelTrace(8000,self.Player,beam_mins,beam_maxs,MASK_SOLID).HitPos
		else
			endpos = self:GetTrace(8000,self.Player,beam_mins,beam_maxs,MASK_SOLID).HitPos
		end
		render.DrawBeam(pos,endpos,2+(1-math.Clamp(CurTime()-self:GetLastWaypointSet(),0,1))*28,0,1,lasercol)
		--render.SetMaterial(beammat)
		--beammat:SetVector("$color",redvec)
		--render.DrawBeam(laserpos,endpos,2,0,1,color_white)
		render.SetMaterial(chargemat)
		--glowmat:SetVector("$color",redvec)
		render.DrawSprite(endpos,4,4,lasercol)
		--beammat:SetVector("$color",whitevec)
		
	end

end

scripted_ents.Register(ENT,"scav_stream_bhgcharge",true)
