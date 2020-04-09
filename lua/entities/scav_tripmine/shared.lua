ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "scav_tripmine"
ENT.Author = "Ghor"
ENT.Contact = "none"
ENT.Purpose = "none"
ENT.Instructions = ""
ENT.Range = 7000
ENT.AutomaticArm = true
ENT.ArmDelay = 3
ENT.Armed = false
ENT.LastStartPos = Vector()
ENT.LastHitPos = Vector()

function ENT:SetupDataTables()
	self:DTVar("Bool",0,"Armed")
end

function ENT:Initialize()
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end
	self.Created = CurTime()
end

function ENT:Think()
	if SERVER then
		if !self.dt.Armed && (CurTime()-self.Created > self.ArmDelay) && self.AutomaticArm then
			self:SetArmed(true)
		end
		if self.dt.Armed then
			local tr = self:GetBeamTrace()
			if (tr.Entity:IsNPC() || tr.Entity:IsPlayer()) && !tr.Entity:IsFriendlyToPlayer(self.Owner) then
				self:OnBeamCrossedByEnemy(tr)
			end
		end
	else
		local pos = self:GetPos()
		ScavData.SetRenderBoundsFromPoints(self,pos+self:OBBMins(),pos+self:OBBMaxs(),self.LastHitPos)
	end
end

function ENT:SetArmed(state)
	if self.dt.Armed != state then
		if state then
			self:OnArmed()
		else
			self:OnDisarmed()
		end
	end
	if SERVER then --we are sending a usermessage to inform the client of the change in arming, and using a dtvar so clients that learn about the mine later still know its state
		self.dt.Armed = state
		umsg.Start("scv_mine_arm")
			umsg.Entity(self)
			umsg.Bool(state)
		umsg.End()
	end
	self.AutomaticArm = false
end

function ENT:IsArmed()
	return self.dt.Armed
end

function ENT:OnArmed()
	if CLIENT then
		self:EmitSound("weapons/mine_activate.wav")
	else
		self:Fire("SetBodyGroup",1,0)
		self.NoScav = true
	end
end

function ENT:OnDisarmed()
	if CLIENT then
		self:EmitSound("weapons/mine_activate.wav",100,52)
	else
		self:Fire("SetBodyGroup",0,0)
		self.NoScav = false
	end
end

local traceinfo = {}
	traceinfo.mask = MASK_SHOT

function ENT:GetBeamTrace()
	local index_att = self:LookupAttachment("beam_attach")
	local vec_start
	local ang_normal
	if (index_att != 0) then
		local posang = self:GetAttachment(index_att)
		vec_start = posang.Pos
		ang_normal = posang.Ang
		//ang_normal.y = ang_normal.y+90
		ang_normal = (-1*ang_normal:Right()):Angle()
	else
		vec_start = self:GetPos()
		ang_normal = self:GetAngles():Up():Angle()
	end
	traceinfo.start = vec_start
	traceinfo.endpos = vec_start+ang_normal:Forward()*self.Range
	traceinfo.filter = self
	local tr = util.TraceLine(traceinfo)
	self.LastStartPos = tr.StartPos
	self.LastHitPos = tr.HitPos
	return tr
end
