AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.CanScav = true
ENT.angoffset = Angle(0,0,0)

--Just FYI this code is fucking horrid and should never be used as an example for anything ever.

function ENT:Initialize()
	self.trail = util.SpriteTrail(self,0,color_blue,false,7,0,1,0.0625,"trails/laser.vmt")
	self.lastupdate = CurTime()
	self.Created = CurTime()
	self.vel = self.Owner:GetAimVector()*3000
	self.time = CurTime()+0.4
	self.lasttrace = CurTime()
	self.Gravity = Vector(0,0,-96)
	self.didhit = false
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self.filter = {self.Owner}
end

function ENT:PhysicsCollide(physdata, hitent)
	if physdata.Entity != self.Owner then
		self.selfkill = 1
		self:SetMoveType(MOVETYPE_NONE)
	end
end

function ENT:EntityImpactEffects(tr)
	local ef = EffectData()
	ef:SetStart(self.vel:GetNormalized()*-1)
	ef:SetOrigin(tr.HitPos)
	if (tr.MatType == MAT_BLOODYFLESH)||(tr.MatType == MAT_FLESH) then
		util.Effect("BloodImpact",ef)
		sound.Play("physics/flesh/flesh_impact_bullet"..math.random(1,5)..".wav",self:GetPos(),50)
	elseif (tr.MatType == MAT_CONCRETE) then
		util.Decal("impact.concrete",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		sound.Play("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
	elseif (tr.MatType == MAT_PLASTIC) then
		util.Decal("impact.concrete",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		sound.Play("physics/plastic/plastic_box_impact_hard"..math.random(1,4)..".wav",self:GetPos(),50)
	elseif (tr.MatType == MAT_GLASS)||(tr.MatType == MAT_TILE) then
		util.Effect("GlassImpact",ef)
		util.Decal("impact.glass",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		sound.Play("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
	elseif (tr.MatType == MAT_METAL)||(tr.MatType == MAT_GRATE) then
		util.Effect("MetalSpark",ef)
		util.Decal("impact.metal",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		sound.Play("physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
	elseif (tr.MatType == MAT_WOOD) then
		util.Decal("impact.wood",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		sound.Play("physics/wood/wood_solid_impact_bullet"..math.random(1,5)..".wav",self:GetPos(),50)
	elseif (tr.MatType == MAT_DIRT)||(tr.MatType == MAT_SAND) then
		util.Decal("impact.sand",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
		sound.Play("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav",self:GetPos(),50)
	end
end

function ENT:WorldImpactEffects(tr)
	self.didhit = true
	if self:GetModel() == "models/crossbow_bolt.mdl" then
		self:SetPos(tr.HitPos-self.vel:GetNormalized()*8)
	else
		self:SetPos(tr.HitPos)
	end
	//self.Gravity = vector_origin
	//self.vel = vector_origin
	//self:Fire("Kill",1,60)
end

local function MakeRagdoll(ent)
	local rag
	if ent:GetMoveType() == MOVETYPE_VPHYSICS then
		rag = ents.Create("prop_physics")
	else
		rag = ents.Create("prop_ragdoll")
	end
	if ent:GetShouldServerRagdoll() then
		return false
	end
	rag:SetModel(ent:GetModel())
	rag:SetPos(ent:GetPos())
	rag:SetAngles(ent:GetAngles())
	rag:SetColor(ent:GetColor())
	rag:SetMaterial(ent:GetMaterial())
	local bodygroupstring = ""
	for i=0,#ent:GetBodyGroups()-1 do
		bodygroupstring = bodygroupstring .. tonumber(ent:GetBodygroup(i),36) --SetBodyGroups numbers are base 36 (1-z)
	end
	--print(bodygroupstring)
	rag:SetBodyGroups(bodygroupstring)
	rag:SetSkin(ent:GetSkin())
	rag:Spawn()
	rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	rag:Fire("Kill",1,60)
	for i=0,rag:GetPhysicsObjectCount()-1 do --setup bone positions
		local bone = rag:TranslatePhysBoneToBone(i)
		local phys = rag:GetPhysicsObjectNum(i)
		if phys then
			local bpos,bang = ent:GetBonePosition(bone)
			phys:SetPos(bpos)
			phys:SetAngles(bang)
			phys:SetVelocity(ent:GetVelocity())
		end
	end
	
	gamemode.Call("CreateEntityRagdoll",ent,rag) --just a good idea
	if ent:IsPlayer() && ent:GetRagdollEntityOld() then --remove the old ragdoll
		ent:GetRagdollEntityOld():Remove()
	end
	
	
	return rag
end

local tracep = {}

function ENT:Think()
		if !self.didhit then
			self.vel = self.vel+self.Gravity*(CurTime()-self.lasttrace)

			local tr = self:ProcessMovement()
			if tr.Hit || tr.HitSky  then
				if tr.Entity && tr.Entity:IsValid() then
					self:EntityImpactEffects(tr)
				end
				if tr.HitWorld then
					self:WorldImpactEffects(tr)
					self.didhit = true
					local tr = self:ProcessMovement()
					self:SetPos(tr.HitPos)
					if self:GetPhysicsObject():IsValid() then
						self:GetPhysicsObject():SetPos(tr.HitPos)
					end
						
					local oldfilter = self.filter
					self.filter = {self.Owner,tr.Entity}
					tr2 = self:ProcessMovement()
					self.filter = oldfilter
					local arrow = self:CreateArrowProp()
					constraint.Weld(arrow,tr.Entity,0,tr.PhysicsBone,0,true)
					local offset = arrow:GetPhysicsObject():GetPos()-tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone):GetPos()
					arrow:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					if IsValid(self.trail) then
						local target = ents.Create("info_target")
						target:SetPos(self:GetPos())
						self.trail:SetParent(target)
						target:Fire("Kill",nil,2)
					end
					self:Remove()
					return
				end
				if tr.Entity:IsValid() then
					if tr.Entity:IsPlayer() && GetConVar("mp_teamplay"):GetBool() && (tr.Entity:Team() == self.Owner:Team()) then
						table.insert(self.filter,tr.Entity)
						self:NextThink(CurTime()+0.01)
						return true
					end
					local dmg = DamageInfo()
					dmg:SetDamage(50)
					dmg:SetDamageForce(vector_origin)
					dmg:SetAttacker(self.Owner)
					dmg:SetInflictor(self)
					dmg:SetDamagePosition(tr.HitPos)
					tr.Entity.nogib = true
					tr.Entity:TakeDamageInfo(dmg)
					if tr.Entity:Health() > 0 then
						local arrow = self:CreateArrowProp()
						arrow:GetPhysicsObject():Wake()
						arrow:GetPhysicsObject():SetVelocity(self.vel*-0.2)
						arrow:GetPhysicsObject():AddAngleVelocity(Vector(math.Rand(-120,120),math.Rand(-120,120),math.Rand(-120,120)))
						if IsValid(self.trail) then
							local target = ents.Create("info_target")
							target:SetPos(self:GetPos())
							self.trail:SetParent(arrow)
							target:Fire("Kill",nil,2)
						end
						self:Remove()
						return
					end
					if (tr.Entity:IsNPC() || tr.Entity:IsPlayer()) && (tr.Entity:GetMoveType() != MOVETYPE_VPHYSICS) then
						
						
						--Make Ragdoll
						local rag = MakeRagdoll(tr.Entity)
						tr.Entity.ArrowRagdoll = rag

						if tr.Entity:IsPlayer() then
							tr.Entity:KillSilent()
						else
							tr.Entity:Remove()
						end
						self.didhit = true
						tr = self:ProcessMovement()
						self:SetPos(tr.HitPos)
						if self:GetPhysicsObject():IsValid() then
							self:GetPhysicsObject():SetPos(tr.HitPos)
						end
						
						tracep.filter = {self.Owner,tr.Entity}
						tracep.endpos = tracep.start+self.vel:GetNormalized()*200
						tr2 = util.TraceLine(tracep)

						local arrow = self:CreateArrowProp() --create arrow physics prop or w/e
						//arrow:Spawn()
						
						if tr.Entity:IsValid() && arrow:GetPhysicsObject():IsValid() then
							constraint.Weld(arrow,tr.Entity,0,tr.PhysicsBone,0,true)
							local offset = arrow:GetPhysicsObject():GetPos()-tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone):GetPos()
							
							
							if tr2.HitWorld then
								arrow:GetPhysicsObject():SetPos(tr2.HitPos)
								tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone):SetPos(arrow:GetPhysicsObject():GetPos()+offset)
								constraint.Weld(game.GetWorld(),tr.Entity,0,tr.PhysicsBone,0,false)
								tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone):EnableMotion(false)
								arrow:GetPhysicsObject():EnableMotion(false)
							end
						else
							arrow:Remove()
						end
						if IsValid(self.trail) then
							local target = ents.Create("info_target")
							target:SetPos(self:GetPos())
							self.trail:SetParent(target)
							target:Fire("Kill",nil,2)
						end
						self:Remove()

					elseif tr.Hit then --if we hit world or prop
						self.didhit = true
						local tr = self:ProcessMovement()
						self:SetPos(tr.HitPos)
						if self:GetPhysicsObject():IsValid() then
							self:GetPhysicsObject():SetPos(tr.HitPos)
						end
						
						local oldfilter = self.filter
						self.filter = {self.Owner,tr.Entity}
						//tr2 = self:ProcessMovement()
						self.filter = oldfilter
						local arrow = self:CreateArrowProp()
						constraint.Weld(arrow,tr.Entity,0,tr.PhysicsBone,0,true)
						//local offset = arrow:GetPhysicsObject():GetPos()-tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone):GetPos()
						arrow:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
						if IsValid(self.trail) then
							local target = ents.Create("info_target")
							target:SetPos(self:GetPos())
							self.trail:SetParent(target)
							target:Fire("Kill",nil,2)
						end
						self:Remove()
					end
				end
			else
				local vel = self.vel*(CurTime()-self.lasttrace)
				self:SetPos(self:GetPos()+vel)
				self:DoAngles()
			end
			self.lasttrace = CurTime()
		end
		self:NextThink(CurTime()+0.01)
		return true
end

local refang = Angle(0,0,0)
function ENT:DoAngles()
	local ang = self.vel:Angle()
	if self.angoffset == refang then --we don't need an offset, so we can spin without much trouble
		ang.r = ang.r+(CurTime()-self.Created)*720
	else --don't spin otherwise, and use the angle offset
		ang.p = ang.p+self.angoffset.p
		ang.y = ang.y+self.angoffset.y
		ang.r = ang.r+self.angoffset.r
		self:SetAngles(self.vel:Angle()+self.angoffset)
	end
	self:SetAngles(ang)
end

function ENT:ProcessMovement()
	local vel = self.vel*(CurTime()-self.lasttrace)
	tracep.start = self:GetPos()
	tracep.filter = self.filter
	tracep.endpos = self:GetPos()+vel
	tracep.mask = MASK_SHOT
	return util.TraceLine(tracep)
end

function ENT:CreateArrowProp()
	local arrow = ents.Create("prop_physics")
	arrow:SetPos(self:GetPos())
	arrow:SetAngles(self:GetAngles())
	if self:GetModel() == "models/crossbow_bolt.mdl" then
		arrow:SetModel("models/props_debris/rebar001a_32.mdl")
		arrow:SetNoDraw(true)
		arrow:DrawShadow(false)
		local pd = ents.Create("prop_dynamic")
		pd:SetModel("models/crossbow_bolt.mdl")
		pd:SetPos(arrow:GetPos())
		pd:SetAngles(arrow:GetAngles())
		pd:SetParent(arrow)
		pd:SetLocalPos(Vector(-12,0,0))
		pd:Spawn()
	else
		arrow:SetModel(self:GetModel())
	end
	arrow:PhysicsInit(SOLID_VPHYSICS)
	arrow:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	arrow:Fire("Kill",1,60)
	return arrow
end
