local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 2

PrecacheParticleSystem("scav_plasmatorch")

function ENT:OnInit()	
	if CLIENT then
		//self:CreateParticleEffect("scav_plasmatorch",self:GetOwner():LookupAttachment("muzzle"))
		self.points = {}
	else
		//self:EmitSound("ambient/energy/NewSpark09.wav")
		self:EmitSound("ambient/energy/weld2.wav")
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

if CLIENT then
	function ENT:OnThink()
		if self.dt.DeathTime == 0 then
			local angpos = self:GetMuzzlePosAng()
			if angpos.Pos then
				self:SetPos(angpos.Pos)
				self:SetAngles(angpos.Ang)
			end
			self:UpdateDLight()
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

	local beammat = Material("effects/energysplash")
	local beammat2 = Material("effects/bluespark")
	CreateMaterial("scav_plasmablade_trail","UnlitGeneric",{
		["$basetexture"] = "models/debug/debugwhite",
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1
		})
	local trailmat = Material("effects/scav_bladetrail")
	local glowcol = Color(255,255,255,255)
	
	function ENT:Draw2()
		local angpos = self:GetMuzzlePosAng()
		local ang = angpos.Ang
		local pos1 = angpos.Pos-ang:Forward()*5
		local pos2 = pos1+ang:Forward()*70
		local p = self.points	
		if self.dt.DeathTime == 0 then
			render.SetMaterial(beammat2)
			glowcol.a = math.random(10,20)
			local a = beammat2:GetMaterialFloat("$alpha")
			beammat2:SetFloat("$alpha",math.Rand(0.05,0.2))
			render.DrawBeam(pos1,pos2,math.random(14,29),1,0,glowcol)
			beammat2:SetFloat("$alpha",a)
			render.SetMaterial(beammat)
			render.DrawBeam(pos1,pos2,math.random(5,12),0,1,color_white)
		end
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_pblade",true)