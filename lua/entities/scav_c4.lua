AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.screen = false

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"ArmTime")
	self:NetworkVar("Float",1,"DetonateTime")
	self:NetworkVar("Bool",0,"Armed")
end

function ENT:Arm(seconds)
	self:SetArmTime(CurTime())
	self:SetDetonateTime(self:GetArmTime()+seconds)
	self:SetArmed(true)
	self.NoScav = true
end

function ENT:Disarm()
	self:SetArmed(false)
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
	
		if not self:GetArmed() then return false end

		if self:GetStatusEffect("Frozen") then
			self:SetDetonateTime(self:GetDetonateTime() + 0.1) --slow down timer if frozen
		end
		
		if self.nextbeep < CurTime() then
			local time = self:GetDetonateTime() - CurTime()
			if time < 30 then
				if IsMounted(240) then --CSS
					self:EmitSound("weapons/c4/c4_beep1.wav")
				else
					self:EmitSound("hl1/fvox/beep.wav")
				end
				self.nextbeep = self.nextbeep + math.Clamp(math.pow(time / 10,2),0.1,5)
			end
		end
		
		if self:GetDetonateTime() < CurTime() and not self.Exploded then
		
			self.Exploded = true
			
			net.Start("scv_falloffsound")
				local rf = RecipientFilter()
				rf:AddAllPlayers()
				net.WriteVector(self:GetPos())
				if IsMounted(240) then --CSS
					net.WriteString("weapons/c4/c4_explode1.wav")
				else
					net.WriteString("npc/env_headcrabcanister/explosion.wav")
				end
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
		
		if self:GetModel() == "models/weapons/w_c4_planted.mdl" then
			self.screen = true
		end
	end
	
	local color_red = Color(255,0,0,255)
	local color_green = Color(0,255,0,255)
	
	function ENT:Draw()
		
		self:DrawModel()
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(),-90)
		
		if self.screen then
			local time = nil
			
			if self:GetArmed() then
				time = self:GetDetonateTime() - CurTime()
				self.lasttimeremaining = nil
			else
				if not self.lasttimeremaining then
					self.lasttimeremaining = self:GetDetonateTime() - CurTime()
				end
				
				time = self.lasttimeremaining
				
			end

			cam.Start3D2D(self:LocalToWorld(screenrefvec),ang,0.1)
			
			surface.SetFont("Scav_ConsoleText")
			
			if self:GetArmed() then
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
	
end
