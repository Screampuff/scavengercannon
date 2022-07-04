AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
ENT.Damage = 21
ENT.Penetration = -1

local bonetrace = {}
bonetrace.mask = MASK_SHOT
bonetrace.mins = Vector(-1,-1,-1)
bonetrace.maxs = Vector(1,1,1)

local function ragdollweld(self,ragdoll,hitbone,localpos,localang)
    if IsValid(self) and IsValid(ragdoll) then

        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local myphys = self:GetPhysicsObject()
        myphys:EnableGravity(true)
        local phys = ragdoll:GetPhysicsObjectNum(hitbone)
        local ragdollbonepos = phys:GetPos()
        local ragdollboneang = phys:GetAngles()
        local pos,ang = LocalToWorld(localpos,localang,ragdollbonepos,ragdollboneang)
        self:SetPos(pos)
        self:SetAngles(ang)
        self.Welded = true
        self.Weld = constraint.Weld(self,ragdoll,0,hitbone,0,true)
    end
end

local function transfertoragdoll(self,ragdoll)
    self:SetParent()
    self:SetStickEntity(NULL)
    ragdollweld(self,ragdoll,ragdoll:TranslateBoneToPhysBone(self:GetStickBone()),self:GetStickPos(),self:GetStickAngle())
end

hook.Add("CreateEntityRagdoll","ScavTransferShurikens",function(ent,rag)
        for k,v in pairs(ents.FindByClass("scav_projectile_shuriken")) do
            if (v.laststuckentity == ent) then
                transfertoragdoll(v,rag)
            end
        end
    end)

local function safegravity(phys)
	if phys:IsValid() then
		phys:EnableGravity(true)
	end
end

function ENT:PhysicsCollide(data,phys)
	if not self.GravityEnabled then
		timer.Simple(0, function() safegravity(phys) end)
		self.GravityEnabled = true
	end
	if IsValid(self.Trail) then --pretty sure no shits are given about this happening in a physics callback because neither of these entities have physics
		local target = ents.Create("info_target")
		target:SetPos(self:GetPos())
		self.Trail:SetParent(target)
		target:Fire("Kill",nil,2)
		self.Trail = nil
	end
    local class = data.HitEntity:GetClass()
    if not IsValid(self) or self.Stuck then
        return
    end
	local brush = string.find(data.HitEntity:GetModel(),"*",0,true)
	bonetrace.start = data.HitPos
    bonetrace.endpos = bonetrace.start+data.OurOldVelocity:GetNormalized()*4000
    bonetrace.filter = {self,self:GetOwner()}
    local tr = util.TraceLine(bonetrace)
    if data.HitEntity:IsWorld() then
        self:SetStickEntity(data.HitEntity)
        self:SetStickBone(0)
        self:SetStickPos(data.HitPos+data.OurOldVelocity:GetNormalized()*self.Penetration)
        self:SetStickAngle(self:GetAngles())
        self:Fire("Kill",nil,30)
        self.Stuck = true
        timer.Simple(0, function() self:ImpactEffect(tr) end)
        return
    end
    local getbonecenter = false
    if tr.Entity ~= data.HitEntity then
        bonetrace.endpos = data.HitEntity:GetPos()+data.HitEntity:OBBCenter()
        tr = util.TraceLine(bonetrace)
    end
    local ent = tr.Entity
    if (ent == data.HitEntity) then
        if ent:GetClass() == "prop_ragdoll" then
            local hitbox = tr.HitBox
            local bone = ent:GetHitBoxBone(hitbox,0)
            local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone)
            if phys:IsValid() then
                local bonepos = phys:GetPos()
                local boneang = phys:GetAngles()
                if bonepos then
                    local localpos,localang = WorldToLocal(tr.HitPos+tr.Normal*self.Penetration,self:GetAngles(),bonepos,boneang)
                    timer.Simple(0, function() ragdollweld(self,ent,tr.PhysicsBone,localpos,localang) end)
                end
            end
       elseif brush then
            local phys = ent:GetPhysicsObject()
            if phys:IsValid() then
                local bonepos = phys:GetPos()
                local boneang = phys:GetAngles()
                if bonepos then
                    local localpos,localang = WorldToLocal(tr.HitPos+tr.Normal*self.Penetration,self:GetAngles(),bonepos,boneang)
                    timer.Simple(0, function() ragdollweld(self,ent,0,localpos,localang) end)
                end
            end 
        else
            if tr.Entity:IsNPC() and (ent:GetClass() ~= "npc_antlionguard") then
                tr.Entity:SetSchedule(SCHED_BIG_FLINCH)
            end
            local hitbox = tr.HitBox
            local bone = ent:GetHitBoxBone(hitbox,0)
            local bonepos,boneang = ent:GetBonePosition(bone)  
            
            self:SetStickEntity(ent)
            self.laststuckentity = ent

            self:SetStickBone(bone)
            if bonepos then
                local stickpos,stickang = WorldToLocal(tr.HitPos+tr.Normal*self.Penetration,self:GetAngles(),bonepos,boneang)
                self:SetStickPos(stickpos)
                self:SetStickAngle(stickang)
            else
                local stickpos,stickang = WorldToLocal(tr.HitPos+tr.Normal*self.Penetration,self:GetAngles(),ent:GetPos(),ent:GetAngles())
                self:SetStickPos(stickpos)
                self:SetStickAngle(stickang)
            end
            local dmg = DamageInfo()
            dmg:SetDamageType(DMG_SLASH)
            dmg:SetDamagePosition(tr.HitPos)
            if IsValid(self:GetOwner()) then
                dmg:SetAttacker(self:GetOwner())
            else
                dmg:SetAttacker(self)
            end
            dmg:SetInflictor(self)
            dmg:SetDamageForce(data.OurOldVelocity) --not multiplying this by 90,000 anymore. Why was it?
            dmg:SetDamage(self.Damage)
            ent:TakeDamageInfo(dmg)
        end
        self.Stuck = true
        timer.Simple(0, function() self.ImpactEffect(tr) end)
    end
end

--5pm
--18 closed

function ENT:PhysicsUpdate()
    if self.Stuck and (self:GetStickEntity() ~= NULL) then
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
    end
end

function ENT:ImpactEffect(tr)
if not IsValid(self) or dodebug then
    return
end
    local ef = EffectData()
    ef:SetOrigin(tr.HitPos)
    ef:SetNormal(tr.HitNormal)
    local mat = tr.MatType
    local pos = self:GetPos()
    if (mat == MAT_BLOODYFLESH) or (mat == MAT_FLESH) then
        util.Effect("BloodImpact",ef)
        sound.Play("physics/flesh/flesh_impact_bullet"..math.random(1,5)..".wav",pos,50)
    elseif (mat == MAT_CONCRETE) or (mat == MAT_DIRT) then
        --util.Effect("Impact",ef)
        sound.Play("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav",pos,50)
    elseif (mat == MAT_PLASTIC) then
        --util.Effect("Impact",ef)
        sound.Play("physics/plastic/plastic_box_impact_hard"..math.random(1,4)..".wav",pos,50)
    elseif (mat == MAT_GLASS) or (mat == MAT_TILE) then
        util.Effect("GlassImpact",ef)
        sound.Play("physics/concrete/concrete_impact_bullet"..math.random(1,4)..".wav",pos,50)
    elseif (mat == MAT_METAL) or (mat == MAT_GRATE) then
        util.Effect("Sparks",ef)
        sound.Play("physics/metal/metal_solid_impact_bullet"..math.random(1,4)..".wav",pos,50)
    elseif (mat == MAT_WOOD) then
        --util.Effect("Impact",ef)
        sound.Play("physics/wood/wood_solid_impact_bullet"..math.random(1,5)..".wav",pos,50)
    elseif (mat == MAT_SAND) then
        --util.Effect("Impact",ef)
        sound.Play("physics/surfaces/sand_impact_bullet"..math.random(1,4)..".wav",pos,50)
    end
    self:EmitSound("physics/metal/sawblade_stick2.wav")
end
