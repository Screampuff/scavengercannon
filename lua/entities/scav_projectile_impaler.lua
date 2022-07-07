AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Scav Impaler Projectile"
ENT.Author = "Anya O'Quinn"

local ClassName = "scav_projectile_impaler"

function ENT:SetupDataTables()
	self:NetworkVar("Float", 	0, "Length")
	self:NetworkVar("Bool", 	0, "Hit")
	self:NetworkVar("Entity",	0, "AHitEnt")
	self:NetworkVar("Int", 		0, "AHitBone")
	self:NetworkVar("Vector", 	0, "AHitPos")
	self:NetworkVar("Angle", 	0, "AHitAng")
end

if CLIENT then

	function ENT:Draw()

		if not self.CurAPos or not self.CurAAng then
			self.CurAPos = self:GetAHitPos() or self:GetPos()
			self.CurAAng = self:GetAHitAng() or self:GetAngles()
		end

		self:DrawModel()
		self:SetRenderBoundsWS(self:GetPos() + self:OBBMins() * 100, self:GetPos() + self:OBBMaxs() * 100)

		local hitent = self:GetAHitEnt()
		local hitpos = self:GetAHitPos()
		local hitang = self:GetAHitAng()
		local hitbone = self:GetAHitBone()

		if IsValid(hitent) and hitpos and hitang and hitbone and self.CurAPos ~= hitpos and self.CurAAng ~= hitang then

			local bonepos,boneang = hitent:GetBonePosition(hitbone)

			if bonepos and boneang then
				local pos,ang = LocalToWorld(hitpos,hitang,bonepos,boneang)
				self.CurAPos = pos
				self.CurAAng = ang
				self:SetPos(pos)
				self:SetAngles(ang)
			end

		elseif hitpos and hitang and self.CurAPos ~= self:GetAHitPos() and self.CurAAng ~= self:GetAHitAng() then
			self.CurAPos = hitpos
			self.CurAAng = hitang
			self:SetPos(hitpos)
			self:SetAngles(hitang)
		end

	end

end

if SERVER then

	function ENT:Initialize()

        if not self:GetModel() then
            self:SetModel("models/crossbow_bolt.mdl")
		end

		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:DrawShadow(false)

		if not IsValid(self.Owner) then return end

		self.LastTrace = CurTime()

		if not self.Trail then
            self.Trail = util.SpriteTrail(self,0,color_blue,false,7,0,1,0.0625,"trails/laser.vmt")
        end

        if not self.DmgAmt then
            self.DmgAmt = 50
        end

        if not self.Drop then
            self.Drop = Vector(0,0,-200)
        end

        if not self.Vel then
            self.Vel = self.Owner:GetAimVector() * 3000
		end

		self:SetLength(math.floor(math.max(self:OBBMaxs().x - self:OBBMins().x,self:OBBMaxs().y - self:OBBMins().y,self:OBBMaxs().z - self:OBBMins().z)))

	end

	local b_trace 	= {}
	local b_tr 		= {}

	function ENT:Think()

		if not self:GetHit() then

            self.Vel = self.Vel + self.Drop * (CurTime() - self.LastTrace)

			local vel = self.Vel * (CurTime() - self.LastTrace)

			b_trace.start = self:GetPos()
			b_trace.endpos = self:GetPos() + vel
			b_trace.filter = {self, self.Owner}
			b_trace.mask = MASK_SHOT_HULL
			b_trace.mins = self:OBBMins() / 8
			b_trace.maxs = self:OBBMaxs() / 8
			b_tr = util.TraceHull(b_trace)

			local ang = self.Vel:Angle() + (self.angoffset or angle_zero)

			self:SetPos(self:GetPos() + vel)
			self:SetAngles(ang)

		end

		local hit = b_tr.Hit
		local hitsky = b_tr.HitSky
		local hitpos = b_tr.HitPos
		local hitnormal = b_tr.HitNormal
		local hitbox = b_tr.HitBox
		local ent = b_tr.Entity

		if IsValid(self) and not self:GetHit() and hit then

			self:SetPos(hitpos)

			if self:GetModel() == "models/crossbow_bolt.mdl" then
				self:SetPos(self:GetPos() - self:GetForward():GetNormalized() * 10)
			elseif self:GetModel() == "models/props_junk/harpoon002a.mdl" then
				self:SetPos(self:GetPos() - self:GetForward():GetNormalized() * 30)
			elseif self:GetModel() == "models/weapons/c_models/c_scimitar/c_scimitar.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_scimitar/c_scimitar.mdl"
				or self:GetModel() == "models/weapons/c_models/c_machete/c_machete.mdl"
				or self:GetModel() == "models/weapons/c_models/c_croc_knife/c_croc_knife.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl"
				or self:GetModel() == "models/weapons/c_models/c_wood_machete/c_wood_machete.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_wood_machete/c_wood_machete.mdl"
			then
				self:SetPos(self:GetPos() - self:GetForward():GetNormalized() * 15)
				self.ImpactDamageType = DMG_SLASH
			elseif self:GetModel() == "models/weapons/w_knife_ct.mdl" then
				self:SetPos(self:GetPos() - self:GetUp():GetNormalized() * 5 - self:GetForward():GetNormalized() * 8)
				self.ImpactDamageType = DMG_SLASH
			elseif self:GetModel() == "models/weapons/w_knife_t.mdl"
				or self:GetModel() == "models/weapons/w_models/w_knife.mdl"
				or self:GetModel() == "models/workshop_partner/weapons/c_models/c_prinny_knife/c_prinny_knife.mdl"
				or self:GetModel() == "models/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl"
				or self:GetModel() == "models/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl"
				or self:GetModel() == "models/weapons/c_models/c_ava_roseknife/c_ava_roseknife_v.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_ava_roseknife/c_ava_roseknife.mdl"
				or self:GetModel() == "models/weapons/c_models/c_switchblade/c_switchblade.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_switchblade/c_switchblade.mdl"
				or self:GetModel() == "models/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl"
				or self:GetModel() == "models/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl"
				or self:GetModel() == "models/workshop_partner/weapons/c_models/c_sd_cleaver/c_sd_cleaver.mdl"
				or self:GetModel() == "models/workshop_partner/weapons/c_models/c_sd_cleaver/v_sd_cleaver.mdl"
				or self:GetModel() == "models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl"
				or self:GetModel() == "models/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl"
				or self:GetModel() == "models/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl"
			then
				self:SetPos(self:GetPos() - self:GetUp():GetNormalized() * 8)
				self.ImpactDamageType = DMG_SLASH
			elseif self:GetModel() == "models/weapons/c_models/c_claymore/c_claymore.mdl"
				or self:GetModel() == "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl"
				or self:GetModel() == "models/weapons/c_models/c_scout_sword/c_scout_sword.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl"
				or self:GetModel() == "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl"
				or self:GetModel() == "models/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl"
				or self:GetModel() == "models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl"
				or self:GetModel() == "models/workshop_partner/weapons/c_models/c_shogun_katana/c_shogun_katana_soldier.mdl"
				or self:GetModel() == "models/workshop/weapons/c_models/c_demo_sultan_sword/c_demo_sultan_sword.mdl"
				or self:GetModel() == "models/weapons/melee/w_machete.mdl"
				or self:GetModel() == "models/weapons/melee/w_katana.mdl"
			then
				self:SetPos(self:GetPos() - self:GetUp():GetNormalized() * 20)
				self.ImpactDamageType = DMG_SLASH
			elseif self:GetModel() == "models/weapons/melee/w_pitchfork.mdl"
			then
				self:SetPos(self:GetPos() - self:GetUp():GetNormalized() * 30)
				self.ImpactDamageType = DMG_SLASH
			elseif self:GetModel() == "models/lostcoast/fisherman/harpoon.mdl"
			then
				self:SetPos(self:GetPos() - self:GetUp():GetNormalized() * 20)
			end

            if IsValid(self.Trail) then
                self.Trail:Fire("Kill",1,1)
            end

			if hitsky or not self:IsInWorld() or not ent then
				self:SetNoDraw(true)
				self:Remove()
			end

			if IsValid(ent) and ent:GetClass() == "func_breakable_surf" then
				ent:Fire("Shatter")
				self:SetNoDraw(true)
				self:Remove()
			end

			if (not ent:IsPlayer() and not ent:IsNPC() and not ent:IsNextBot() and not ent:GetClass() ~= "prop_ragdoll") and ent:GetClass() ~= self:GetClass() then

				self:SetAHitEnt(nil)
				self:SetAHitPos(self:GetPos())
				self:SetAHitAng(self:GetAngles())

				if not ent:IsWorld() then
					self:SetParent(ent)
				end

			else

				local bone = ent:GetHitBoxBone(hitbox,0)
				local bonepos = nil
				local boneang = nil

				if bone then
					bonepos,boneang = ent:GetBonePosition(bone)
				end

				if bonepos and boneang and self:GetMoveType() == MOVETYPE_NONE and not self.Stuck and self.DmgAmt < ent:Health() then

					self.Stuck = true

					local localhpos,localhang = WorldToLocal(hitpos,self:GetAngles(),bonepos,boneang)

					self:SetAHitEnt(ent)
					self:SetAHitBone(bone)
					self:SetAHitPos(localhpos)
					self:SetAHitAng(localhang)
					self:SetParent(ent)

				end

			end

			local dmg = DamageInfo()

			if IsValid(self.Owner) then
				dmg:SetAttacker(self.Owner)
			else
				dmg:SetAttacker(self)
			end

			if IsValid(self.Inflictor) then
				dmg:SetInflictor(self.Inflictor)
				else
				dmg:SetInflictor(self)
			end

			dmg:SetDamagePosition(hitpos)
			dmg:SetDamageForce(self.Vel * 10)
            dmg:SetDamageType(DMG_SLASH)
            dmg:SetDamage(self.DmgAmt)

            efdata = EffectData()
			efdata:SetOrigin(hitpos)
            efdata:SetEntity(self)
            efdata:SetNormal(hitnormal)
            efdata:SetDamageType(self.ImpactDamageType or DMG_BULLET)
            util.Effect("ef_scav_impalerimpact", efdata)

            if (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) and ent.Health and (ent:Health() > 0 or ent:GetMaxHealth() == 0) then --ew

				sound.Play("ambient/machines/slicer"..math.random(2,3)..".wav", hitpos, 90, 100)

                local tracew = {}
                tracew.start = hitpos
                tracew.endpos = hitpos + (self.Vel * (self:GetLength()/500 or 0.1))
                tracew.mask = MASK_SHOT_HULL

                tracew.filter = function(tr_ent)
                    if tr_ent ~= ent then
                        return true
                    end
                end

                local trw = util.TraceLine(tracew)

                if self.DmgAmt >= ent:Health() and trw.Hit and not self.NoPin then

                    local pos = hitpos
                    local offpos = pos - (hitpos - trw.HitPos)

                    if ent:IsPlayer() then
                        ent:TakeDamageInfo(dmg)
                    end

                    self.Pinned = true
                    local rag = ent

                    if IsValid(ent) and offpos and (not ent:IsPlayer() or (ent:IsPlayer() and not ent:Alive())) and not self.PerformPin then

                        self.PerformPin = true

                        if ent:GetMoveType() == MOVETYPE_VPHYSICS then
                            rag = ents.Create("prop_physics")
                        else
                            rag = ents.Create("prop_ragdoll")
                        end

                        rag:SetModel(ent:GetModel())
                        rag:SetPos(offpos)
                        rag:SetAngles(ent:GetAngles())
                        rag:SetColor(ent:GetColor())
                        rag:SetMaterial(ent:GetMaterial())
                        rag:Spawn()
                        rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                        rag:Fire("Kill", 1, 300)

                        for i=0,rag:GetPhysicsObjectCount() - 1 do

                            local bone = rag:TranslatePhysBoneToBone(i)
                            local phys = rag:GetPhysicsObjectNum(i)

                            if phys then

                                local bpos,bang = ent:GetBonePosition(bone)

                                if bpos and bang then
                                    phys:SetPos(bpos)
                                    phys:SetAngles(bang)
                                end

                                phys:Wake()
                                phys:SetVelocity(ent:GetVelocity())

                            end

                        end

                        local bonetrace = {}
                        bonetrace.start = hitpos
                        bonetrace.endpos = hitpos + self.Vel / 25
                        bonetrace.filter = {self, self.Owner, ClassName}
                        bonetrace.mask = MASK_SHOT - CONTENTS_SOLID
                        local bonetr = util.TraceLine(bonetrace)

                        if IsValid(rag) then

                            local bone = rag:GetPhysicsObjectNum(bonetr.PhysicsBone)

                            if bone then

                                bone:SetPos(offpos)
                                self:SetPos(offpos)

                                local hitent = trw.Entity

                                if IsValid(hitent) and (not hitent:IsPlayer() and not hitent:IsNPC() and not hitent:IsNextBot() and hitent:GetMoveType() == MOVETYPE_VPHYSICS) then
                                    self:SetParent(hitent)
                                    rag:SetOwner(hitent:GetOwner() or hitent)
                                    constraint.Weld(rag, hitent, bonetr.PhysicsBone, 0, 0, false, true)
                                elseif trw.HitWorld then
                                    bone:EnableMotion(false)
                                    timer.Simple(1,function()
                                        constraint.Weld(rag, game.GetWorld(), bonetr.PhysicsBone, 0, 0, false, true)
                                    end)
                                end

                            end

                            if ent:IsPlayer() then
                                local oldrag = ent:GetRagdollEntity()
                                if IsValid(oldrag) then
                                    oldrag:Remove()
                                end
                            else
                                ent:Remove()
                            end

                            sound.Play("weapons/crossbow/bolt_skewer1.wav", rag:GetPos(), 90, 100)

                        end

                    end

                elseif self.DmgAmt >= ent:Health() and (not trw.Hit or not self.CanDoPin) then
                    self:SetNoDraw(true)
                    self:Remove()
                end

            end

            if not self.Pinned then
                ent:TakeDamageInfo(dmg)
            end

			self:Fire("kill", 1, 60)
			self:SetHit(true)

		end

		if self:GetHit() and IsValid(self:GetAHitEnt()) and self:GetAHitEnt():Health() <= 0 and not self.PerformPin then
			self:SetNoDraw(true)
			self:Remove()
		end

		self.LastTrace = CurTime()
		self:NextThink(CurTime() + 0.01)
		return true

	end

	function ENT:OnRemove()
		if IsValid(self.Trail) then
			self.Trail:Fire("Kill",0)
		end
	end

	local function DenyBoltMoving(ply, ent)
		if ent:GetClass() == ClassName then return false end
	end
	hook.Add("PhysgunPickup", "DenyScavBoltPhysGunning", DenyBoltMoving)



end

if CLIENT then

	local EFFECT = {}

	function EFFECT:Init(data)

		self.Pos = data:GetOrigin()
		self.DieTime = CurTime() + 0.5

		local vOrig = self.Pos

		local trdata = {}
		trdata.start = self.Pos
		trdata.endpos = self.Pos + data:GetNormal() * -10
		if IsValid(data:GetEntity()) then
			trdata.filter = data:GetEntity()
		end
		local tr = util.TraceLine(trdata)

		local ef = EffectData()
		ef:SetStart(self:GetVelocity():GetNormalized() * -1)
		ef:SetOrigin(tr.HitPos)
		ef:SetStart(self.Pos)
		ef:SetSurfaceProp(tr.SurfaceProps)
		ef:SetHitBox(tr.HitBox)
		ef:SetNormal(tr.HitNormal)
		ef:SetDamageType(data:GetDamageType() or DMG_BULLET)
		ef:SetScale(1)
		ef:SetMagnitude(1)
		ef:SetEntity(tr.Entity or game.GetWorld())

		util.Effect("Impact", ef)

	end

	function EFFECT:Think()

		if self.DieTime and CurTime() > self.DieTime then
			return false
		end

		return true

	end

	function EFFECT:Render()
	end

	effects.Register(EFFECT,"ef_scav_impalerimpact",true)

end
