--[[
    Float like a thruster, sting like a dynamite
]]

AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")

ENT.PrintName = "#scav.scavcan.canister"

function ENT:SetOn(on)
	self:SetNWBool("On", on)
end

function ENT:IsOn()
	return self:GetNWBool("On", false)
end

function ENT:SetOffset(v)
	self:SetNWVector("Offset", v)
end

function ENT:GetOffset()
	return self:GetNWVector("Offset")
end

function ENT:Initialize()

	if (CLIENT) then

		self.ShouldDraw = true

		-- Make the render bounds bigger so the effect doesn't get snipped off
		local mx, mn = self:GetRenderBounds()
		self:SetRenderBounds(mn + Vector(0, 0, 128), mx, 0)

		self.Seed = math.Rand(0, 10000)

	else

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
        self:SetPhysicsAttacker(self.Owner,13)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end

		local max = self:OBBMaxs()
		local min = self:OBBMins()

		self.ThrustOffset = Vector(0, 0, max.z)
		self.ThrustOffsetR = Vector(0, 0, min.z)
		self.ForceAngle = self.ThrustOffset:GetNormalized() * -1

		self:SetForce(60)

		self:SetOffset(self.ThrustOffset)
		self:StartMotionController()

		self:Switch(true)

		self.SoundName = Sound("PhysicsCannister.ThrusterLoop")
        self:StartThrustSound()

        self:SetMaxHealth(25)

	end

    self:SetHealth(25)
    self.SwitchOffTime = CurTime() + 12
    self.Lifetime = CurTime() + 13
    self.Exploded = false

end

if (CLIENT) then

	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:DrawTranslucent(flags)

		BaseClass.DrawTranslucent(self, flags)

	end
end

function ENT:Think()

	BaseClass.Think(self)

	if SERVER and self.SwitchOffTime and self.SwitchOffTime < CurTime() then
		self.SwitchOffTime = nil
		self:Switch(false)
	end

	if SERVER and self.Lifetime < CurTime() then
        self:Explode(self.Owner,200,200)
	end

	if (CLIENT) then

		self.ShouldDraw = true

		if (!self:IsOn()) then self.OnStart = nil return end
		self.OnStart = self.OnStart or CurTime()

		if (self.ShouldDraw == false) then return end

        //Trail effects
		self.SmokeTimer = self.SmokeTimer or 0
		if (self.SmokeTimer > CurTime()) then return end

		self.SmokeTimer = CurTime() + 0.015

		local size = self:OBBMaxs() - self:OBBMins()
		size = math.min(size.x, size.y) / 2

		local vOffset = self:LocalToWorld(self:GetOffset())

		-- Make the offset farther so the normal isn't jumping around crazily on certain models
		local vNormalRand = vOffset + (vOffset - self:GetPos()):GetNormalized() * 32 + VectorRand() * 3
		local vNormal = (vNormalRand - self:GetPos()):GetNormalized()

		local emitter = self:GetEmitter(vOffset, false)
		if (!IsValid(emitter)) then return end

		local particle = emitter:Add("particles/smokey", vOffset + VectorRand() * 3)
		if (!particle) then return end

		local vel_scale = math.Rand(10, 30) * 10 / math.Clamp(self:GetVelocity():Length() / 200, 1, 10)
		local velocity = vNormal * vel_scale

		particle:SetVelocity(velocity)
		particle:SetDieTime(2.0)
		particle:SetGravity(Vector(0, 0, 32))
		particle:SetStartAlpha(math.Rand(50, 150))
		particle:SetStartSize(size)
		particle:SetEndSize(math.Rand(64, 128))
		particle:SetRoll(math.Rand(-0.2, 0.2))
		particle:SetColor(200, 200, 210)

	end

end

if (CLIENT) then
	--[[---------------------------------------------------------
		Use the same emitter, but get a new one every 2 seconds
			This will fix any draw order issues
	-----------------------------------------------------------]]
	function ENT:GetEmitter(Pos, b3D)

		if (self.Emitter) then
			if (self.EmitterIs3D == b3D && self.EmitterTime > CurTime()) then
				return self.Emitter
			end
		end

		if (IsValid(self.Emitter)) then
			self.Emitter:Finish()
		end

		self.Emitter = ParticleEmitter(Pos, b3D)
		self.EmitterIs3D = b3D
		self.EmitterTime = CurTime() + 2
		return self.Emitter

	end
end

function ENT:OnRemove()

	if (IsValid(self.Emitter)) then
		self.Emitter:Finish()
	end

	if (self.Sound) then
		self.Sound:Stop()
	end

end

if (SERVER) then
	function ENT:SetForce(force, mul)

		if (force) then self.force = force end
		mul = mul or 1

		local phys = self:GetPhysicsObject()
		if (!IsValid(phys)) then
			Msg("Warning: [scav_projectile_canister] Physics object isn't valid!\n")
			return
		end

		-- Get the data in worldspace
		local ThrusterWorldPos = phys:LocalToWorld(self.ThrustOffset)
		local ThrusterWorldForce = phys:LocalToWorldVector(self.ThrustOffset * -1)

		-- Calculate the velocity
		ThrusterWorldForce = ThrusterWorldForce * self.force * mul * math.min(self:GetPhysicsObject():GetMass(),50) --don't make light objects go stupidly fast

		local motionEnabled = phys:IsMotionEnabled()
		phys:EnableMotion(true) -- Dirty hack for PhysObj.CalculateVelocityOffset while frozen
		self.ForceLinear, self.ForceAngle = phys:CalculateVelocityOffset(ThrusterWorldForce, ThrusterWorldPos)
		phys:EnableMotion(motionEnabled)

		self.ForceLinear = phys:WorldToLocalVector(self.ForceLinear)

		if (mul > 0) then
			self:SetOffset(self.ThrustOffset)
		else
			self:SetOffset(self.ThrustOffsetR)
		end

		self:SetNWVector(1, self.ForceAngle)
		self:SetNWVector(2, self.ForceLinear)

	end

	function ENT:AddMul(mul, bDown)

        if (!bDown) then return end

        if (self.Multiply == mul) then
            self.Multiply = 0
        else
            self.Multiply = mul
        end

		self:SetForce(nil, self.Multiply)
		self:Switch(self.Multiply != 0)

	end

	function ENT:OnTakeDamage(dmginfo)

        if dmginfo:GetInflictor() == self and dmginfo:IsDamageType(DMG_BLAST) then 
            return false
        end --don't infinite loop when we explode

		self:TakePhysicsDamage(dmginfo)

        self:SetHealth(self:Health() - dmginfo:GetDamage())

        --print(dmginfo:GetDamage(),self:Health())

		if self:Health() <= 0 then
            self:Explode(dmginfo:GetAttacker(),250,200)
        end

        return dmginfo:GetDamage()

	end

	function ENT:Use(activator, caller)

	end

	function ENT:PhysicsSimulate(phys, deltatime)

		if (!self:IsOn()) then return SIM_NOTHING end

		return self.ForceAngle, self.ForceLinear, SIM_LOCAL_ACCELERATION

	end

	-- Switch thruster on or off
	function ENT:Switch(on)

		if (!IsValid(self)) then return false end

		self:SetOn(on)

		if (on) then

			self:StartThrustSound()

		else

			self:StopThrustSound()

		end

		local phys = self:GetPhysicsObject()
		if (IsValid(phys)) then
			phys:Wake()
		end

		return true

	end

	function ENT:SetSound(sound)

		-- No change, don't do shit
		if (self.SoundName == sound) then return end

		-- Gracefully shutdown
		if (self:IsOn()) then
			self:StopThrustSound()
		end

		self.SoundName = Sound(sound)
		self.Sound = nil

		-- Now start the new sound
		if (self:IsOn()) then
			self:StartThrustSound()
		end

	end

	-- Starts the looping sound
	function ENT:StartThrustSound()

		if not self.SoundName or self.SoundName == "" then return end

		if not self.Sound then
			 -- Make sure the fadeout gets to every player!
			local filter = RecipientFilter()
			filter:AddPAS(self:GetPos())
			self.Sound = CreateSound(self.Entity, self.SoundName, filter)
		end

		self.Sound:PlayEx(0.5, 100)

	end

	-- Stop the looping sound
	function ENT:StopThrustSound()

		if (self.Sound) then
			self.Sound:ChangeVolume(0.0, 0.25)
		end

	end

end

function ENT:PhysicsCollide(data,phys)
    local other = phys:GetEntity()
    if other:IsWorld() then
        if data.Speed > 300 then
            self:TakeDamage(math.floor(data.Speed*.001),self.Owner,other)
        end
    else
        if data.Speed > 100 then
            self:TakeDamage(math.floor(data.Speed*.005),self.Owner,other)
        end
    end
end

function ENT:Explode(ply, radius, damage)

	if not IsValid(self) then return end

    if self.Exploded then return end

	if not IsValid(ply) then
        ply = self.Owner
    end
    local chunks = {"a","b","c","d","f","g","h","i","k","l","m"}
    for i=1,#chunks,1 do
        local proj = ents.Create("prop_physics")
        proj:SetModel("models/props_c17/canisterchunk01"..chunks[i]..".mdl")
        proj:SetPos(self:GetPos())
        proj:SetAngles(self:GetAngles())
        proj:SetPhysicsAttacker(self.Owner)
        proj:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        proj:Spawn()
        if IsValid(proj) then
            proj:SetOwner(self.Owner)
            proj.CanScav = false
            proj:Fire("kill",1,"6")
        end
    end

    util.BlastDamage(self, ply, self:GetPos(), radius, damage * math.max(5,self:Health()) / self:GetMaxHealth())

    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("Explosion", effectdata, true, true)

    self.Exploded = true

    self:Remove()
    return

end