----------------------------------------------------------
--Status Effects System --
---------------------------------------------------------

--[[======================================================================================================================================================================================
	AUTHOR: Ghor
	--This was originally created for personal use, but as I started working on this system more and more I realized how many people might be able to make use of my work..
	--I've provided a wide range of status effects with this script, and new ones can be added very easily.
	--Don't forget to include an icon for your custom status effects!  It should go in materials/hud/status/, and have the same name as your status effect. It will automatically resource.AddFile() itself and appear for the client when they get the status.
======================================================================================================================================================================================]]--

--damage fix
DMG_FREEZE = 16
DMG_CHEMICAL = 1048576

AddCSLuaFile()

if SERVER then
	local files = file.Find("materials/hud/status/*", "GAME")
	for _,v in ipairs(files) do
		resource.AddSingleFile(string.lower("materials/hud/status/"..v))
	end
	hook.Add("PlayerInitialSpawn", "SendStatus", function(pl) for _,v in ipairs(Status2.GetAll()) do Status2.Inflict(v.Owner,v.Name,v.EndTime - CurTime(),v.Value,v.Inflictor) end end)
end

local STATUS_ENT = FindMetaTable("Entity")
local STATUS_PLY = FindMetaTable("Player")

Status2 = {}
Status2.AllInstances = {}
Status2.AllEffects = {}
	
hook.Add("Think","StatusThink", function()

	for _,v in ipairs(Status2.GetAll()) do
	
		if v.Think and (v.nextthinktime < CurTime()) and IsValid(v.Owner) then
			local res = v:Think()
			if not res then
				v:NextThink(CurTime() + 0.1)
			end
		end

		if v.EndTime < CurTime() and not v.Infinite then
			if v.Finish and IsValid(v.Owner) then
				v:Finish()
			end
			Status2.RemoveInstance(v)
		elseif v.infinite then
			v.EndTime = CurTime() + 10
		end

		if CLIENT and IsValid(v.Owner) and GetConVar("cl_scav_colorblindmode"):GetBool() == true and v.Owner:GetStatusEffect("Cloak") == nil and GetViewEntity() ~= v.Owner then
					--colorblind mode is on, the entity isn't invisible and isn't what we're looking through (we'll see the status on our HUD if we're looking through it)
			for j,k in ipairs(v.Owner.StatusTable) do
				local emitter = ParticleEmitter(v.Owner:GetPos())
				if IsValid(emitter) then
					local size = 8
					--local vec = v.Owner:GetPos() - GetViewEntity():GetPos() --introduces a bit of "warping" at edges of view
					local vec = EyeAngles()
					vec.z = 0 --we don't care about the Z, don't let it confuse us
					vec = vec:Right()
					local statpos = (j-(#k.Owner.StatusTable+1)/2)*size*2
					local part = emitter:Add("hud/status/" .. k.Name,emitter:GetPos()+Vector(vec.x*statpos,vec.y*statpos,k.Owner:OBBMaxs().z+size*2))
					if part then
						part:SetDieTime(.01)
						part:SetStartAlpha(25)
						part:SetStartSize(size)
						part:SetEndSize(size)
					end
					emitter:Finish()
				end
			end
		end
	end
	
end)

function Status2.GetAll()
	return Status2.AllInstances
end
	
hook.Add("Initialize","SetupStatusHook",function()
	function GAMEMODE:OnStatusInflicted(tab)
		return false
	end
end)
	
if SERVER then
	util.AddNetworkString("StatusInflict")
end

function Status2.Inflict(ent,statustype,duration,value,inflictor,infinite) --entity, string, number, number, entity (whether or not this is needed depends on the effect)

	if not IsValid(ent) or (SERVER and ent:IsPlayer() and not ent:Alive()) or (ent.StatusImmunities and ent.StatusImmunities[statustype]) then return end
	
	local tab = ent.StatusTable or {}
	
	if ent:GetClass() == "phys_bone_follower" then
		ent = ent:GetOwner()
	end
	
	local tab = ent.StatusTable or {}
	
	ent.StatusTable = tab
	tab.ent = ent
	tab.statustype = statustype
	tab.duration = duration
	tab.value = value
	tab.inflictor = inflictor
	tab.infinite = infinite
	
	if gamemode.Call("OnStatusInflicted",tab) then return end --I'm passing a table as an argument here so the gamemode has a shot at changing the values

	ent = tab.ent
	statustype = tab.statustype
	duration = tab.duration
	value = tab.value
	inflictor = tab.inflictor
	infinite = tab.infinite
	
	if SERVER then
		local rf = RecipientFilter()
		rf:AddAllPlayers()
		net.Start("StatusInflict")
			net.WriteEntity(ent)
			net.WriteString(statustype)
			net.WriteFloat(duration)
			net.WriteFloat(value)
			net.WriteEntity(inflictor)
			net.WriteBool(infinite)
		net.Send(rf)
	end
	
	--if the ent already has this status effect
	for _,v in ipairs(tab) do
		if v.Name == statustype then
			v.Infinite = infinite
			if v.Add then --if there is a function to handle adding...
				v:Add(duration,value)
				return v
			end
			return v
		end
	end
	--if this is a new effect being inflicted..
	if duration > 0 then --if you want to end a status effect early, just throw a negative value into the duration argument and it'll subtract from an existing effect
		local newstat = Status2.New(statustype)
		newstat.Owner = ent
		newstat.StartTime = CurTime()
		newstat.EndTime = CurTime() + duration
		newstat.Value = value
		newstat.Inflictor = inflictor or Entity(0)
		newstat.Infinite = infinite
		table.insert(tab,newstat)
		table.insert(Status2.AllInstances,newstat)
		newstat:Initialize()
		return newstat
	end
end
	
STATUS_ENT.InflictStatusEffect = Status2.Inflict

function Status2.New(statustype)
	local ef = Status2.AllEffects[statustype]
	return table.Inherit({["Value"] = 0, ["EndTime"] = 0, ["StartTime"] = 0, ["Owner"] = NULL}, ef)
end

function Status2.RemoveInstance(stat)
	if IsValid(stat.Owner) then
		for k,v in ipairs(stat.Owner.StatusTable) do
			if v == stat then
				table.remove(stat.Owner.StatusTable,k)
				break
			end
		end
		for k,v in ipairs(Status2.AllInstances) do
			if v == stat then
				table.remove(Status2.AllInstances,k)
				break
			end
		end
	end
end
	
if SERVER then
	util.AddNetworkString("StatusPurge")
end

function Status2.PurgeEnt(self)
	if SERVER then
		net.Start("StatusPurge")
			net.WriteEntity(self)
		net.Send(self)
	end
	if not IsValid(self) or not self.StatusTable then
		return
	end
	for i=1,#self.StatusTable do
		self.StatusTable[1]:Finish()
		Status2.RemoveInstance(self.StatusTable[1])
	end
end
	
STATUS_ENT.ClearStatusEffect = Status2.PurgeEnt

function Status2.Register(name,stattable)
	Status2.AllEffects[name] = table.Inherit(stattable,Status2.base)
end
	
function STATUS_ENT:GetStatusEffect(name)
	if not self.StatusTable then
		return
	end
	for _,v in ipairs(self.StatusTable) do
		if v.Name == name then
			return v
		end
	end
end
	
Status2.base = {}

local BASE = Status2.base
BASE.nextthinktime = 0
function BASE:NextThink(nextthink)
	self.nextthinktime = nextthink
end

local em = nil

if CLIENT then

	local trans_dk_gray = Color(100,100,100,200)
	em = ParticleEmitter(vector_origin)
	
	net.Receive("StatusInflict",function() Status2.Inflict(net.ReadEntity(),net.ReadString(),net.ReadFloat(),net.ReadFloat(),net.ReadEntity(),net.ReadBool()) end)
	net.Receive("StatusPurge", function() Status2.PurgeEnt(net.ReadEntity()) end)
	
	hook.Add("HUDPaint","StatusHUD",function()
		if GetViewEntity().StatusTable then
		
			local num = #GetViewEntity().StatusTable
			if num == 0 then return end
			local y = ScrH() - 48
			local xbase = ScrW() / 2 - num * 32
			draw.RoundedBox(16,xbase - 16,y,num * 64 + 32,32,trans_dk_gray)
			
			for k,v in ipairs(GetViewEntity().StatusTable) do
				surface.SetTexture(surface.GetTextureID("hud/status/"..string.lower(v.Name)))
				local x = xbase + k * 64 - 64
				surface.DrawTexturedRect(x,y,32,32)
				if not v.Infinite then
					draw.DrawText(math.max(math.floor(v.EndTime - CurTime()),0),"Trebuchet18",x + 48,y + 8,color_white,TEXT_ALIGN_RIGHT)
				else
					draw.DrawText("∞","Trebuchet18",x + 48,y + 16,color_white,TEXT_ALIGN_RIGHT)
				end
			end
			
		end
	end)
	
else

	hook.Add("PlayerDeath","PlayerStatusReset",Status2.PurgeEnt)
	hook.Add("PlayerSilentDeath","PlayerStatusReset",Status2.PurgeEnt)
end
		
	
	
	
	
	
	
	
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
--Speed

if not STATUS_PLY.SetWalkSpeedOld then
	STATUS_PLY.SetWalkSpeedOld = STATUS_PLY.SetWalkSpeed
		function STATUS_PLY:SetWalkSpeed(speed)
			if speed then
				self:SetWalkSpeedOld(speed)
				self.WalkSpeed = speed
			end
		end
		function STATUS_PLY:GetWalkSpeed()
			return (self.WalkSpeed or 250)
		end

	STATUS_PLY.SetRunSpeedOld = STATUS_PLY.SetRunSpeed
		function STATUS_PLY:SetRunSpeed(speed)
			if speed then
				self:SetRunSpeedOld(speed)
				self.RunSpeed = speed
			end
		end
		function STATUS_PLY:GetRunSpeed()
			return (self.RunSpeed or 500)
		end
		
	if not vFireInstalled then --vFire breaks this so let's make sure it doesnt init if vFire exists
		STATUS_ENT.IgniteOld = STATUS_ENT.Ignite
		function STATUS_ENT:Ignite(duration,radius,inflictor)
			if not radius then radius = 0 end
			if not inflictor then inflictor = self end
			self:InflictStatusEffect("Burning",duration,radius,inflictor)
		end
		
		STATUS_ENT.ExtinguishOld = STATUS_ENT.Extinguish
	end
	
	
end
	
local STATUS = {}
	
	STATUS.Name = "Speed"
	
	function STATUS:Initialize()
		self.NextStaminaHeal = CurTime()
	end
	
	if SERVER then
		hook.Add("EntityTakeDamage","ScavSpeed",function(ent,dmginfo)
			if ent:GetStatusEffect("Speed") and dmginfo:IsDamageType(DMG_FALL) then
				local reduced = math.max(1,dmginfo:GetDamage() * 0.25) --take only 25% fall damage (at least 1)
				dmginfo:SetDamage(reduced)
				return dmginfo
			end
		end)
	end

	function STATUS:Think()
		if SERVER and IsValid(self.Owner) and self.Owner:IsPlayer() and self.Owner:GetSuitPower() < 100 and self.NextStaminaHeal and self.NextStaminaHeal < CurTime() then
			self.Owner:SetSuitPower(math.Clamp(self.Owner:GetSuitPower()+5,0,100))
			self.NextStaminaHeal = CurTime() + 0.5
		end
	end
	
	function STATUS:Finish()
	end
	
	function STATUS:Add(duration,value)
		self.Value = value
		self.EndTime = self.EndTime+duration
	end
	
	Status2.Register("Speed",STATUS)

--Slow

local STATUS = {}

	STATUS.Name = "Slow"
	
	function STATUS:Initialize()
		if IsValid(self.Owner) then
			self.Owner.Status_slow = self
		end
		self.NextStaminaHeal = CurTime()
	end
	
	function STATUS:Think()
		if SERVER and GetConVar("gmod_suit"):GetBool() and IsValid(self.Owner) and self.Owner:IsPlayer() and self.NextStaminaHeal and self.NextStaminaHeal < CurTime() then
			if self.Owner:IsSprinting() then
				self.Owner:SetSuitPower(math.Clamp(self.Owner:GetSuitPower()-5,0,100))
			elseif self.Owner:GetSuitPower() < 100 then
				self.Owner:SetSuitPower(math.Clamp(self.Owner:GetSuitPower()-2.5,0,100))
			end
			self.NextStaminaHeal = CurTime() + 0.5
		end
	end
	
	function STATUS:Finish()
		if IsValid(self.Owner) then
			self.Owner.Status_slow = false
		end
	end
	
	function STATUS:Add(duration,value)
		self.Value = value
		self.EndTime = self.EndTime+duration
	end
	
	Status2.Register("Slow",STATUS)	
	
	hook.Add("Move","StatusSpeedSlow",function(pl,movedata)
		local scale = 1
		local speedstatus = pl:GetStatusEffect("Speed")
		local slowstatus = pl:GetStatusEffect("Slow")
		if speedstatus then
			scale = speedstatus.Value
		end
		if slowstatus then
			scale = scale*slowstatus.Value
		end
		if scale ~= 1 then
			movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed()*scale)
			movedata:SetMaxSpeed(movedata:GetMaxSpeed()*scale)
			movedata:SetForwardSpeed(movedata:GetForwardSpeed()*scale)
			movedata:SetSideSpeed(movedata:GetSideSpeed()*scale)
			if slowstatus and movedata:GetVelocity().z > 0 then
				movedata:SetVelocity(movedata:GetVelocity() + Vector(0,0,math.Clamp(-10/scale,-10,pl:GetJumpPower()*-1)))
			end
		end
	end)
	
--Cloak

local STATUS = {}
	
	STATUS.Name = "Cloak"
	STATUS.color = Color(0,0,0,0)
--	TODO- make NPCs totally ignore cloaked players. Probably need a table of them with their current relationships that can be reset when cloak is off
--				Making enemies neutral means traps won't activate from them, need a better way. Some npc perception hook we could get in?

	function STATUS:Initialize()
		local r,g,b,a = self.Owner:GetColor().r,self.Owner:GetColor().g,self.Owner:GetColor().b,self.Owner:GetColor().a
		--self.Owner:SetColor(Color(r,g,b,0))
		--self.Owner:SetRenderMode(RENDERMODE_TRANSALPHA)
		self.Owner:SetMaterial("effects/predator_camo")
		self.Owner:DrawShadow(false)
		if self.Owner:IsPlayer() then
			for k,v in ipairs(self.Owner:GetWeapons()) do
				--v:SetColor(Color(r,g,b,0))
				--v:SetRenderMode(RENDERMODE_TRANSALPHA)
				v:SetMaterial("effects/predator_camo")
				v:DrawShadow(false)
			end
			--[[if SERVER then
				for i, npc in ipairs( ents.FindByClass( "npc_*" ) ) do
					if IsValid( npc ) and npc:IsNPC() then
						if IsValid(npc:GetEnemy()) and npc:GetEnemy() == self.Owner then
							npc:AddEntityRelationship(self.Owner,D_NU,1)
							npc:MarkEnemyAsEluded(self.Owner)
						end
					end
				end
			end]]--
		end
		if CLIENT then
			if (self.Owner == LocalPlayer()) then
				local pos = self.Owner:GetPos()
				pos.z = pos.z+1
				self.Owner:SetPos(pos)
				--self.Owner:GetViewModel():SetMaterial("models/shadertest/predator")
				self.Owner:GetViewModel():SetMaterial("effects/predator_camo")
				self.Owner:GetHands():SetMaterial("effects/predator_camo")
			end
		end
		if IsMounted(440) then --only use TF2 sounds if TF2 is mounted
			self.Owner:EmitSound("player/spy_cloak.wav")
		else
			self.Owner:EmitSound("friends/friend_online.wav")
		end
		self.Owner.Status_cloak = true
	end
	
	function STATUS:Think()
		--[[if SERVER then
			for i, npc in ipairs( ents.FindByClass( "npc_*" ) ) do
				if IsValid( npc ) and npc:IsNPC() then
					if IsValid(npc:GetEnemy()) and npc:GetEnemy() == self.Owner then
						npc:AddEntityRelationship(self.Owner,D_NU,1)
						npc:MarkEnemyAsEluded(self.Owner)
					end
				end
			end
		end]]--
	end
	
	function STATUS:Finish()
		local r,g,b,a = self.Owner:GetColor().r,self.Owner:GetColor().g,self.Owner:GetColor().b,self.Owner:GetColor().a
		self.Owner:SetColor(Color(r,g,b,a))
		self.Owner:SetRenderMode(RENDERMODE_NORMAL)
		self.Owner:SetMaterial("")
		self.Owner:DrawShadow(true)
		if self.Owner:IsPlayer() then
			for k,v in ipairs(self.Owner:GetWeapons()) do
				--v:SetColor(Color(r,g,b,255))
				v:SetMaterial("")
				--v:SetRenderMode(RENDERMODE_NORMAL)
				v:DrawShadow(true)
			end
			--[[if SERVER then
				for i, npc in ipairs( ents.FindByClass( "npc_*" ) ) do
					if IsValid( npc ) and npc:IsNPC() then
						if npc:GetRelationship(self.Owner) == D_NU then --and npc:GetRelationship(CLASS_PLAYER) == D_HT then --Not sure how to test for this
							npc:AddEntityRelationship(self.Owner,D_HT,1)
							--npc:MarkEnemyAsEluded(self.Owner)
						end
					end
				end
			end]]--
		end
		if CLIENT then
			if (self.Owner == LocalPlayer()) then
				self.Owner:GetViewModel():SetMaterial()
				self.Owner:GetHands():SetMaterial()
			end
		end
		if IsMounted(440) then --only use TF2 sounds if TF2 is mounted
			self.Owner:EmitSound("player/spy_uncloak.wav")
		else
			self.Owner:EmitSound("npc/turret_floor/die.wav")
		end
		self.Owner.Status_cloak = false
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
	end
	
	Status2.Register("Cloak",STATUS)
	
	if CLIENT then
		hook.Add("HUDDrawTargetID","cloaknoid",function() if LocalPlayer():GetEyeTrace().Entity.Status_cloak then return false end end)
	end
	

--Frozen
	local STATUS = {}
	
	STATUS.Name = "Frozen"
	
	util.PrecacheModel("models/props_junk/watermelon01_chunk02a.mdl")
	util.PrecacheModel("models/props_debris/concrete_chunk03a.mdl")
	util.PrecacheModel("models/props_combine/breenbust_Chunk03.mdl")

	
	function STATUS:Initialize()
		if SERVER then
			self.Owner:EmitSound("physics/glass/glass_strain2.wav")
			self.Owner:EmitSound("physics/glass/glass_strain2.wav")
			self.col = self.Owner:GetColor()
		end
		self.Owner.Status_frozen = self
		self.movetype = self.Owner:GetMoveType()
		if self.Owner:IsPlayer() then
			self.Owner:GetActiveWeapon():SetNextPrimaryFire(self.EndTime)
			self.Owner:GetActiveWeapon():SetNextSecondaryFire(self.EndTime)
			self.aim = self.Owner:GetAimVector():Angle()
			self.wep = self.Owner:GetActiveWeapon():GetClass()
			self.Owner:Freeze(true)
		elseif self.Owner:IsNPC() and SERVER then
			self.Owner:CapabilitiesRemove(CAP_TURN_HEAD)
			self.Owner:CapabilitiesRemove(CAP_AIM_GUN)
		end
	end
	
	if SERVER then
		function STATUS:Think()
			if self.Owner:IsPlayer() then
				self.Owner:SelectWeapon(self.wep)
			elseif self.Owner:IsNPC() and (self.Owner:Health() > 0) then
				self.Owner:SetSchedule(SCHED_NPC_FREEZE)
				self.Owner:SetNPCState(NPC_STATE_NONE)
			elseif self.Owner:IsNPC() then
				self.Owner:SetSchedule(SCHED_NONE)
			elseif _ZetasInstalled and self.Owner:GetClass() == "npc_zetaplayer" then --Zeta Player specific
				self.Owner:CancelMove()
				self.Owner:StopLooking()
				self.Owner:SetState('jailed/held')
			elseif IsValid(self.Owner:GetPhysicsObject()) and self.Owner:GetMoveType() == MOVETYPE_VPHYSICS then
				local phys = self.Owner:GetPhysicsObject()
				if IsValid(phys) then
					if phys:IsMotionEnabled() then
						self.Owner.wasmotionenabled = phys:IsMotionEnabled()
						self.Owner.unfreezevel = phys:GetVelocity()
						phys:Sleep()
						phys:EnableMotion(false)
					end
				end
			end
			self:NextThink(CurTime()+0.01)
			return true
		end
		local noshatter = {DMG_FREEZE, DMG_SLOWFREEZE, DMG_ENERGYBEAM, DMG_DIRECT, DMG_BURN, DMG_SLOWBURN, DMG_POISON, DMG_RADIATION, DMG_PARALYZE, DMG_DROWN, DMG_DROWNRECOVER, DMG_NERVEGAS, DMG_CHEMICAL}
		hook.Add("EntityTakeDamage","FrozenDmg",function(ent,dmginfo)
			if ent.Status_frozen and not table.HasValue(noshatter,dmginfo:GetDamageType()) then
				dmginfo:ScaleDamage(10)
			end
			if ent.Status_frozen and ((dmginfo:GetDamageType() == DMG_DIRECT) or (dmginfo:GetDamageType() == DMG_BURN) or (dmginfo:GetDamageType() == DMG_SLOWBURN)) then
				ent:InflictStatusEffect("Frozen",-1,1)
				ent:InflictStatusEffect("Acid",1,0.025) --sizzle
				return true
			end
			if ent.Status_frozen and (dmginfo:GetDamageType() == DMG_FREEZE) then
				return true
			end
			if ent.Status_frozen and (ent:IsNPC() or ent:IsNextBot()) and (dmginfo:GetDamage() > ent:Health()) then
				if ent:IsNPC() then
					ent:SetSchedule(SCHED_NONE)
				end
				local self = ent.Status_frozen
				local rag = ents.Create("prop_ragdoll")
				rag:SetModel(ent:GetModel())
				rag:SetPos(ent:GetPos())
				rag:SetAngles(ent:GetAngles())
				rag:Spawn()
				rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				if rag:GetPhysicsObjectCount() < 2 then
					rag:Remove()
					local data = EffectData()
					local pos = ent:GetPos()+ent:OBBCenter()
					for i=1,4 do
						data:SetOrigin(pos)
						local dvec = VectorRand()*100
						data:SetStart(dvec)
						data:SetNormal(dvec)
						util.Effect("ef_frozen_chunk",data)
					end
				else
					for i=0,rag:GetPhysicsObjectCount()-1 do
						local bone = rag:TranslatePhysBoneToBone(i)
						local phys = rag:GetPhysicsObjectNum(i)
						if phys then
							local bpos,bang = ent:GetBonePosition(bone)
							local data = EffectData()
							if bpos then
								data:SetOrigin(bpos)
								data:SetStart(ent:GetVelocity():GetNormalized()*100)
							end
							if bang then
								data:SetNormal(bang:Forward())
							end
							util.Effect("ef_frozen_chunk",data)
						end
					end
				end
				if ent:IsNPC() then
					gamemode.Call("OnNPCKilled",ent,attacker,inflictor)
				end
				ent:Remove()
				rag:Remove()
				ent:EmitSound("physics/glass/glass_sheet_break1.wav")
				return true
			end
			return
		end)
		hook.Add("PlayerDeath","FreezeShatter",function(pl,inflictor,attacker)
			if pl.Status_frozen then
				local self = pl.Status_frozen
				pl:EmitSound("physics/glass/glass_sheet_break1.wav")
				local rag = ents.Create("prop_ragdoll")
				rag:SetModel(pl:GetModel())
				rag:SetPos(pl:GetPos())
				rag:SetAngles(pl:GetAngles())
				rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				rag:Spawn()
				for i=0,rag:GetPhysicsObjectCount()-1 do
					local bone = rag:TranslatePhysBoneToBone(i)
					local phys = rag:GetPhysicsObjectNum(i)
					if phys then
						local bpos,bang = pl:GetBonePosition(bone)
						local data = EffectData()
						if bpos then
							data:SetOrigin(bpos)
							data:SetStart(pl:GetVelocity():GetNormalized()*100)
						end
						if bang then
							data:SetNormal(bang:Forward())
						end
						util.Effect("ef_frozen_chunk",data)
					end
				end
				rag:Remove()
				if IsValid(self.Owner:GetRagdollEntity()) then
					pl:GetRagdollEntity():Remove()
				end
			end
		end)
	end
	
	function STATUS:Finish()
		if not IsValid(self.Owner) then
			return
		end
		self.Owner.Status_frozen = false
		if SERVER then
			if not self.Owner:GetStatusEffect("Acid") then
				self.Owner:EmitSound("physics/glass/glass_sheet_break1.wav")
			end
			if self.Owner:IsNPC() then
				self.Owner:SetNPCState(NPC_STATE_ALERT)
				self.Owner:SetSchedule(SCHED_NONE)
				self.Owner:CapabilitiesAdd(CAP_TURN_HEAD)
				self.Owner:CapabilitiesAdd(CAP_AIM_GUN)
				local dmg = DamageInfo()
				dmg:SetAttacker(self.Inflictor)
				dmg:SetInflictor(self.Inflictor)
				dmg:SetDamage(1)
				dmg:SetDamageForce(vector_origin)
				dmg:SetDamagePosition(self.Owner:GetPos())
				dmg:SetDamageType(DMG_DIRECT)
				self.Owner:TakeDamageInfo(dmg)
			end
			if _ZetasInstalled and self.Owner:GetClass() == "npc_zetaplayer" then --Zeta Player specific
				self.Owner:SetState('idle')
			end
			if not self.Owner:IsPlayer() then
				self.Owner:SetMaterial(self.mat)
				local phys = self.Owner:GetPhysicsObject()
				if IsValid(phys) and not phys:IsMotionEnabled() and self.Owner.wasmotionenabled then
					phys:EnableMotion(true)
					phys:Wake()
					if self.Owner.unfreezevel then
						phys:SetVelocity(self.Owner.unfreezevel)
						self.Owner.unfreezevel = nil
					end
				end
			else
				self.Owner:Freeze(false)
				self.Owner:ViewPunch(Angle(60,math.random(-10,10),math.random(-10,10)))
				self.Owner:InflictStatusEffect("Shock",2,10)
			end
		end
		self.Owner:SetMoveType(self.movetype)
	end
	
	Status2.Register("Frozen",STATUS)
	if CLIENT then
		local freezemat = Material("hud/status/iceoverlay1")
		hook.Add("CreateMove","FreezeView",function(UCMD)
				if LocalPlayer().Status_frozen then
					UCMD:SetMouseX(0)
					UCMD:SetMouseY(0)
					UCMD:SetViewAngles(LocalPlayer().Status_frozen.aim)
					return true
				end
			end)
		hook.Add("RenderScreenspaceEffects","IceOverlay",function()
				if GetViewEntity().Status_frozen then
					render.SetMaterial(freezemat)
					render.DrawScreenQuad()
				end
			end)
	else
		hook.Add("Move","FreezeMove",function(pl,MoveData)
				if pl.Status_frozen then
					MoveData:SetVelocity(Vector(0,0,0))
					MoveData:SetMaxClientSpeed(0)
					MoveData:SetMaxSpeed(0)
					return true
				end
			end)
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
	end
	
--Shock

local STATUS = {}
	
	STATUS.Name = "Shock"
	
	function STATUS:Initialize()
		self.Owner.Status_shock = true
	end
	
	if CLIENT then
		function STATUS:Think()	
			if (self.Owner == LocalPlayer()) then
				--self.Owner:SetEyeAngles(EyeAngles()+Angle(math.Rand(-2,2),math.Rand(-2,2),0))
				self.Owner:SetEyeAngles((VectorRand()*0.02+self.Owner:GetAimVector()):Angle())
			end
			self:NextThink(CurTime()+1/self.Value)
			return true
		end
	else
		function STATUS:Think()
		end
	end
	
	function STATUS:Finish()
		self.Owner.Status_shock = false
	end

	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
		self.Value = math.max(self.Value,value)	
	end
	
	Status2.Register("Shock",STATUS)
	
	hook.Add("GetMotionBlurValues","ShockBlur",function(x,y,fwd,spin) if GetViewEntity().Status_shock then return math.Rand(-1,1),math.Rand(-1,1),fwd,spin end end)
	
--Burning


	function STATUS_ENT:Extinguish()
		if self.StatusTable then
			for k,v in ipairs(self.StatusTable) do
				if v.Name == "Burning" then
					self:InflictStatusEffect("Burning",CurTime()-v.EndTime,0)
				end
			end
		end
	end
		
		

local STATUS = {}
	
	STATUS.Name = "Burning"
	
	function STATUS:Initialize()
		if SERVER then
			self.Owner:IgniteOld(self.EndTime-CurTime(),self.value)
		end
		self.Owner.ignitedby = self.Inflictor
	end
	
	function STATUS:Think()
		--Put ourselves out in water
		if self.Owner:WaterLevel() > 2 then
			self.EndTime = self.EndTime - 2.0
		elseif self.Owner:WaterLevel() > 1 then
			self.EndTime = self.EndTime - 1.0
		elseif self.Owner:WaterLevel() > 0 then
			self.EndTime = self.EndTime - 0.5
		end
		--Put ourselves out on Frozen (melt ice, too)
		if self.Owner:GetStatusEffect("Frozen") then
			self.Owner:InflictStatusEffect("Acid",1,0.025) --sizzling (acid multiplies its value by 5 for its added duration)
			--self.Owner:InflictStatusEffect("Frozen",-.1,0) --freezing does this already
			self.EndTime = self.EndTime - 0.1
		end
	end
	if SERVER then
		hook.Add("EntityTakeDamage","FireDmg",function(ent,dmginfo)
			if dmginfo:GetDamageType() == DMG_FREEZE then
				ent:InflictStatusEffect("Burning",-1,1)
				ent:InflictStatusEffect("Acid",1,0.025) --sizzle
				return true
			end
			return
		end)

		hook.Add("Touch","FireTouch",function(ent) --TODO: only seems to be called for props with it enabled in their flags.
				local dmg = DamageInfo()
					dmg:SetDamageType(DMG_BURN)
					dmg:SetInflictor(self)
					dmg:AddDamage(1)
				ent:TakedamageInfo(dmg)
				return true
		end)
	end

	function STATUS:Finish()
		if SERVER then
			self.Owner:ExtinguishOld()
		end
		hook.Remove("EntityTakeDamage","FireDmg")
		hook.Remove("Touch","FireTouch")
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = CurTime()+duration
		--print(duration)
		if SERVER then
			self.Owner:IgniteOld(duration,self.value)
		end
	end
	
	Status2.Register("Burning",STATUS)

--Acid Burning
	
local STATUS = {}
	
	STATUS.Name = "Acid"
	STATUS.acideffect = NULL
	
	function STATUS:Initialize()
		self.Created = CurTime()
	end
	
	function STATUS:Think()
		if SERVER then
			local dmg = DamageInfo()
			if IsValid(self.Inflictor) then
				dmg:SetAttacker(self.Inflictor)
			else
				dmg:SetAttacker(game.GetWorld())
			end
			dmg:SetInflictor(dmg:GetAttacker())
			dmg:SetDamage(self.Value)
			self.Owner:EmitSound("ambient/levels/canals/toxic_slime_sizzle"..math.random(2,4)..".wav")
			dmg:SetDamageForce(vector_origin)
			dmg:SetDamagePosition(self.Owner:GetPos())
			dmg:SetDamageType(DMG_ACID)
			self.Owner:TakeDamageInfo(dmg)
		else
			local mins = self.Owner:OBBMins()
			local maxs = self.Owner:OBBMaxs()
			for i=1,3 do
				local pos = self.Owner:GetPos()+Vector(math.Rand(mins.x,maxs.x),math.Rand(mins.y,maxs.y),math.Rand(mins.z,maxs.z))
				local part = em:Add("particle/smokesprites_000"..math.random(1,9),pos)
				if part then
					part:SetVelocity(self.Owner:GetVelocity())
					part:SetDieTime(1)
					part:SetStartSize(2)
					part:SetEndSize(8+math.random(0,16))
					part:SetStartAlpha(255)
					part:SetEndAlpha(20)
					part:SetGravity(Vector(0,0,96))
					part:SetRoll(math.Rand(0,6.28))
					part:SetRollDelta(math.Rand(-6.28,6.28))
				end
			end
		end
		self.Value = self.Value-0.1
		if self.Owner:WaterLevel() > 2 then
			self.Value = self.Value-1
		end
		self.EndTime = self.Created+self.Value*5
		self:NextThink(CurTime()+0.5)
		return true
	end
	

	function STATUS:Finish()
		if IsValid(self.acideffect) then
			self.acideffect:Remove()
		end
	end
	
	function STATUS:Add(duration,value)
		self.Value = self.Value+value
		self.EndTime = self.Created+self.Value*5	
	end
	
	Status2.Register("Acid",STATUS)

--Deaf
	
local STATUS = {}

	STATUS.Name = "Deaf"
	STATUS.lastdsp = 0
	function STATUS:Initialize()
		if SERVER and self.Owner:IsNPC() then
			if CAP_HEAR then
				self.Owner:CapabilitiesRemove(CAP_HEAR)
			end
		end
	end
	
	function STATUS:Think()
		self:NextThink(CurTime()+0.05)
		if self.Owner:IsPlayer() and (SERVER or (GetViewEntity() == self.Owner)) then
			self.lastdsp = 1-self.lastdsp
			self.Owner:SetDSP(32+self.lastdsp)
		end
		return true
	end
	

	function STATUS:Finish()
		if SERVER and self.Owner:IsPlayer() then
			self.Owner:SetDSP(1)
		elseif SERVER and IsValid(self.Owner) and self.Owner:IsNPC() then
			if CAP_HEAR then
				self.Owner:CapabilitiesAdd(CAP_HEAR)
			end
		end
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
	end
	
	Status2.Register("Deaf",STATUS)
	
--Disease
	
local STATUS = {}
	
	STATUS.Name = "Disease"
	
	function STATUS:Initialize()
		if CLIENT then
			self.nextcough = CurTime()
		end
	end
	
	if SERVER then
		function STATUS:Think()
			self:NextThink(CurTime()+1/self.Value)
			if self.Owner:Health() > 1 then
				self.Owner:SetHealth(self.Owner:Health()-1)
			end
			return true
		end
	else
		function STATUS:Think()
			self:NextThink(CurTime()+1/self.Value/4)
			local sprite = math.random(1,7)	
			local mins = self.Owner:OBBMins()
			local maxs = self.Owner:OBBMaxs()
			local pos = self.Owner:GetPos()+Vector(math.Rand(mins.x,maxs.x),math.Rand(mins.y,maxs.y),math.Rand(mins.z,maxs.z))
			local part = em:Add("hud/status/disease",pos)
			if part then
				part:SetVelocity(VectorRand()*50+self.Owner:GetVelocity())
				part:SetColor(255,255,255)
				part:SetDieTime(1)
				part:SetStartSize(6)
				part:SetEndSize(6)
				part:SetStartAlpha(255)
				part:SetEndAlpha(0)
				part:SetGravity(Vector(0,0,-96))
				part:SetRoll(math.Rand(0,6.28))
				part:SetRollDelta(math.Rand(-6.28,6.28))
			end
			if self.Owner:IsPlayer() and (self.nextcough < CurTime()) then
				self.Owner:EmitSound("ambient/voices/cough"..math.random(1,4)..".wav")
				self.nextcough = CurTime()+math.random(1,3)
			end
			return true
		end
	end
	
	function STATUS:Finish()
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
		self.Value = math.max(self.Value,value)	
	end
	
	Status2.Register("Disease",STATUS)

--DamageX
	
local STATUS = {}
	
	STATUS.Name = "DamageX"
	
	function STATUS:Initialize()
		if CLIENT then
--			self.Owner.Status_DmgXSnd = CreateSound(self.Owner,"HL1/ambience/alien_cycletone.wav")
--			self.Owner.Status_DmgXSnd:Play()
		end
	end
	
	if SERVER then
		hook.Add("EntityTakeDamage","StatusDamageX",function(ent,dmginfo)
			local attacker = dmginfo:GetAttacker()
			local inflictor = dmginfo:GetAttacker()
			if attacker:GetStatusEffect("DamageX") then
				dmginfo:ScaleDamage(attacker:GetStatusEffect("DamageX").Value)
				sound.Play("player/crit_hit"..math.random(2,5)..".wav",dmginfo:GetDamagePosition())
			elseif inflictor:GetStatusEffect("DamageX") then
				dmginfo:ScaleDamage(inflictor:GetStatusEffect("DamageX").Value)
				sound.Play("player/crit_hit"..math.random(2,5)..".wav",dmginfo:GetDamagePosition())
			end
		end)
		function STATUS:Think()
		end
	else
		function STATUS:Think()
			local ent
			local pos
			if self.Owner.GetActiveWeapon then
				if GetViewEntity() ~= self.Owner then
					ent = self.Owner:GetActiveWeapon()
				else
					ent = self.Owner:GetViewModel()
				end
				if not IsValid(ent) then
					return true
				end
				local att = ent:LookupAttachment("muzzle")
				if att == 0 then
					return true
				end
				if ent and ent:GetAttachment(att) then
					pos = ent:GetAttachment(att).Pos
				elseif ent then
					pos = ent:GetPos()
				end
			end
			self:NextThink(CurTime()+1/self.Value/4)
			local sprite = math.random(1,7)
			
			if not pos then
				local mins = self.Owner:OBBMins()
				local maxs = self.Owner:OBBMaxs()
				pos = self.Owner:OBBCenter()
			end

			local part = em:Add("hud/status/damagexpart",pos)
			if part then
				part:SetVelocity(VectorRand()*50+self.Owner:GetVelocity())
				part:SetColor(255,100,100)
				part:SetDieTime(0.4)
				part:SetStartSize(6)
				part:SetEndSize(6)
				part:SetStartAlpha(255)
				part:SetEndAlpha(0)
				part:SetGravity(Vector(0,0,-96))
				part:SetRoll(math.Rand(0,6.28))
				part:SetRollDelta(math.Rand(-6.28,6.28))
			end
		end
	end
	
	function STATUS:Finish()
		if CLIENT then
--			self.Owner.Status_DmgXSnd:Stop()
		end
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
		self.Value = math.max(self.Value,value)
	end
	
	Status2.Register("DamageX",STATUS)

--Invulnerability
	
local STATUS = {}
	
	STATUS.Name = "Invuln"
	
	function STATUS:Initialize()
		if CLIENT then
			self.Owner.Status_InvulnSnd = CreateSound(self.Owner,"ambient/machines/engine1.wav")
			self.Owner.Status_InvulnSnd:Play()
			if self.Owner == LocalPlayer() then
				local _,_,_,a = self.Owner:GetViewModel():GetColor()
				local _,_,_,a2 = self.Owner:GetHands():GetColor()
				local col = color_white
				if self.Owner:Team() == 1001 then --unassigned
					col = Color(self.Owner:GetPlayerColor().x*255,self.Owner:GetPlayerColor().y*255,self.Owner:GetPlayerColor().z*255,255)
				else
					col = team.GetColor(self.Owner:Team())
				end
				self.Owner:GetViewModel():SetColor(Color(col.r,col.g,col.b,a))
				self.Owner:GetHands():SetColor(Color(col.r,col.g,col.b,a2))
				self.Owner:GetViewModel():SetMaterial("hud/status/invulnoverlay")
				self.Owner:GetHands():SetMaterial("hud/status/invulnoverlay")
			end
		end
		if self.Owner:IsPlayer() then
			local _,_,_,a = self.Owner:GetColor()
			local col = color_white
			if self.Owner:Team() == 1001 then --unassigned
				col = Color(self.Owner:GetPlayerColor().x*255,self.Owner:GetPlayerColor().y*255,self.Owner:GetPlayerColor().z*255,255)
			else
				col = team.GetColor(self.Owner:Team())
			end
			self.Owner:SetColor(Color(col.r,col.g,col.b,a))
			for k,v in ipairs(self.Owner:GetWeapons()) do
				v:SetColor(Color(col.r,col.g,col.b,a))
				v:SetMaterial("hud/status/invulnoverlay")
			end
		end
		self.Owner:SetMaterial("hud/status/invulnoverlay")
	end
	
	if SERVER then
		hook.Add("EntityTakeDamage","StatusInvuln",function(ent,dmginfo)
			if ent:GetStatusEffect("Invuln") then
				return true
			end
		end)
	end
	
	function STATUS:Think()
	end
	
	function STATUS:Finish()
		if CLIENT then
			self.Owner.Status_InvulnSnd:Stop()
			if self.Owner == LocalPlayer() then
				self.Owner:GetViewModel():SetMaterial()
				self.Owner:GetHands():SetMaterial()
				local _,_,_,a = self.Owner:GetViewModel():GetColor()
				local _,_,_,a2 = self.Owner:GetHands():GetColor()
				self.Owner:GetViewModel():SetColor(Color(255,255,255,a))
				self.Owner:GetHands():SetColor(Color(255,255,255,a2))
			end
		end
		if self.Owner:IsPlayer() then
			local _,_,_,a = self.Owner:GetColor()
			self.Owner:SetColor(Color(255,255,255,a))
			for k,v in ipairs(self.Owner:GetWeapons()) do
				v:SetColor(Color(255,255,255,a))
				v:SetMaterial()
			end
		end
		self.Owner:SetMaterial()
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
	end
	
	Status2.Register("Invuln",STATUS)
	
--Radiation
	
local STATUS = {}
	
	STATUS.Name = "Radiation"
	STATUS.nextclick = 0
	
	function STATUS:Initialize()
		if CLIENT then
			self.dlight = DynamicLight(0)
			self.dlight.Pos = self.Owner:GetPos()
			self.dlight.r = 0
			self.dlight.g = 255
			self.dlight.b = 0
			self.dlight.Brightness = 3
			self.dlight.Size = 300
			self.dlight.Decay = 60
			self.dlight.DieTime = CurTime() + 1
		end
	end
	
	function STATUS:Think()
		if SERVER then
			self:NextThink(CurTime()+1/self.Value)
			local dmg = DamageInfo()
			dmg:SetInflictor(self.Owner)
			if self.Inflictor then
				dmg:SetAttacker(self.Inflictor)
			end
			dmg:SetDamageForce(vector_origin)
			dmg:SetDamageType(DMG_RADIATION)
			local ents = ents.FindInSphere(self.Owner:GetPos(),300)
			for k,v in ipairs(ents) do
				if v ~= self.Owner then
					dmg:SetDamage(100/(v:GetPos():Distance(self.Owner:GetPos())+1))
				else
					dmg:SetDamage(0.5)
				end
				dmg:SetDamagePosition(v:GetPos())
				v:TakeDamageInfo(dmg)
			end
		else
			self:NextThink(CurTime()+0.05)
			self.dlight.Pos = self.Owner:GetPos()
			self.dlight.Size = 300
			self.dlight.DieTime = CurTime() + 5
			if self.nextclick < CurTime() and (LocalPlayer():GetPos():Distance(self.Owner:GetPos()) < 1000) and (math.random(0,math.ceil(LocalPlayer():GetPos():Distance(self.Owner:GetPos())/100)) < 2) then
				LocalPlayer():EmitSound("player/geiger"..math.random(1,3)..".wav")
				self.nextclick = CurTime()+1/self.Value
			end
		end
		return true
	end

	function STATUS:Finish()
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
		self.Value = math.max(self.Value,value)	
	end
	
	Status2.Register("Radiation",STATUS)
	
--Numbness
	
local STATUS = {}
	
	STATUS.Name = "Numb"
	
	function STATUS:Initialize()
	end

	
	function STATUS:Think()
		return true
	end

	function STATUS:Finish()
	end
	
	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
		self.Value = math.max(self.Value,value)	
	end
	if CLIENT then
		hook.Add("HUDShouldDraw","SENumbness",function(name) if ((name == "CHudDamageIndicator") or (name == "CHudHealth")) and GetViewEntity():GetStatusEffect("Numb") then return false end end)
	end
	Status2.Register("Numb",STATUS)
	
if CLIENT then

	local matfreeze = Material("models/shiny")
	hook.Add("RenderScreenspaceEffects","StatusOverlays",function()
		cam.Start3D(EyePos(),EyeAngles())
			render.SetColorModulation(0.68,0.88,1)
			render.SetBlend(0.6)
			render.MaterialOverride(matfreeze)
			for k,v in ipairs(ents.GetAll()) do
				if v:GetStatusEffect("Frozen") then
					v:DrawModel()
				end
			end
			render.SetColorModulation(1,1,1)
			render.SetBlend(1)
			render.MaterialOverride()
		cam.End3D()
	end)

end

--Temporary Health
--Functions like in L4D, slowly decays over time, isn't used before permanent health is down to 1

local STATUS = {}
	
	STATUS.Name = "TemporaryHealth"
	STATUS.MaxDrain = 0
	local nextThink = 0
	function STATUS:Initialize()
		self.Value = 0
		self.MaxDrain = math.floor(self.EndTime - self.StartTime)
		--Reduce our status effect if we didn't apply our whole health bonus to the player (so we don't take away permanent health)
		local hypotheticalhealth = self.Owner:Health() + self.MaxDrain
		self.Owner:SetHealth(math.min(hypotheticalhealth,self.Owner:GetMaxHealth()))
		if hypotheticalhealth > self.Owner:GetMaxHealth() then
			self.MaxDrain = self.MaxDrain - (hypotheticalhealth - self.Owner:GetMaxHealth())
			self.EndTime = self.MaxDrain - self.Value + CurTime()
		end
		nextThink = self.nextthinktime --sync up our slower think with the entity's think time
	end
	
	function STATUS:Think()
		--the player's been damaged down to 1 permanent health, so our duration is going to be lowered
		if self.MaxDrain - self.Value > self.Owner:Health() - 1 then
			self.MaxDrain = self.Owner:Health() - 1
			self.Value = 0
			self.EndTime = self.MaxDrain - self.Value + CurTime()
		end
		 --our slowed down think function for removing health
		if nextThink < CurTime() then
			if self.Owner:Health() <= 1.1 then --Make sure we're removed if player is at 1 health (with a little extra for precision error)
				self.Value = self.MaxDrain
				self.Owner:InflictStatusEffect("TemporaryHealth",-1 * self.EndTime,1,self.Inflictor) --make sure we end
			elseif self.Value < self.MaxDrain then
				self.Owner:SetHealth(math.max(1,self.Owner:Health() - 1)) --Max 1 failsafe to make sure we don't kill the player
				self.Value = self.Value + 1
				self.EndTime = self.MaxDrain - self.Value + CurTime()
			end
			nextThink = self.nextthinktime + 1 --sync up our slower think with the entity's think time
		end
	end
	
	function STATUS:Finish()
		self.Owner:SetHealth(math.max(1,self.Owner:Health() - math.max(0,self.MaxDrain - self.Value))) --if we have any health left to drain, do it.
	end
	
	function STATUS:Add(duration,value) --for now, we don't allow another source of temporary health to be applied while one's active
		--self.EndTime = self.EndTime + duration
	end
	
	Status2.Register("TemporaryHealth",STATUS)
	
	if CLIENT then
		hook.Add("HUDDrawTargetID","TemporaryHealth",function() end)
	end

--Drunk

local STATUS = {}
	
	STATUS.Name = "Drunk"
	STATUS.LastValue = 0
	STATUS.StartTime = 0
	if CLIENT then
		local function DrawToyTown( NumPasses, H )
			cam.Start2D()
		
			surface.SetMaterial( matToytown )
			surface.SetDrawColor( 255, 255, 255, 255 )
		
			for i = 1, NumPasses do
		
				render.CopyRenderTargetToTexture( render.GetScreenEffectTexture() )
		
				surface.DrawTexturedRect( 0, 0, ScrW(), H )
				surface.DrawTexturedRectUV( 0, ScrH() - H, ScrW(), H, 0, 1, 1, 0 )
		
			end
		
			cam.End2D()
		end
	end

	function STATUS:Initialize()
		self.StartTime = CurTime()
		self.Value = 1
		if CLIENT then
			hook.Add( "RenderScreenspaceEffects", "ScavDrunk", function()
				DrawMaterialOverlay( "effects/water_warp01", 0.02 )
				surface.SetDrawColor(0,255,0,6)
				surface.DrawRect(0,0,ScrW(),ScrH())
				local H = math.floor( ScrH() * 0.69 )

				DrawToyTown( 3, H )
			end )
		end
	end
	
--if SERVER then
	function STATUS:Think()
		if SERVER then
			self.Owner:ViewPunch(Angle(math.Rand(-self.Value,self.Value),math.Rand(-self.Value,self.Value),0))
		else
			hook.Add( "RenderScreenspaceEffects", "ScavDrunk", function()
				DrawMaterialOverlay( "effects/water_warp01", 0.02 * self.Value )
				surface.SetDrawColor(0,255,0,3*(1+self.Value))
				surface.DrawRect(0,0,ScrW(),ScrH())
				local H = math.floor( ScrH() * 0.29*(1+self.Value) )

				DrawToyTown( 3, H )
			end )
		end
		self.Value = math.max(.5,self.Value - .125/(self.EndTime - self.StartTime)) --lessen effects over time
		self:NextThink(CurTime()+.125)
		return true
	end
--end
	
	function STATUS:Finish()
		if CLIENT then
			hook.Remove( "RenderScreenspaceEffects", "ScavDrunk")
		end
	end

	function STATUS:Add(duration,value)
		self.EndTime = self.EndTime+duration
		self.Value = self.Value+value
		if CLIENT then
			hook.Add( "RenderScreenspaceEffects", "ScavDrunk", function()
				DrawMaterialOverlay( "effects/water_warp01", 0.02 * self.Value )
				surface.SetDrawColor(0,255,0,3*(1+self.Value))
				surface.DrawRect(0,0,ScrW(),ScrH())
				local H = math.floor( ScrH() * 0.29*(1+self.Value) )

				DrawToyTown( 3, H )
			end )
		end
	end
	
	Status2.Register("Drunk",STATUS)
