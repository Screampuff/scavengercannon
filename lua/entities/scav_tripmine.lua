AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_entity"
ENT.PrintName 		= "Tripmine"
ENT.Author 			= "Ghor"

ENT.Range 			= 7000
ENT.AutomaticArm 	= true
ENT.ArmDelay 		= 3
ENT.Armed 			= false
ENT.LastStartPos 	= Vector()
ENT.LastHitPos 		= Vector()

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"IsArmed")
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
	
		if IsValid(self) and self.Explode and not self.exploded then
		
			self.exploded = true
			
			local edata = EffectData()
			edata:SetOrigin(self:GetPos())
			edata:SetNormal(vector_up)
			util.Effect("ef_scav_exp",edata)
			
			if IsValid(self.Owner) then
				util.BlastDamage(self,self.Owner,self:GetPos(),200,100)
			end
			
			self:Remove()
			
		end
	
		if not self:GetIsArmed() and CurTime() - self.Created > self.ArmDelay and self.AutomaticArm then
			self:SetArmed(true)
		end
		
		if self:GetIsArmed() then
			local tr = self:GetBeamTrace()
			if IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:IsNextBot()) and not tr.Entity:IsFriendlyToPlayer(self.Owner) then
				self:OnBeamCrossedByEnemy(tr)
			end
		end
		
	else
	
		local pos = self:GetPos()
		ScavData.SetRenderBoundsFromPoints(self,pos+self:OBBMins(),pos+self:OBBMaxs(),self.LastHitPos)
		
	end
	
end

if SERVER then
	util.AddNetworkString("scv_mine_arm")
end

function ENT:SetArmed(state)

	if self:GetIsArmed() ~= state then
		if state then
			self:OnArmed()
		else
			self:OnDisarmed()
		end
	end
	
	if SERVER then --we are sending a net message to inform the client of the change in arming, and using a dtvar so clients that learn about the mine later still know its state
		self:SetIsArmed(state)
		net.Start("scv_mine_arm")
			local rf = RecipientFilter()
			rf:AddAllPlayers()
			net.WriteEntity(self)
			net.WriteBool(state)
		net.Send(rf)
	end
	
	self.AutomaticArm = false
	
end

function ENT:IsArmed()
	return self:GetIsArmed()
end

function ENT:OnArmed()
	if SERVER then
		self:EmitSound("weapons/mine_activate.wav")
		self:Fire("SetBodyGroup",1,0)
		self.NoScav = true
	end
end

function ENT:OnDisarmed()
	if SERVER then
		self:EmitSound("weapons/mine_activate.wav",100,52)
		self:Fire("SetBodyGroup",0,0)
		self.NoScav = false
	end
end

local traceinfo = {}
	traceinfo.mask = MASK_SHOT

function ENT:GetBeamTrace()

	local index_att = self:LookupAttachment("beam_attach")
	local vec_start = nil
	local ang_normal = nil
	
	if index_att ~= 0 then
		local posang = self:GetAttachment(index_att)
		vec_start = posang.Pos
		ang_normal = posang.Ang
		ang_normal = (-1 * ang_normal:Right()):Angle()
	else
		vec_start = self:GetPos()
		ang_normal = self:GetAngles():Up():Angle()
	end
	
	traceinfo.start = vec_start
	traceinfo.endpos = vec_start+ang_normal:Forward() * self.Range
	traceinfo.filter = self
	
	local tr = util.TraceLine(traceinfo)
	
	self.LastStartPos = tr.StartPos
	self.LastHitPos = tr.HitPos
	
	return tr
	
end

if CLIENT then

	local mat_beam 		= Material("trails/laser")
	local mat_bloom 	= Material("effects/scav_shine_HR")
	local color_beam 	= Color(255,0,0,50)

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTranslucent()
		self:Draw()
	end

	net.Receive("scv_mine_arm",function()
		local ent = net.ReadEntity()
		local state = net.ReadBool()
		if not IsValid(ent) then return end
		ent:SetArmed(state)
	end)

	hook.Add("PostDrawOpaqueRenderables","scvminedraw",function()
		for _,v in pairs(ents.FindByClass("scav_tripmine")) do
			if v:IsArmed() then
				local tr = v:GetBeamTrace()
				local posang = v:GetAttachment(v:LookupAttachment("beam_attach"))
				render.SetMaterial(mat_beam)
				render.DrawBeam(tr.StartPos,tr.HitPos,8,0,0,color_beam)
				render.SetMaterial(mat_bloom)
				render.DrawSprite(tr.HitPos,2,2,color_beam)
			end
		end
	end)

end

if SERVER then

	function ENT:OnTakeDamage()
		if not self.exploded and not self.damaged then
			timer.Simple(0.2, function() 
				self.Explode = true
			end)
			self.damaged = true
		end
	end

	function ENT:OnBeamCrossedByEnemy(tr)
		if not self.exploded then
			self.Explode = true
		end
	end

end
