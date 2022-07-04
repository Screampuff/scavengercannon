local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"

PrecacheParticleSystem("scav_flamethrower")
PrecacheParticleSystem("scav_flamethrower_vm")

function ENT:OnInit()
	self:EmitSound("ambient/fire/ignite.wav")
	self.sound = CreateSound(self,"ambient/fire/fire_med_loop1.wav")
	self.sound:Play()
	if CLIENT then
		self:CreateParticleEffect("scav_flamethrower",{
			{
			["entity"] = self,
			["attachtype"]= PATTACH_ABSORIGIN_FOLLOW,
			},
			{
			["position"] = Vector(self.Weapon:GetForceScale(),0,0)
			}
		})
		self.em = ParticleEmitter(self:GetPos())
	end
end

function ENT:BuildDLight()
	self.dlight = DynamicLight(0)
	local attach = self.Weapon:GetAttachment(self.Weapon:LookupAttachment("muzzle"))
	self.dlight.Pos = attach.Pos+attach.Ang:Forward()*16
	self.dlight.r = 255
	self.dlight.g = 120
	self.dlight.b = 50
	self.dlight.Brightness = .6
	self.dlight.Size = 300
	self.dlight.Decay = 500
	self.dlight.DieTime = CurTime() + 1
end

function ENT:UpdateDLight()
	if self.dlight then
		local attach = self.Weapon:GetAttachment(self.Weapon:LookupAttachment("muzzle"))
		self.dlight.Pos = attach.Pos+attach.Ang:Forward()*16
		self.dlight.Brightness = .6
		self.dlight.Size = 300
		self.dlight.DieTime = CurTime() + 1
	else
		self:BuildDLight()
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

if CLIENT then
	local bubblegrav = Vector(0,0,600)
	ENT.Underwater = false
	
	local function partthink(part)
		local tr	
			part.tracep.start = part.lastpos
			part.tracep.mask = MASK_SHOT
			part.tracep.endpos = part.lastpos+part:GetVelocity()*(CurTime()-part.lastmove)
			tr = util.TraceLine(part.tracep)
			
		part.lastmove = CurTime()
		part.lastpos = part:GetPos()
		local contents = util.PointContents(tr.HitPos)
		if tr.Hit or (bit.band(CONTENTS_WATER, contents) ~= CONTENTS_WATER) then
			part:SetVelocity(vector_origin)
			part:SetDieTime(0)
			return false
		end
		part:SetNextThink(CurTime()+0.1)
	end
	
	function ENT:MakeBubbles()
		local angpos = self:GetMuzzlePosAng()
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		local pos = angpos.Pos
		local forcescale = 1
		if IsValid(self.Weapon) and (self.Weapon:GetClass() == "scav_gun") then
			forcescale = self.Weapon:GetForceScale()
		end
		local aimvec = self.Player:GetAimVector()
		local vel = self.Player:GetVelocity()
		for i=1,6 do
			local part = self.em:Add("effects/bubble",pos)
			if part then
				local velscale = math.Rand(1,2*i)*2*forcescale
				part:SetVelocity(VectorRand()*math.random(0,6)+aimvec*50*velscale+vel)
				part:SetColor(255,255,255)
				part:SetDieTime(2/velscale)
				part:SetStartSize(1)
				part:SetEndSize(3)
				part:SetStartAlpha(100)
				part:SetEndAlpha(0)
				part:SetGravity(bubblegrav)
				part:SetThinkFunction(partthink)
				part.lastpos = part:GetPos()
				part.lastmove = CurTime()
				part.tracep = {}
				part.tracep.mask = bit.bor(CONTENTS_SOLID,CONTENTS_WATER)
				part.tracep.filter = self.Owner
				part:SetNextThink(CurTime()+0.1)
			end
		end
--		self.em:Finish()
	end
end

function ENT:OnThink()
	if CLIENT then
		local angpos = self:GetMuzzlePosAng()
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		self:UpdateDLight()
		if not self.Underwater and (self:WaterLevel() > 0) then
			self:StopParticles()
			self.Underwater = true
		end
		if self.Underwater then
			if (self:WaterLevel() == 0) then
				self:CreateParticleEffect("scav_flamethrower",PATTACH_ABSORIGIN_FOLLOW,{[1]={position=Vector(self.Weapon:GetForceScale(),0,0)}})
				self.Underwater = false
			end
			self:MakeBubbles()
		end
	end
end

function ENT:OnViewMode()
	--local vm = self:GetViewModel()
	--self:GetOwner():StopParticleEmission()
	--vm:CreateParticleEffect("scav_flamethrower_vm",vm:LookupAttachment("muzzle"))
end

function ENT:OnWorldMode()
	--local vm = self:GetViewModel()
	--vm:StopParticleEmission()
	--self:GetOwner():CreateParticleEffect("scav_flamethrower",self:GetOwner():LookupAttachment("muzzle"))
end

scripted_ents.Register(ENT,"scav_stream_fthrow")
