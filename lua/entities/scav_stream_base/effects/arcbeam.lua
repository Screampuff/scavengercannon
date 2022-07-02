local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0
ENT.Range = 350
ENT.Cone = 50

function ENT:OnInit()	
	if CLIENT then
		self.em = ParticleEmitter(self:GetPos())
		self.lerpoffset = 0
		self.BeamRes = 20
		self.DisplacementTable = {}
		self.Wave = VectorRand()*12
		self.NextWave = VectorRand()*12
		self.WaveLerp = 0
		self.LastBeamAdvance = CurTime()
		for i=1,self.BeamRes do
			self.DisplacementTable[i] = LerpVector(0.4,self.DisplacementTable[i-1] or VectorRand(),VectorRand()*math.Rand(4,16))
		end
	else
		self:EmitSound("weapons/stunstick/stunstick_impact1.wav",75,100)
		self.sound = CreateSound(self,"ambient/energy/electric_loop.wav")
		self.sound:Play()
		self.LastDamage = 0
	end
end

function ENT:OnSetupDataTables()
	self:NetworkVar("Entity",0,"endent")
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

if SERVER then
	function ENT:SeekTarget(pos,dir)
		local ent = self
		local currentdist = self.Range
		local currentang = self.Cone
		for k,v in pairs(ents.FindInSphere(pos,self.Range)) do
			if v:IsNPC() or (v:IsPlayer() and v ~= self:GetPlayer() and v:Alive()) then
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

	local shocksounds = {
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav",
	}
	
	function ENT:OnThink()
		local tr = self:GetTrace(self.Range)
		local ent = self:Getendent()
		local pos = self:GetShootPos()
		local ang = self:GetAimVector():Angle()
		if IsValid(ent) then
			local entpos = ent:GetPos()+ent:OBBCenter()
			local dist = entpos:Distance(pos)
			local entconeang = math.abs(self:EntAng(ent,pos,ang:Forward()))
			if (dist > self.Range) or (entconeang > self.Cone) or (ent:IsPlayer() and not ent:Alive()) or (ent:IsNPC() and (ent:Health() <= 0)) then
				self:Setendent(NULL)
				ent = NULL
			else
				if self.LastDamage+0.1 < CurTime() then
					local dmg = DamageInfo()
					dmg:SetDamageType(DMG_SHOCK)
					dmg:SetDamagePosition(entpos)
					dmg:SetDamage(6)
					dmg:SetAttacker(self:GetPlayer())
					dmg:SetInflictor(self)
					dmg:SetDamageForce(vector_origin)
					ent:TakeDamageInfo(dmg)
					self.LastDamage = CurTime()
				end
				ent:EmitSound(table.Random(shocksounds))
			end
		end
		if not IsValid(ent) then
			local newent = self:SeekTarget(pos,ang:Forward())
			if newent ~= self then
				self:Setendent(newent)
				self.LastDamage = CurTime()
			elseif IsValid(tr.Entity) then
				if self.LastDamage+0.1 < CurTime() then
					local dmg = DamageInfo()
					dmg:SetDamageType(DMG_SHOCK)
					dmg:SetDamagePosition(tr.HitPos)
					dmg:SetDamage(4)
					dmg:SetAttacker(self:GetPlayer())
					dmg:SetInflictor(self)
					dmg:SetDamageForce(vector_origin)
					tr.Entity:TakeDamageInfo(dmg)
					self.LastDamage = CurTime()
				end
			else
				self.LastDamage = CurTime()
			end
		end
	end
	
end
if CLIENT then
	local beamglowmat1 = Material("sprites/blueglow1")
	local beamglowmat2 = Material("sprites/blueglow2")
	local beammat = Material("sprites/scav_tr_phys")
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		local ang = angpos.Ang
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		self:UpdateDLight()
		self.WaveLerp = self.WaveLerp + FrameTime()*8
		if self.WaveLerp < 1 then
			self.Wave = LerpVector(self.WaveLerp,self.Wave,self.NextWave)
		else
			self.WaveLerp = 0
			self.Wave = self.NextWave
			self.NextWave = VectorRand()*18
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
	
	local lasercol = Color(255,255,255,255)
	local glowcol = Color(255,255,255,40)
	
	function ENT:GetPointOnCurve(lerpvalue,startpos,startguide,endpos,endguide)
		lerpvalue = math.Clamp(lerpvalue,0,1)
		return LerpVector(lerpvalue,LerpVector(lerpvalue,startpos,startpos+startguide),LerpVector(lerpvalue,endpos,endpos+endguide))
	end
	
	function ENT:AdvanceBeam()
		while self.LastBeamAdvance+0.04*10/self.BeamRes < CurTime() do
			table.insert(self.DisplacementTable,1,LerpVector(0.4,self.DisplacementTable[1],VectorRand()*math.Rand(4,16))+self.Wave)
			self.DisplacementTable[self.BeamRes+1] = nil
			self.LastBeamAdvance = self.LastBeamAdvance+0.04*10/self.BeamRes
			self.lerpoffset = 0
		end
	end
	
	function ENT:Draw2()
			local angpos = self:GetMuzzlePosAng()
			local ang = angpos.Ang
			local pos1 = angpos.Pos
			local pos2
			if IsValid(self:Getendent()) then
				pos2 = self:Getendent():GetPos()+self:Getendent():OBBCenter()
			else
				local tr = self:GetTrace(self.Range)
				pos2 = tr.HitPos
			end
			render.SetColorModulation(1,1,1)
			
			render.SetBlend(1)
			render.SetMaterial(beamglowmat2)
			local startpos = pos1

			local startguide = ang:Forward()*math.min(self.Range,pos1:Distance(pos2))
			local endpos = pos2
			local ctime = CurTime()*80
			self:AdvanceBeam()
			local postable = {}
			
			
			do
				local spritepos = self:GetPointOnCurve(0,startpos,startguide,endpos,vector_origin)
				postable[1] = spritepos
				local radius = (1+math.abs(math.sin(ctime-1))*3)*8
				render.DrawSprite(spritepos,radius,radius,lasercol)
			end
			
			for i=1,self.BeamRes-1 do
				local spritepos = self:GetPointOnCurve((i+self.lerpoffset)/self.BeamRes,startpos,startguide,endpos,vector_origin)+self.DisplacementTable[i]*(math.sin(i*math.pi/self.BeamRes))
				postable[i+1] = spritepos
				local radius = (1+math.abs(math.sin(ctime-i))*3)*24
				render.DrawSprite(spritepos,radius,radius,glowcol)
			end
			if dodebug then
				dodebug = false
			end
			render.SetMaterial(beammat)
			render.StartBeam(self.BeamRes)
			local mult = 1
			if IsValid(self:Getendent()) then
				mult = 1+math.abs(math.sin(CurTime()*4))*3
			end
			for i=1,self.BeamRes do
				render.AddBeam(postable[i],math.Rand(1,4)*mult,i-1,lasercol)
			end
			render.EndBeam()

	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_tesla",true)
