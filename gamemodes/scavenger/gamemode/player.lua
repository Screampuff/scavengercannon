local PLAYER = FindMetaTable("Player")

function PLAYER:IsSpectator()
	return ((self:Team() == TEAM_SPECTATOR) or (self:Team() == TEAM_CONNECTING) or (not self:Alive() and (self:Lives() <= 0)))
end

--lives

function PLAYER:Lives()
	return self:GetNWInt("lives")
end

function PLAYER:AddLives(lives)
	self:SetLives(self:Lives()+lives)
end

function PLAYER:SetLives(lives)
	self:SetNWInt("lives",lives)
end

if SERVER then
	function GM:PlayerUse(pl,ent)
		return pl:Alive()
	end
	
	function GM:PlayerInitialSpawn(pl)
		gamemode.Call("PlayerJoinTeam",pl,TEAM_SPECTATOR)
		self:SendPlayerTeams(pl)
		pl:KillSilent()
	end

	function GM:PlayerSpawn(pl)
		if pl:Team() == TEAM_SPECTATOR then
			pl:SetMoveType(MOVETYPE_NOCLIP)
			pl:Spectate(OBS_MODE_ROAMING)
			pl:KillSilent()
			return true
		end
		pl:UnSpectate()
		gamemode.Call("PlayerLoadout",pl)
		gamemode.Call("PlayerSetModel",pl)
		umsg.Start("sdm_plmodel",pl)
			umsg.Entity(pl)
			umsg.String(pl:GetModel())
		umsg.End()
		pl:SetCharacterFromModel()
		pl:SetChargeRateDelayed(5,1)
		pl:SetEnergy(pl:GetMaxEnergy())
		pl:SetWalkSpeed(250)
		pl:SetRunSpeed(pl:GetWalkSpeed())
		pl:SetStepSize(24)
		pl:SetJumpPower(275)
	end
	
	function GM:PlayerCanSpawn(pl)
		if pl:Team() == TEAM_SPECTATOR then
			return false
		end
		local ctime = CurTime()
		local spawndelay = (pl.NextSpawnTime or 0)-ctime
		local usinglives = self:GetGNWVar("UseLives")
		return (spawndelay <= 0) and (not usinglives  or (pl:Lives()>0))
	end

	function GM:PlayerDeathThink(pl)
		if self:PlayerCanSpawn(pl) then
			if ( pl:KeyPressed( IN_ATTACK ) or pl:KeyPressed( IN_ATTACK2 ) or pl:KeyPressed( IN_JUMP ) ) then
				pl:Spawn()
			end
		end
	end
	
	
	function table.shuffle(tab)
		local sorttable = {}
		local newtab = {}
		if tab then
			for k,v in pairs(tab) do
				table.insert(sorttable,v)
			end
			for k,v in pairs(tab) do
				local maxvalues = #sorttable
				local randindex = math.random(1,maxvalues)
				table.insert(newtab,sorttable[randindex])
				table.remove(sorttable,randindex)
			end
		end
		return newtab
	end
	
	local spawnpoints
	
	function GM:GenerateSpawnPointList()
		spawnpoints = ents.FindByClass("info_sdm_spawn")
	end
	
	hook.Add("OnGLoaderSpawn","RefreshSpawnPoints",function()
		gamemode.Call("GenerateSpawnPointList")
	end)
	
	function GM:ShuffleSpawnPointList()
		spawnpoints = table.shuffle(spawnpoints)
	end
	
	function GM:PlayerSelectSpawn(pl)
		spawnpoints = table.shuffle(spawnpoints)
		for k,v in pairs(spawnpoints) do
			if v:PlayerCanSpawn(pl) then
				return v
			end
		end
		for k,v in pairs(spawnpoints) do
			v:SpawnFrag()
			return v
		end
		--MsgAll("WARNING! NO VALID SPAWN POINTS!")
	end
	
end

if CLIENT then
	usermessage.Hook("sdm_plmodel",function(um)
		local ent=um:ReadEntity()
		local model=um:ReadString()
		if IsValid(ent) then
			ent:SetModel(model)
		end
	end)
end


if SERVER then
	hook.Add("PlayerInitialSpawn","AddDashValues",function(pl)
		pl.LastDirection = 0
		pl.LastDirectionPress = 0
		pl.Dashing = false
		pl.DashHitGround = 0
		pl.LastAttack = 0
	end)
else
	hook.Add("InitPostEntity","AddDashValues",function()
		local pl = LocalPlayer()
		pl.LastDirection = 0
		pl.LastDirectionPress = 0
		pl.Dashing = false
		pl.DashHitGround = 0
		pl.LastAttack = 0
	end)
end


function GM:KeyRelease(pl,key)
	if pl:Alive() and ((key == IN_ATTACK) or (key == IN_ATTACK2)) and not pl:KeyDown(IN_ATTACK) and not pl:KeyDown(IN_ATTACK2)  then
		pl.Attacking = false
		pl.LastAttack = CurTime()
	end
--[[
	if pl:KeyDown(IN_FORWARD) or pl:KeyDown(IN_BACK) or pl:KeyDown(IN_MOVELEFT) or pl:KeyDown(IN_MOVERIGHT) then
		return
	end
	if (key == IN_FORWARD) or (key == IN_BACK) or (key == IN_MOVELEFT) or (key == IN_MOVERIGHT) then
		pl.LastDirectionRelease = CurTime()
		pl.LastDirection = key
	end
	]]
end

local dash_value = 500

function GM:KeyPress(pl,key)
	if CLIENT and not IsFirstTimePredicted() then
		return
	end
	if key == IN_SPEED then
		pl.NoSprintUntilNextSprintPress = false
	end
	if pl:Alive() and ((key == IN_ATTACK) or (key == IN_ATTACK2)) then
		pl.Attacking = true
	end
	if pl:Alive() and (key == IN_JUMP) and (pl:GetGroundEntity() ~= NULL) then
		--pl:PlaySDMSound("Jump",false,nil,true,true)
		pl:GetCharacter():HandleJump(pl)
	end
	--[[
	if pl.Dashing then
		return
	end
	local dashscale = CurTime()-pl.DashHitGround
	if (dashscale > 0.5) and (pl:GetGroundEntity() ~= NULL) and (CurTime()-pl.LastDirectionPress < 0.5) and (key == pl.LastDirection) then
		dashscale = math.Min(dashscale,1)
		pl:SetGroundEntity(NULL)
		--pl:SetVelocity(Vector(0,0,10000))
		if pl.LastDirection == IN_FORWARD then
			local vec = pl:GetForward()*dash_value*dashscale
			vec.z = 100
			pl:SetVelocity(vec)
		elseif pl.LastDirection == IN_BACK then
			local vec = pl:GetForward()*dash_value*-1*dashscale
			vec.z = 100
			pl:SetVelocity(vec)
		elseif pl.LastDirection == IN_MOVERIGHT then
			local vec = pl:GetRight()*dash_value*dashscale
			vec.z = 100
			pl:SetVelocity(vec)
		elseif pl.LastDirection == IN_MOVELEFT then
			local vec = pl:GetRight()*dash_value*-1*dashscale
			vec.z = 100
			pl:SetVelocity(vec)
		end
		]]
		--[[
		if CLIENT then
			print("CLIENT: "..tostring(pl)..", "..tostring(pl:GetPos())..", "..CurTime()..", "..tostring(pl:GetVelocity()))
		else
			print("SERVER: "..tostring(pl)..", "..tostring(pl:GetPos())..", "..CurTime()..", "..tostring(pl:GetVelocity()))
		end
		]]
		--[[
		gamemode.Call("DoAnimationEvent",pl,PLAYERANIMEVENT_JUMP)
		if SERVER then
			pl:EmitSound("player/suit_sprint.wav")
		end
		pl.Dashing = true
	end
	]]
	--if pl:KeyDown(IN_FORWARD) or pl:KeyDown(IN_BACK) or pl:KeyDown(IN_MOVELEFT) or pl:KeyDown(IN_MOVERIGHT) then
	--	return
	--end
	--[[
	if (key == IN_FORWARD) or (key == IN_BACK) or (key == IN_MOVELEFT) or (key == IN_MOVERIGHT) then
		pl.LastDirectionPress = CurTime()
		pl.LastDirection = key
	end
	]]
end


if CLIENT then
	function PLAYER:SetVelocity(vel)
		self.ClientVel = self.ClientVel or Vector()
		self.ClientVel = self.ClientVel+vel
	end
end

function GM:OnPlayerHitGround(pl,inwater,onfloater,fallspeed)
	if pl.Dashing then
		pl.Dashing = false
		pl.DashHitGround = CurTime()
	end
	if CLIENT then
		pl.landingtime = CurTime()
		pl.landingspeed = fallspeed
	end
end

function GM:Move(pl,movedata)
	--[[
	if CLIENT then
		if IsFirstTimePredicted() then
			pl.ClientVel2 = nil
		end
		if pl.ClientVel then
			pl.ClientVel2 = pl.ClientVel
			pl.ClientVel = nil
		end
		if pl.ClientVel2 then
			movedata:SetVelocity(movedata:GetVelocity()+pl.ClientVel2)
		end
	end
	local dashrecoverscale = CurTime()-pl.DashHitGround
	if dashrecoverscale < 1 then
		movedata:SetForwardSpeed(movedata:GetForwardSpeed()*dashrecoverscale)
		movedata:SetSideSpeed(movedata:GetSideSpeed()*dashrecoverscale)
	end
	movedata:SetConstraintRadius(2000)
	]]
	--movedata:SetMaxSpeed(2000)
	--movedata:SetMaxClientSpeed(2000)
	local scale = 1
	local wep = pl:GetActiveWeapon()
	local attacktime = 0
	if IsValid(wep) then
		attacktime = math.max(wep:GetNextPrimaryFire(),wep:GetNextSecondaryFire())
	end
	local ctime = CurTime()
	if pl:Alive() and not pl.NoSprintUntilNextSprintPress and pl:KeyDown(IN_SPEED) and (pl.sprinting or ((ctime-attacktime > 1) and not pl.Attacking)) and (pl:GetEnergy() > 20*FrameTime()) then
		if (pl:GetGroundEntity() ~= NULL) then
			if not pl.sprinting then
				if CLIENT then
					pl:EmitSound("player/suit_sprint.wav")
				end
				pl.sprinting = true
			end
			scale = scale*1.25
			pl:SetEnergy(pl:GetEnergy()-20*FrameTime())
		end
		if IsValid(wep) and (attacktime <= ctime) then
			wep:SetNextPrimaryFire(ctime+1)
			wep:SetNextSecondaryFire(ctime+1)
		end
	else
		if CLIENT and pl.sprinting then
			pl:EmitSound("player/suit_sprint.wav",100,52)
		end
		pl.NoSprintUntilNextSprintPress = true
		pl.sprinting = false
		
	end
	if scale ~= 1 then
		movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed()*scale)
		movedata:SetMaxSpeed(movedata:GetMaxSpeed()*scale)
		movedata:SetForwardSpeed(movedata:GetForwardSpeed()*scale)
		movedata:SetSideSpeed(movedata:GetSideSpeed()*scale)
		--movedata:SetVelocity(movedata:GetVelocity()*2)
	end
	return movedata
end

CreateClientConVar("sdm_footsteps_enabled",1,true,false)
function GM:PlayerFootstep(pl,pos,foot,sound,volume,rf)
	if SERVER then
		return pl:GetCharacter():HandleFootstep(pl,pos,foot,sound,volume,rf)
	else
		if GetConVarNumber("sdm_footsteps_enabled") == 0 then
			return true
		end
		return pl:GetCharacter():HandleFootstep(pl,pos,foot,sound,volume,rf)
		--[[
		if not pl.lastfoot then
			pl.lastfoot = 0
		end
		local model = ScavData.FormatModelname(pl:GetModel())
		local modeltype = PlayerModelTypes[model]
		local volbonus = 0

		pl.lastfoot = 1-pl.lastfoot
		if PlayerSounds[modeltype] then
			if (pl.lastfoot == 0) and PlayerSounds[modeltype].FootLeft then
				pl:PlaySDMSoundNoQueue("LeftFoot")
				return
			elseif PlayerSounds[modeltype].FootRight then
				pl:PlaySDMSoundNoQueue("RightFoot")
				return
			end
		end
		
		if pl == LocalPlayer() then
			volbonus = 10
		end

		if (model == "models/police.mdl") or (model == "models/player/police.mdl") or (model == "models/player/barney.mdl") then
			pl:EmitSound("npc/metropolice/gear"..math.random(1,3)+3*pl.lastfoot..".wav",30+volbonus)
		elseif modeltype == PLAYERMODEL_COMBINE then
			pl:EmitSound("npc/combine_soldier/gear"..math.random(1,3)+3*pl.lastfoot..".wav",37+volbonus)
		end
		if modeltype == PLAYERMODEL_ZOMBIE then
			--if (model == "models/player/zombie_soldier.mdl") then
			--	pl:EmitSound("npc/zombine/gear"..math.random(1,3)..".wav",36+volbonus)
			--else
				pl:EmitSound("npc/zombie/foot"..math.random(1,3)..".wav",50+volbonus)
			--end
		end
		]]
	end
	return true
end

if CLIENT then
	function GM:PlayerDeath(victim,killer,inflictor)
		timer.Simple(0.25, function() self.ScoreBoard:SortPlayerTeam(victim) end)
		if IsValid(killer) and killer:IsPlayer() then
			timer.Simple(0.25, function() self.ScoreBoard:SortPlayerTeam(killer) end)
		end
	end

	usermessage.Hook("GMPlayerDeath",function(um)
		local v = um:ReadEntity()
		local k = um:ReadEntity()
		local i = um:ReadEntity()
		gamemode.Call("PlayerDeath",v,k,i)
	end)

	function GM:PlayerDisconnectedTeam(teamid) --Called when a team loses a player to a disconnect
		teamid = tonumber(teamid)
		timer.Simple(0.25, function() self.ScoreBoard:ValidateTeam(teamid) end)
	end
	usermessage.Hook("GMPlayerDisconnectedTeam",function(um)
		local teamid = um:ReadShort()
		gamemode.Call("PlayerDisconnectedTeam",teamid)
	end)

	function GM:OnPlayerChangedTeam(pl,oldteam,newteam) 
		if IsValid(self.ScoreBoard) then
			timer.Simple(1, function() self.ScoreBoard:UpdatePlayerTeam(pl) end)
		end
	end
	usermessage.Hook("GMOnPlayerChangedTeam",function(um)
		local pl = um:ReadEntity()
		local oldteam = um:ReadShort()
		local newteam = um:ReadShort()
		gamemode.Call("OnPlayerChangedTeam",pl,oldteam,newteam)
	end)
else

	function GM:GetFallDamage(ply,vel)
		if self:GetGameVar("sdm_main_mod_falldmg") then
			local dmg = 0
			if vel > 700 then
				dmg = vel*0.05
			end
			return dmg
		end
	end
	
	function GM:PlayerTraceAttack(pl,dmginfo,dir,trace)
		if SERVER then
			gamemode.Call("ScalePlayerDamage",pl,trace.HitGroup,dmginfo) --this is a redundant call, the engine calls ScalePlayerDamage on its own
		end
		return true
	end
	
	function GM:ScalePlayerDamage(pl,hitgroup,dmginfo) 
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(2)
			if dmginfo:GetAttacker():IsPlayer() then
				umsg.Start("sdm_headshot",dmginfo:GetAttacker())
					umsg.Entity(pl)
					umsg.Vector(dmginfo:GetDamagePosition())
				umsg.End()
			end
		end
	end
	
	GM.ScaleNPCDamage = GM.ScalePlayerDamage

	function PLAYER:AddKills(amt)
		self:AddFrags(amt)
		self:AddScavStat(SCAVSTAT_FRAGS,amt)
		if GAMEMODE:GetMode() == SDM_MODE_DM_TEAM then
			local teamid = self:Team()
			team.AddScore(teamid,amt)
			local limit = team.GetScoreLimit(teamid)
			if (limit ~= 0) and (team.GetScore(teamid) >= limit) then
				GAMEMODE:EndRoundTeam(teamid)
			end
		elseif GAMEMODE:GetMode() == SDM_MODE_DM then
			local limit = team.GetScoreLimit(teamid)
			if (limit ~= 0) and (self:Frags() >= limit) then
				GAMEMODE:EndRoundPlayer(self)
			end
		end
	end
	

	function GM:PlayerDeathSound()
		return true
	end
	
	local lastframe = 0
	function GM:DoPlayerDeath(victim,attacker,dmginfo)
		local newframe = true
		local inflictor
		if CurTime() == lastframe then
			newframe = false
		else
			lastframe = CurTime()
		end
		if IsValid(victim.killedby) then
			attacker = victim.killedby
			dmginfo:SetAttacker(attacker)
		end
		if IsValid(victim.killedbyinflictor) then
			inflictor = victim.killedbyinflictor
			dmginfo:SetInflictor(inflictor)
		end	
		if not attacker.fragsthislife then
			attacker.fragsthislife = 0
		end
		local suicide = (attacker==victim)
		local friendlyfire = (attacker:IsPlayer() and (victim:Team()~=TEAM_UNASSIGNED) and (attacker:Team() == victim:Team()))
		victim.fragsthislife = 0
		victim:AddScavStat(SCAVSTAT_DEATHS,1)
		victim:AddDeaths(1)
		if not inflictor then
			inflictor = dmginfo:GetInflictor()
		end
		if (IsValid(attacker) and attacker:IsPlayer()) then

			if suicide then
				attacker:AddScavStat(SCAVSTAT_SUICIDES,1)
			end
			if suicide or friendlyfire then
				attacker:AddFrags(-1 )
			else
				attacker.fragsthislife = attacker.fragsthislife+1
				attacker:GetCharacter():HandleTaunt(attacker,victim,attacker.fragsthislife)
				--[[
				if attacker.fragsthislife%5 == 0 then
					--attacker:PlaySDMSound("KillingSpree")
				elseif math.random(1,4) == 1 then
					--attacker:PlaySDMSound("Taunt")
				end
				]]
				attacker:AddKills(1)
				if dmginfo:IsDamageType(DMG_BLAST) and IsValid(inflictor) then
					inflictor.BlastKills = (inflictor.BlastKills or 0)+1
					if inflictor.BlastKills > 2 then
						--attacker:AddScavAchievement(SCAVACHIEVEMENT_TRIPLEGIB,1)
					end
				end
			end

		end 
		if ((dmginfo:GetDamage() > 30) and dmginfo:IsExplosionDamage()) or (dmginfo:GetDamage() > 200) and not victim.nogib then
		--[[
			local edata = EffectData()
			edata:SetOrigin(victim:GetPos())
			edata:SetEntity(victim)
			edata:SetStart(dmginfo:GetDamageForce()/100)
			util.Effect("ef_playergib",edata)
			]]
			local gib = ents.Create("scav_gib")
			gib:SetOwner(victim)
			gib:Spawn()
		else
			--victim:PlaySDMSound("Death",true)
			victim:GetCharacter():HandleDeath(victim,attacker,dmginfo)
			victim:CreateRagdoll()
			--victim:Spectate(OBS_MODE_IN_EYE)
			--victim:SpectateEntity(victim:GetRagdollEntity())
		end
		--if IsValid(attacker) then
		--	victim:Spectate(OBS_MODE_DEATHCAM)
		--	victim:SpectateEntity(attacker)
		--end
		victim:SetMoveType(MOVETYPE_NONE)
	end
end

local function GetAheadPlayer(pl1,pl2)
	if pl1 == pl2 then
		return pl1
	end
	local f1 = pl1:Frags()
	local f2 = pl2:Frags()
	if f1 > f2 then --player one has more frags, return him
		return pl1
	elseif f2 > f1 then --player two has more frags, return him
		return pl2
	else --frags are tied, use deaths instead
		local d1 = pl1:Deaths()
		local d2 = pl2:Deaths()
		if d1 < d2 then --player one has fewer deaths, return him
			return pl1
		elseif d2 < d1 then --player two has fewer deaths, return him
			return pl2
		else --deaths are tied, use player indexes as a last resort to put a numerical place on a player
			if pl1:EntIndex() < pl2:EntIndex() then
				return pl1
			else
				return pl2
			end
		end
	end
end

local function GetBehindPlayer(pl1,pl2)
	if pl1 == pl2 then
		return pl1
	end
	local f1 = pl1:Frags()
	local f2 = pl2:Frags()
	if f1 > f2 then --player one has more frags, return the other player
		return pl2
	elseif f2 > f1 then --player two has more frags, return the other player
		return pl1
	else --frags are tied, use deaths instead
		local d1 = pl1:Deaths()
		local d2 = pl2:Deaths()
		if d1 < d2 then --player one has fewer deaths, return the other player
			return pl2
		elseif d2 < d1 then --player two has fewer deaths, return the other player
			return pl1
		else --deaths are tied, use player indexes as a last resort to put a numerical place on a player
			if pl1:EntIndex() < pl2:EntIndex() then
				return pl2
			else
				return pl1
			end
		end
	end
end

function PLAYER:SeekPlace() --meant to be called when the link has been broken
	local currentnext = self
	local currentprev = self
	for k,v in pairs(PLAYERS) do
		if GetAheadPlayer(self,v) == v then
			if GetBehindPlayer(v,currentnext) == v then
				currentnext = v
			end
		elseif GetBehindPlayer(self,v) == v then
			if GetAheadPlayer(v,currentprev) == v then
				currentprev = v
			end
		end
	end
	currentprev.place_next = self
	currentnext.place_previous = self
	self.place_next = currentnext
	self.place_previous = currentprev
end

function PLAYER:GetPlace(set)
	local place = 1
	local myfrags = self:GetFrags()
	for k,v in pairs(set) do
		if (v ~= self) and (v:Frags() >= myfrags) then
			if v:Frags() > myfrags then
				place = place+1
			elseif v:Deaths() <= self:Deaths() then --if frags are tied, check who has died less instead
				if v:Deaths() == self:Deaths() then
					if v:EntIndex() < self:EntIndex() then --if deaths are tied, check who has the first entindex
						place = place+1
					end
				end
			end
		end
	end
	return place
end

function player.GetByPlace()
	
end

if CLIENT then
	usermessage.Hook("sdm_headshot",function(um)
		local pl = um:ReadEntity()
		local pos = um:ReadVector()
		local edata = EffectData()
		edata:SetOrigin(pos)
		edata:SetEntity(pl)
		util.Effect("ef_sdm_headshot",edata)
	end)
end
