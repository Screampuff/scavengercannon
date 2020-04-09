AddCSLuaFile()

ENT.Type 		= "anim"
ENT.Base 		= "base_entity"
ENT.PrintName 	= "Hopper Mine"
ENT.Author 		= "Ghor"

function ENT:SetupDataTables()
	self:DTVar("Int",0,"state")
end

function ENT:Initialize()

	self:SetPoseParameter("blendstates",65)
	self.Created = CurTime()
	
	if SERVER then
	
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		
		self.sound1 = CreateSound(self,"npc/roller/mine/combine_mine_active_loop1.wav")
		self.sound1:ChangePitch(255)
		self.expl = false
		
		if IsValid(self.Owner) then
			self.Owner:AddScavExplosive(self)
		end
		
	end
	
	if CLIENT then
		self.ready = false
	end
	
end

function ENT:Think()

	if self.Explode and not self.exploded and IsValid(self.Owner) then
	
		self.exploded = true
		
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		fx:SetRadius(100)
		util.Effect("Explosion",fx)
		
		if IsValid(self.Owner) then
			util.BlastDamage(self,self.Owner,self:GetPos(),200,128)
		end
		
		self:Remove()
		
	end
	
	if self.nothink then return end
	
	if SERVER then
	
		if not IsValid(self.constraint) and self.constrained then
			self:Disarm()
		elseif IsValid(self.constraint) and not self.constrained then
			self:Arm()
		end
		
		local prox = nil
		
		if IsValid(self.constraint) then
		
			local tab = ents.FindInSphere(self:GetPos(), 300)
			
			for i=1,table.getn(tab),1 do
			
				if (tab[i]:IsPlayer() or tab[i]:IsNPC()) then
				
					if tab[i]:GetPos():Distance(self:GetPos()) < 150 and not tab[i]:IsFriendlyToPlayer(self.Owner) then
					
						self.constraint:Remove()
						
						timer.Simple(0, function()
							local phys = self:GetPhysicsObject()
							if IsValid(phys) then
								phys:Wake()
								phys:SetVelocity(VectorRand() * 300 + Vector(0,0,1000))
								phys:AddAngleVelocity(VectorRand() * 400)
								phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
							end
						end)

						self:EmitSound("npc/roller/mine/rmine_blip3.wav")	
						self:Disarm()
						self.dt.state = 0
						self.nothink = true
						
						break
						
					else
					
						if prox and not prox:IsFriendlyToPlayer(self.Owner) then
							prox = tab[i]
						elseif not prox then
							prox = tab[i]
						end
						
					end
					
				end
				
			end
			
			if prox then
				if prox:IsFriendlyToPlayer(self.Owner) then
					self.dt.state = 1
				else
					self.sound1:Play()
					self.dt.state = 2
				end
			else
				self.sound1:Stop()
				self.dt.state = 0
			end
			
		elseif self:IsHeld() then
			self:SetPoseParameter("blendstates", math.sin(CurTime() * 7) * 32 + 32)
		end
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) and phys:GetVelocity() == vector_origin and not IsValid(self.constraint) then
		
			local tracep = {}
			tracep.start = self:GetPos() + self:OBBCenter()
			tracep.filter = self
			tracep.endpos = tracep.start - self:GetAngles():Up() * 10
			tracep.mask = MASK_SHOT
			tr = util.TraceLine(tracep)

			if tr.HitWorld and tr.HitNormal.z > 0.5 and self:GetAngles():Up().z > 0.5 then
				self:Constrain(tr.Entity)
			elseif self.hascollided then
				phys:SetVelocity(VectorRand() * 100 + Vector(0,0,700))
				phys:AddAngleVelocity(VectorRand() * 600)
				self:EmitSound("npc/roller/mine/rmine_blip3.wav")
				self.hascollided = false
			end
		end
		if CurTime() > self.Created + 3 and not self.ready then
			self.ready = true
		end
		
		
	end

	if CLIENT then
		self.inrange = false
		local tab = ents.FindInSphere(self:GetPos(), 250)
		for i=1,table.getn(tab),1 do
			if tab[i]:IsPlayer() or tab[i]:IsNPC() then
				self.inrange = true
			end
		end
	end	

	self:NextThink(CurTime() + 0.1)
	return true
	
end

if CLIENT then

	ENT.mat = Material("effects/softglow")

	local color_blue = Color(0,0,255,255)
	local color_green = Color(0,255,0,255)
	local color_red = Color(255,0,0,255)

	function ENT:Draw()
		render.SetMaterial(self.mat)
		local pos = self:GetBonePosition(self:LookupBone("body"))
		if self.dt.state == 1 then -- ally
			render.DrawSprite(pos,24,24,color_green)
		elseif self.dt.state == 2 then -- enemy
			render.DrawSprite(pos,24,24,color_red)
		elseif self.dt.state == 3 then -- disarmed
			render.DrawSprite(pos,24,24,color_blue)
		end
		self:DrawModel()
	end
	
end

if SERVER then

	ENT.constraint 		= NULL
	ENT.wasconstrained 	= false

	function ENT:Arm()
		self:SetPoseParameter("blendstates",0)
		self:EmitSound("npc/roller/blade_cut.wav")
		self:EmitSound("npc/roller/mine/combine_mine_deploy1.wav")
		self.constrained = true
		self.dt.state = 0
	end

	function ENT:Disarm()
	
		if IsValid(self.constraint) then
			self.constraint:Remove()
		end
		
		self:SetPoseParameter("blendstates",65)
		self:EmitSound("npc/roller/blade_in.wav")
		self.constrained = false
		self.dt.state = 3
		
	end

	function ENT:OnGravGunPickup(pl)
	
		self.Owner = pl
		self.nothink = false
		
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) then
			phys:ClearGameFlag(FVPHYSICS_WAS_THROWN)
		end
		
		self.held = true
		
		if IsValid(self.constraint) then
			self.constraint:Remove()
		end
		
	end

	function ENT:IsHeld()
		return self.held
	end

	function ENT:OnGravGunDropped(pl)
	
		local phys = self:GetPhysicsObject()
		
		if IsValid(phys) and pl:KeyDown(IN_ATTACK) then
			phys:SetDragCoefficient(-2500)
			phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
		end
		
		self:SetPoseParameter("blendstates",65)
		self.held = false
	end


	function ENT:PhysicsCollide(data,physobj)
		if IsValid(physobj) and physobj:HasGameFlag(FVPHYSICS_WAS_THROWN) and not self.exploded then
			timer.Simple(0, function() 
				self:NextThink(CurTime()) 
				self.Explode = true 
			end)
		end
		self.hascollided = true
	end

	function ENT:Constrain(hitent)
		self.constraint = constraint.Weld(self,hitent,0,0,7000,false)
	end

	function ENT:OnRemove()
		if self.sound1 then
			self.sound1:Stop()
		end
	end

end