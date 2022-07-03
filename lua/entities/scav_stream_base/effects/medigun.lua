local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0
ENT.Range = 350
ENT.Cone = 50
ENT.PosOffset = Vector(12,0,0)

function ENT:OnInit()
	if CLIENT then
		if self:Getblue() then
			self.ParticleName = "medicgun_beam_blue"
		else
			self.ParticleName = "medicgun_beam_red"
		end
	else
		self.LastHeal = CurTime()
		self.LastBeep = self.LastHeal
	end
end

function ENT:OnSetupDataTables()
	self:NetworkVar("Entity",0,"endent")
	self:NetworkVar("Bool",0,"blue")
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

if SERVER then
	PrecacheParticleSystem("medicgun_beam_red")
	PrecacheParticleSystem("medicgun_beam_blue")

	function ENT:BeginSound()
		if not self.sound then
			self.sound = CreateSound(self,"weapons/medigun_heal.wav")
		end
		self.sound:Play()
	end
	
	function ENT:EndSound()
		if self.sound then
			self.sound:Stop()
		end
	end
	
	function ENT:SeekTarget(pos,dir)
		local ent = self
		local currentdist = self.Range
		local currentang = self.Cone
		for k,v in pairs(ents.FindInSphere(pos,self.Range)) do
			if v:IsNPC() or (v:IsPlayer() and v ~= self:GetPlayer() and v:Alive()) or (_ZetasInstalled and v:GetClass() == "npc_zetaplayer") then
				local entpos = v:GetPos()+v:OBBCenter()
				local dist = entpos:Distance(pos)
				if (dist < currentdist) then
					local ang = math.abs(self:EntAng(v,pos,dir))
					if (ang <= self.Cone) and (ang <= currentang) then
						currentang = ang
						currentdist = dist
						ent = v
					end
				end
			end
		end
		return ent
	end
	
	function ENT:EntAng(ent,pos,dir)
		local entpos = ent:GetPos()+ent:OBBCenter()
		local entang = ent:GetAngles()
		local localpos,localang = WorldToLocal(entpos,entang,pos,dir:Angle())
		local linedist = math.sqrt(localpos.z^2+localpos.y^2)
		local ang = math.deg(math.atan2(localpos.x,linedist))-90
		return ang
	end
	
	function ENT:OnThink()
		local ctime = CurTime()
		local tr = self:GetTrace(self.Range)
		local ent = self:Getendent()
		local pos = self:GetShootPos()
		local ang = self:GetAimVector():Angle()
		if IsValid(ent) then
			local entpos = ent:GetPos()+ent:OBBCenter()
			local dist = entpos:Distance(pos)
			if (dist > self.Range) or (ent:IsPlayer() and not ent:Alive()) or ((ent:IsNPC() or (_ZetasInstalled and ent:GetClass() == "npc_zetaplayer")) and (ent:Health() <= 0)) then
				self:Setendent(NULL)
				ent = NULL
			else
				if self.LastHeal+0.1 < ctime then
					local dmg = DamageInfo()
					ent:SetHealth(math.min(ent:Health()+22.5*(ctime-self.LastHeal),ent:GetMaxHealth()))
					self.LastHeal = CurTime()
				end
			end
		end
		if not IsValid(ent) then
			self:EndSound()
			local newent = self:SeekTarget(pos,ang:Forward())
			if IsValid(newent) and (newent ~= self) then
				self:BeginSound()
				self:Setendent(newent)
			else
				if self.LastBeep+0.5 < ctime then
					self:EmitSound("weapons/medigun_no_target.wav")
					self.LastBeep = ctime
				end
			end
				
			self.LastHeal = ctime
		end
	end
	
end

if CLIENT then
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		local ang = angpos.Ang
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		if IsValid(self:Getendent()) then
			if not IsValid(self.CPoint1Ent) or (self.CPoint1Ent:GetParent() ~= self:Getendent()) then
				self:StartBeam(self:Getendent())
			end
		else
			self:StopBeam()
		end
		if IsValid(self.CPoint1Ent) and IsValid(self.CPoint1Ent:GetParent()) then
			local cpoint = self.CPoint1Ent
			if cpoint.Attachment then
				cpoint:SetPos(cpoint:GetParent():GetAttachment(cpoint.Attachment).Pos)
			end
		end
	end
	
	function ENT:Draw2()
	end
	
	function ENT:StartBeam(ent)
		self:StopBeam()
		local cmodel = ClientsideModel("models/props_junk/popcan01a.mdl")
			cmodel:AddEffects(bit.bor(EF_NODRAW,EF_NOSHADOW))
			cmodel:SetPos(ent:GetPos()+ent:OBBCenter())
			cmodel:SetParent(ent)
			local att = ent:LookupAttachment("chest")
			if att and (att ~= 0) then
				cmodel.Attachment = att
			end
			self.CPoint1Ent = cmodel
		local cpoint0 = {}
			cpoint0.entity = self
			cpoint0.attachtype = PATTACH_ABSORIGIN_FOLLOW
		local cpoint1 = {}
			cpoint1.entity = cmodel
			cpoint1.attachtype = PATTACH_ABSORIGIN_FOLLOW
			print(self, ent, cmodel);
		self:CreateParticleEffect(self.ParticleName,{cpoint0,cpoint1})
	end
	
	function ENT:StopBeam()
		self:StopParticleEmission()
		if IsValid(self.CPoint1Ent) then
			self.CPoint1Ent:Remove()
		end
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_medigun",true)
