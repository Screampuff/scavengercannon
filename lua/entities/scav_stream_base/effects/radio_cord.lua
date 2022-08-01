local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0
ENT.Range = 1000
ENT.Cone = 50

PrecacheParticleSystem("scav_remotecable")

function ENT:OnInit()
	if CLIENT then
		self.ParticleName = "scav_remotecable"
	end
end

function ENT:OnSetupDataTables()
	self:NetworkVar("Entity",0,"endent")
end

function ENT:OnKill()
end

if SERVER then
	
	function ENT:OnThink()
		local ctime = CurTime()
		local tr = self:GetTrace(self.Range)
		local ent = self:Getendent()
		local pos = self:GetShootPos()
		local ang = self:GetAimVector():Angle()
		if IsValid(ent) then
			local entpos = ent:GetPos()+ent:OBBCenter()
			local dist = entpos:Distance(pos)
			if (dist > self.Range) or (ent:IsPlayer() and not ent:Alive()) or ((ent:IsNPC() or ent:IsNextBot()) and (ent.Health and ent:Health() <= 0)) then
				self:Setendent(NULL)
				ent = NULL
			end
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
		self:CreateParticleEffect(self.ParticleName,{cpoint0,cpoint0,cpoint1})
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

scripted_ents.Register(ENT,"scav_stream_cord",true)