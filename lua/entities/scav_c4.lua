AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:DTVar("Float",0,"ArmTime")
	self:DTVar("Float",1,"DetonateTime")
	self:DTVar("Bool",0,"Armed")
end

function ENT:Arm(seconds)
	self.dt.ArmTime = CurTime()
	self.dt.DetonateTime = self.dt.ArmTime+seconds
	self.dt.Armed = true
	self.NoScav = true
end

function ENT:Disarm()
	self.dt.Armed = false
	self.NoScav = false
end

if SERVER then

	function ENT:Initialize()
	
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:AddGameFlag(bit.bor(FVPHYSICS_NO_IMPACT_DMG,FVPHYSICS_NO_NPC_IMPACT_DMG))
		end
		
		self.Created = CurTime()
		self.nextbeep = self.Created
		
	end
	
	function ENT:Think()
	
		if not self.dt.Armed then return false end

		if self:GetStatusEffect("Frozen") then
			self.dt.DetonateTime = self.dt.DetonateTime + 0.1 --slow down timer if frozen
		end
		
		if self.nextbeep < CurTime() then
			local time = self.dt.DetonateTime - CurTime()
			if time < 30 then
				self:EmitSound("weapons/c4/c4_beep1.wav")
				self.nextbeep = self.nextbeep + math.Clamp(math.pow(time / 10,2),0.1,5)
			end
		end
		
		if self.dt.DetonateTime < CurTime() and not self.Exploded then
		
			self.Exploded = true
			
			net.Start("scv_falloffsound")
				local rf = RecipientFilter()
				rf:AddAllPlayers()
				net.WriteVector(self:GetPos())
				net.WriteString("weapons/c4/c4_explode1.wav")
			net.Send(rf)
			
			ParticleEffect("scav_exp_fireball3",self:GetPos(),Angle(0,0,0),Entity(0))
			util.BlastDamage(self,self.Owner,self:GetPos(),1024,512)
			self:Remove()
			
		end
		
	end
	
else

	screenrefvec = Vector(4.35,-1.9,8.8182)
	
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.Created = CurTime()
	end
	
	local color_red = Color(255,0,0,255)
	local color_green = Color(0,255,0,255)
	
	function ENT:Draw()
		local time = nil
		
		if self.dt.Armed then
			time = self.dt.DetonateTime - CurTime()
			self.lasttimeremaining = nil
		else
		
			if not self.lasttimeremaining then
				self.lasttimeremaining = self.dt.DetonateTime - CurTime()
			end
			
			time = self.lasttimeremaining
			
		end
		
		self:DrawModel()
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(),-90)
		
		cam.Start3D2D(self:LocalToWorld(screenrefvec),ang,0.1)
		
		surface.SetFont("Scav_ConsoleText")
		
		if self.dt.Armed then
			surface.SetTextColor(color_red)
			if (time%3 < 1) then
				surface.SetTextPos(13,0)
				surface.DrawText("#scav.c4.armed")
			end
		else
			surface.SetTextColor(color_green)
			surface.SetTextPos(4,0)
			surface.DrawText("#scav.c4.disarmed")
		end
		
		surface.SetTextPos(4,9)
		
		time = string.FormattedTime(time,"%02i:%02i:%02i")
		surface.DrawText(time)
		cam.End3D2D()
		
	end
	
end