AddCSLuaFile()

local refangle = Angle(0,0,0)
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

SCAV_SHORT_MAX = 32767

CreateClientConVar("cl_scav_high",0,true,false,"Enable/disable Backup Pistol shot dynamic lighting",0,1)
CreateClientConVar("cl_scav_colorblindmode",0,true,true,"Enable/disable colorblindness assistance",0,1)

Scav_DisableTouchPickup2_weapons = {
	["weapon_crowbar"] = true,
	["weapon_stunstick"] = true,
	["weapon_physgun"] = true,
	["weapon_physcannon"] = true,
	["weapon_pistol"] = true,
	["weapon_357"] = true,
	["weapon_smg1"] = true,
	["weapon_ar2"] = true,
	["weapon_shotgun"] = true,
	["weapon_crossbow"] = true,
	["weapon_frag"] = true,
	["weapon_rpg"] = true,
	["weapon_slam"] = true,
	["weapon_bugbait"] = true,
	["gmod_tool"] = true,
	["gmod_camera" ] = true,
	["weapon_alyxgun"] = true,
	["weapon_annabelle"] = true,
	["weapon_oldmanharpoon"] = true,
	["weapon_citizenpackage"] = true,
	["weapon_citizensuitcase"] = true,
	["scav_gun"] = true,
	["weapon_blackholegun"] = true,
	["weapon_backuppistol"] = true,
	["weapon_alchemygun"] = true,
}

Scav_DisableTouchPickup2_items = {
	["item_healthkit"] = true,
	["item_healthvial"] = true,
	["item_grubnugget"] = true,
	["item_battery"] = true,
	["item_box_srounds"] = true,
	["item_ammo_pistol"] = true,
	["item_ammo_pistol_large"] = true,
	["item_ammo_357"] = true,
	["item_ammo_357_large"] = true,
	["item_box_mrounds"] = true,
	["item_ammo_smg1"] = true,
	["item_ammo_smg1_large"] = true,
	["item_ar2_grenade"] = true,
	["item_ammo_smg1_grenade"] = true,
	["item_box_lrounds"] = true,
	["item_ammo_ar2"] = true,
	["item_ammo_ar2_large"] = true,
	["item_ammo_ar2_altfire"] = true,
	["item_box_buckshot"] = true,
	["item_ammo_crossbow"] = true,
	["item_rpg_round"] = true,
}

ScavDropUsefulRagdoll_npcs = {
	["npc_poisonzombie"] = true, --disease shot collection
	["npc_headcrab_black"] = true, --disease shot
	["npc_headcrab_poison"] = true, --"
	["npc_alyx"] = true, --universal remote/Alyx gun (SMG)
	["npc_dog"] = true, --gravity gun
	["npc_vortigaunt"] = true, --vortigaunt beam
	["VortigauntUriah"] = true, --vortigaunt beam
	["VortigauntSlave"] = true, --vortigaunt beam
	["npc_antlionguard"] = true, --bugbait
	["npc_antlion_worker"] = true, --acid spit
	["npc_zombine"] = true, --grenade
	["npc_hunter"] = true, --flechettes
	["npc_stalker"] = true, --laser beam
	["npc_manhack"] = true, --buzzsaw
	["npc_helicopter"] = true, --helicopter gun
	["npc_combinegunship"] = true, --airboat gun
	["npc_strider"] = true, --strider cannon/minigun
	["monster_bullchicken"] = true, --bullsquid spit
	["monster_alien_controller"] = true, --controller balls
	["monster_human_grunt"] = true, --smg/shotgun
	["monster_houndeye"] = true, --supersonic shockwave
	["monster_scientist"] = true, --medkit
	["monster_barney"] = true, --pistol
	["monster_sentry"] = true, --auto-target rifle
	["monster_alien_grunt"] = true, --hornets
	["monster_alien_slave"] = true, --vortigaunt beam
	["monster_human_assassin"] = true, --cloak/silenced USPs
}
if SERVER then
	hook.Add("PlayerSpawn","Scav_JustSpawned",function(ply,transition)
		ply.JustSpawned = true
		timer.Simple(0.125,function() if IsValid(ply) then ply.JustSpawned = false end end)
	end)
end

local function SetupScavPickupOverrides(state)
	for i=1,game.MaxPlayers() do
		if IsValid(Entity(i)) then
			Entity(i).JustSpawned = false
			Entity(i).SWEPSpawned = "nil"
		end
	end
	if tonumber(state) < 2 then
		hook.Remove("PlayerCanPickupWeapon","Scav_DisableTouchPickup")
		hook.Remove("PlayerCanPickupItem","Scav_DisableTouchPickup")
		hook.Remove("PlayerSpawn","Scav_DisableTouchPickup")
		hook.Remove("PlayerGiveSWEP","Scav_DisableTouchPickup")
	elseif tonumber(state) < 3 then
		hook.Add("PlayerGiveSWEP","Scav_DisableTouchPickup",function(ply,weapon,sweptable) --stops checks from denying weapons from spawnmenu
			ply.SWEPSpawned = weapon
			timer.Simple(0,function() ply.SWEPSpawned = "nil" end)
		end)
		hook.Add("PlayerCanPickupWeapon","Scav_DisableTouchPickup", function(ply,weapon)
			if SERVER then
				if weapon:IsPlayerHolding() == false and --cheeky way to allow +USE to still let the player pick up the weapon normally
					ply.JustSpawned == false and
					ply.SWEPSpawned ~= wepname and
					Scav_DisableTouchPickup2_weapons[weapon:GetClass()] then
					return false
				end
			end
		end)
		hook.Add("PlayerCanPickupItem","Scav_DisableTouchPickup", function(ply,item)
			if SERVER then
				if item:IsPlayerHolding() == false and
					ply.JustSpawned == false and
					Scav_DisableTouchPickup2_items[item:GetClass()] then
					return false
				end
			end
		end)
	else
		hook.Add("PlayerGiveSWEP","Scav_DisableTouchPickup",function(ply,weapon,sweptable)
			ply.SWEPSpawned = weapon
			timer.Simple(0,function() ply.SWEPSpawned = "nil" end)
		end)
		hook.Add("PlayerCanPickupWeapon","Scav_DisableTouchPickup", function(ply,weapon)
			if SERVER then
				local wepname = weapon:GetClass()
				if weapon:IsPlayerHolding() == false and
					ply.JustSpawned == false and
					ply.SWEPSpawned ~= wepname and
					IsValid(weapon:GetPhysicsObject()) then --can't pick something up if it doesn't have a phys model, so don't prevent it.
					return false
				end
			end
		end)
		hook.Add("PlayerCanPickupItem","Scav_DisableTouchPickup", function(ply,item)
			if SERVER then
				--local itemname = item:GetClass()
				if item:IsPlayerHolding() == false and
					ply.JustSpawned == false and
					IsValid(item:GetPhysicsObject()) then --can't pick something up if it doesn't have a phys model, so don't prevent it.
					return false
				end
			end
		end)
	end
end

CreateConVar("scav_override_pickups",1,{FCVAR_NOTIFY,FCVAR_ARCHIVE},"Controls the entities that the Scavenger Cannon can pick up.\n1: Standard Behavior\n2: Disables picking up vanilla items/weapons when walking over them, allowing them to be picked up by the Scavenger Cannon instead\n3: Allows picking up vanilla vehicles. Disables picking up *all* items/weapons when walking over them. May not function as expected with other addons!",1,3)
CreateConVar("scav_force_holiday",0,{FCVAR_NOTIFY,FCVAR_ARCHIVE},"Override holiday date checking with this month (not all months have a holiday defined). 0 to disable override.",0,12)

cvars.AddChangeCallback("scav_override_pickups", function(convar, oldValue, newValue)
	SetupScavPickupOverrides(newValue)
end)

local function SetupScavRagdollOverrides(state)
	if tobool(state) then
		hook.Add("OnNPCKilled","ScavDropUsefulRagdoll",function(npc,attacker,inflictor)
			if npc:GetShouldServerRagdoll() then return end --we're already making a server ragdoll
			if ScavDropUsefulRagdoll_npcs[npc:GetClass()] then
				npc:SetShouldServerRagdoll(true)
			end
		end)
	else
		hook.Remove("OnNPCKilled","ScavDropUsefulRagdoll")
	end
end

CreateConVar("scav_force_usefulragdolls",0,{FCVAR_NOTIFY,FCVAR_ARCHIVE},"Force NPCs with unique firemode functions to drop solid ragdolls, regardless of ''Keep Corpses'' settings",0,1)

cvars.AddChangeCallback("scav_force_usefulragdolls", function(convar, oldValue, newValue)
	SetupScavRagdollOverrides(newValue)
end)

hook.Add("InitPostEntity","SetupScavPickupOverrides",function()
	local pickup = GetConVar("scav_override_pickups")
	local rag = GetConVar("scav_force_usefulragdolls")
	if pickup then
		SetupScavPickupOverrides(pickup:GetInt())
	end
	if rag then
		SetupScavRagdollOverrides(pickup:GetInt())
	end
end)

if CLIENT then
	surface.CreateFont("Scav_MenuLarge", {font = "Verdana", size = 15, weight = 600, antialias = true})
	surface.CreateFont("Scav_HUDNumber", {font = "Trebuchet MS", size = 40, weight = 900})	
	surface.CreateFont("Scav_HUDNumber3", {font = "Trebuchet MS", size = 43, weight = 900})
	surface.CreateFont("Scav_HUDNumber5", {font = "Trebuchet MS", size = 45, weight = 900})
	surface.CreateFont("Scav_ConsoleText", {font = "Lucida Console", size = 10, weight = 500})
	surface.CreateFont("Scav_DefaultSmallDropShadow", {font = "Tahoma", size = 11, weight = 0, shadow = true})
end

game.AddParticles("particles/scav_altguns4.pcf")
game.AddParticles("particles/scav_deaths.pcf")
game.AddParticles("particles/scav_muzzleflashes.pcf")
game.AddParticles("particles/scav_particles94.pcf")
game.AddParticles("particles/scav_weather.pcf")
game.AddParticles("particles/water_impacts.pcf") --blast shower
if IsMounted(440) then --TF2
	game.AddParticles("particles/medicgun_beam.pcf") --medigun
	game.AddParticles("particles/cinefx.pcf") --payload
	game.AddParticles("particles/flamethrower.pcf") --fireball
--	game.AddParticles("particles/teleport_status.pcf")
end
if IsMounted(400) then --portal 
--	game.AddParticles("particles/portalgun.pcf")
	game.AddParticles("particles/portal_projectile.pcf")
else
	game.AddParticles("particles/Rocket_Trail.pcf") --teleporter backup
end
--if IsMounted(300) then --DoD:S
--	game.AddParticles("particles/rockettrail.pcf") --MG42
--end

if not ScavData then 
	ScavData = {} --this table holds pretty much everything for the scavgun, it's much cleaner than using _G
end 

ScavData.Debug = {}
ScavData.models = {}

local modelnameformattable = {}
function ScavData.FormatModelname(modelname) --this function will take a modelname from entity:GetModel() and format it so the scavgun can use it
	if not modelnameformattable[modelname] then
		modelnameformattable[modelname] = string.gsub(string.lower(string.gsub(modelname,"%./","")),"\\","/")
	end
	return modelnameformattable[modelname]
end

if CLIENT then

	function ScavData.GetTracerShootPos(pl,defaultpos)
	
		if not IsValid(pl) then
			return defaultpos
		end
		
		if CLIENT and pl == GetViewEntity() then
			local vm = pl:GetViewModel()
			return vm:GetAttachment(vm:LookupAttachment("muzzle")).Pos
		else
			local wep = pl:GetActiveWeapon()
			return wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
		end
		
	end

end

--to keep the old guns happy
ScavData.OKClasses = {
	scav_cartridge = 1,
	prop_combine_ball = 1,
	prop_physics = 1,
	prop_physics_respawnable = 1,
	prop_physics_multiplayer = 1,
	simple_physics_prop = 1, --created by phys_convert
	prop_ragdoll = 1,
	helicopter_chunk = 1,
	gib = 1,
	scav_projectile_rocket = 1,
	rpg_missile = 1,
	apc_missile = 1,
	npc_grenade_frag = 1,
	npc_grenade_bugbait = 1,
	hunter_flechette = 1,
	phys_magnet = 1,
	prop_ragdoll_attached = 1,
	gmod_wire_hoverdrivecontroler = 1,
	scav_projectile_comball = 1,
	scav_projectile_arrow = 1,
	scav_projectile_cannonball = 1,
	scav_c4 = 1,
	scav_tripmine = 1,
	scav_proximity_mine = 1,
	npc_rollermine = 1, --can't leave corpses, so, gotta let them get taken here
	weapon_physgun = 2,
	weapon_physcannon = 2,
	weapon_crowbar = 2,
	weapon_stunstick = 2,
	weapon_pistol = 2,
	weapon_357 = 2,
	weapon_smg1 = 2,
	weapon_ar2 = 2,
	weapon_shotgun = 2,
	weapon_crossbow = 2,
	weapon_frag = 2,
	weapon_rpg = 2,
	weapon_slam = 2,
	weapon_bugbait = 2,
	gmod_tool = 2,
	gmod_camera = 2,
	weapon_alyxgun = 2,
	weapon_annabelle = 2,
	weapon_oldmanharpoon = 2,
	weapon_citizenpackage = 2,
	weapon_citizensuitcase = 2,
	scav_gun = 2,
	weapon_blackholegun = 2,
	weapon_backuppistol = 2,
	weapon_alchemygun = 2,
	item_item_crate = 2,
	item_healthkit = 2,
	item_healthvial = 2,
	item_grubnugget = 2,
	item_healthcharger = 2,
	item_battery = 2,
	item_suitcharger = 2,
	item_box_srounds = 2, --old entity name, can be seen in some HL2 maps
	item_ammo_pistol = 2,
	item_ammo_pistol_large = 2,
	item_ammo_357 = 2,
	item_ammo_357_large = 2,
	item_box_mrounds = 2, --old entity name, can be seen in some HL2 maps
	item_ammo_smg1 = 2,
	item_ammo_smg1_large = 2,
	item_ar2_grenade = 2, --old entity name, can be seen in some HL2 maps
	item_ammo_smg1_grenade = 2,
	grenade_ar2 = 2,
	item_box_lrounds = 2, --old entity name, can be seen in some HL2 maps
	item_ammo_ar2 = 2,
	item_ammo_ar2_large = 2,
	item_ammo_ar2_altfire = 2,
	item_box_buckshot = 2,
	item_ammo_crossbow = 2,
	item_rpg_round = 2,
	grenade_helicopter = 2,
	weapon_striderbuster = 2,
	npc_barnacle = 2, --can't leave corpses, so, gotta let them get taken here
	combine_mine = 2, --ditto
	scav_bounding_mine = 2, --ditto
	npc_turret_ceiling = 2, --ditto
	npc_combine_camera = 2, --ditto
	npc_turret_floor = 2, --ditto
	env_headcrabcanister = 2,
	prop_thumper = 2,
	prop_vehicle_jeep = 3,
	prop_vehicle_airboat = 3,
	prop_vehicle_apc = 3,
	func_physbox = 3, --I am scared, maggots
}

function ScavData.GetFiremode(modelname)
	return ScavData.models[modelname]
end

function ScavData.RegisterFiremode(tab,model)
	ScavData.models[ScavData.FormatModelname(model)] = tab
end

local teams = {}
teams["unassigned"] = 1001
teams["spectator"] = 1002
teams["red"] = 1003
teams["blue"] = 1004
teams["green"] = 1005
teams["yellow"] = 1006
teams["orange"] = 1007
teams["purple"] = 1008
teams["brown"] = 1009
teams["teal"] = 1010
	
function ScavData.ColorNameToTeam(colorname)

	if not colorname then
		error("Bad argument #1 to 'ColorNameToTeam'",2)
	end
	
	colorname = string.lower(colorname)
	
	local teamid = teams[colorname]
	
	if not teamid then
		teamid = TEAM_UNASSIGNED
		print("Warning! Bad team name "..tostring(colorname)..". Using \"unassigned\" instead")
	end
	
	return teamid
	
end
	
if SERVER then

	ScavData.CollectFuncs = {}
	
	local angoffset0_0_0 = Angle(0,0,0)
	local angoffset90_0_0 = Angle(90,0,0)

	local bd_tracetab = {}
	bd_tracetab.mask = MASK_SHOT
	local bd_opvec = Vector(0,0,0)
	bd_tracetab.endpos = bd_opvec
	local bd_vecs = {Vector(1,0,0),Vector(-1,0,0),Vector(0,1,0),Vector(0,-1,0),Vector(0,0,1),Vector(0,0,-1)}
		
	function ScavData.BlastDecals(decal,pos,radius) --creates decals in 6 directions. Kind of nasty but it does the job for medium-small explosions.
	
		bd_tracetab.start = pos
		
		for _,v in pairs(bd_vecs) do
		
			bd_opvec.x = pos.x + v.x * radius
			bd_opvec.y = pos.y + v.y * radius
			bd_opvec.z = pos.z + v.z * radius
			
			local tr = util.TraceLine(bd_tracetab)
			
			if tr.Hit then
				util.Decal(decal,pos,tr.HitPos-tr.HitNormal)
			end
			
		end
		
	end
		
	function ScavData.GetEntityFiringAngleOffset(ent) --entity must not have modified angles! also this is a shitty function why don't I know the real way to do this
	
		local mins = ent:OBBMins()
		local maxs = ent:OBBMaxs()
		local x = maxs.x-mins.x
		local y = maxs.y-mins.y
		local z = maxs.z-mins.z
		
		if z > y and z > x then --if the OBB is taller than it is wide
			return angoffset90_0_0
		end
		
		return angoffset0_0_0
		
	end
		
	function ScavData.DoBlastCalculation(position,radius,attacker,inflictor,callback) --callback should have: ent, position, radius, attacker, inflictor, fraction
		for _,v in ipairs(ents.FindInSphere(position,radius)) do
			callback(v,position,radius,attacker,inflictor,1 - (v:GetPos():Distance(position) / radius))
		end
	end

	function ScavData.GetNewInfoParticleSystem(particlesystemname,pos,parent)
	
		local ent = ents.Create("info_particle_system")

		ent:SetPos(pos)
		
		if parent then
			ent:SetParent(parent)
		end
		
		ent:SetKeyValue("effect_name", particlesystemname)
		ent:SetKeyValue("start_active","true")
		ent:Spawn()
		ent:Activate()
		ent:Fire("Start", nil, 0)
		
		return ent
		
	end

else

	net.Receive("scv_elc",function()
	
		local pos = net.ReadVector()
		local radius = net.ReadFloat()
		
		sound.Play("ambient/explosions/explode_7.wav", pos)
		
		local dlight = DynamicLight(0)
		
		if dlight then
			dlight.Pos = pos
			dlight.r = 100
			dlight.g = 100
			dlight.b = 255
			dlight.Brightness = 10
			dlight.Size = radius
			dlight.Decay = radius
			dlight.DieTime = CurTime() + 1
		end
		
	end)

	local ITEMDIR = "scavdata"
	local ITEMFILE = "knownitems.txt"
	local read = file.Read(ITEMDIR.."/"..ITEMFILE,"DATA")

	if read then
		knownmodels = util.JSONToTable(read)
	else
		knownmodels = {}
		if not file.Exists(ITEMDIR,"DATA") then
			file.CreateDir(ITEMDIR)
		end
	end

	hook.Add("InitPostEntity","Scav_LoadKnownFiremodes",function()
	
		local PlayerID = util.CRC(LocalPlayer():SteamID())
		if not file.Exists(ITEMDIR.."/"..ITEMFILE,"DATA") then
			knownmodels.ID = PlayerID
			local writestring = util.TableToJSON(knownmodels)
			file.Write(ITEMDIR.."/"..ITEMFILE,writestring)
		end

		if knownmodels.ID ~= PlayerID then
			print("Invalid firemode memory table, deleting file.")
			file.Delete(ITEMDIR.."/"..ITEMFILE)
			knownmodels = {["ID"] = PlayerID}
			local writestring = util.TableToJSON(knownmodels)
			file.Write(ITEMDIR.."/"..ITEMFILE,writestring)
		end
		
	end)

	function ScavData.ProcessLocalPlayerItemKnowledge(modelname)
		if not knownmodels[modelname] and ScavData.models[modelname] then
			knownmodels[modelname] = true
			table.sort(knownmodels)
			local writestring = util.TableToJSON(knownmodels)
			file.Write(ITEMDIR.."/"..ITEMFILE,writestring)
		end
	end

	function ScavData.LocalPlayerKnowsItem(modelname)
		return knownmodels[modelname]
	end
	
	hook.Add("GravGunOnDropped","__GGEntDrop",function(pl,ent) if ent.OnGravGunDropped then ent:OnGravGunDropped(pl) end end)
	hook.Add("GravGunOnPickedUp","__GGEntPickup",function(pl,ent) if ent.OnGravGunPickup then ent:OnGravGunPickup(pl) end end)

end

--[[=======================================================================]]--
--		New Player methods
--[[=======================================================================]]--

if SERVER then

	local PLAYER = FindMetaTable("Player")
	
	function PLAYER:GetPlayerScavLevel()
		if self:IsAdmin() then
			return 9
		else
			return GetConVar("scav_defaultlevel"):GetInt()
		end
	end
	
	function PLAYER:CanScavPickup(ent)
		if not IsValid(ent) then return end
		if GetConVar("scav_pickupconstrained"):GetInt() == 0 and constraint.HasConstraints(ent) then
			return false
		end
		if GetConVar("scav_propprotect"):GetInt() == 1 and ent.CPPIGetOwner and ent:CPPIGetOwner() and ent:CPPIGetOwner() ~= self then
			return false
		end
		if tobool(ent:GetInternalVariable("NoScav")) then
			return false
		end
		--print(ent:GetClass())
		if ent.CanScav or
		((ScavData.OKClasses[ent:GetClass()] ~= nil and GetConVar("scav_override_pickups"):GetInt() >= ScavData.OKClasses[ent:GetClass()]) or
		(GetConVar("scav_override_pickups"):GetInt() >= 3 and ent:IsWeapon())) and
		ent:GetMoveType() == MOVETYPE_VPHYSICS and not ent.NoScav then
			if ent:GetClass() == "npc_rollermine" and not ent:GetInternalVariable("m_bHackedByAlyx") then return false end
			return true
		end
	end
	
	local function NewViewPunch(angles,duration)
		local tab = {}
		tab.angle = angles
		tab.lifetime = duration
		tab.Created = UnPredictedCurTime()
		return tab	
	end
	
	util.AddNetworkString("scv_vwpnch")
	
	function PLAYER:ScavViewPunch(angles,duration,freeze)
	
		if not self.ScavViewPunches then
			self.ScavViewPunches = {}
		end
		
		local vp = NewViewPunch(angles,duration)
		
		table.insert(self.ScavViewPunches,vp)
		
		if not game.SinglePlayer() then return end
		
		net.Start("scv_vwpnch")
			net.WriteAngle(angles)
			net.WriteFloat(duration)
		net.Send(self)
		
	end

	local totalviewpunch = Angle()

	function PLAYER:GetCurrentScavViewPunch()
	
		if not self.ScavViewPunches then
			self.ScavViewPunches = {}
		end
		
		if self.LastScavViewPunchCalc == CurTime() then
			return self.LastScavVPAngle * 1
		end
		
		local angles = Angle(0,0,0)
		
		totalviewpunch.p = 0
		totalviewpunch.y = 0
		totalviewpunch.z = 0
		
		for k,v in pairs(self.ScavViewPunches) do
		
			if UnPredictedCurTime() - v.Created > v.lifetime then
				table.remove(self.ScavViewPunches,k)
			else
				local progress = math.Clamp((UnPredictedCurTime() - v.Created) / v.lifetime,0,1)
				local multiplier = math.sin(math.sqrt(progress) * math.pi)
				totalviewpunch.p = totalviewpunch.p + multiplier * v.angle.p
				totalviewpunch.y = totalviewpunch.y + multiplier * v.angle.y
				totalviewpunch.r = totalviewpunch.r + multiplier * v.angle.r
			end
			
		end
		
		totalviewpunch.p = math.Max(-90 - angles.p,totalviewpunch.p)
		totalviewpunch.p = math.Min(90 - angles.p,totalviewpunch.p)
		
		angles.p = angles.p + totalviewpunch.p
		angles.y = angles.y + totalviewpunch.y
		angles.r = angles.r + totalviewpunch.r
		
		self.LastScavVPAngle = angles * 1
		self.LastScavViewPunchCalc = CurTime()
		
		return angles
		
	end

	function PLAYER:GetScavExplosives()
		if not self.ScavExplosives then
			self.ScavExplosives = {}
		end
		return self.ScavExplosives
	end
	
	function PLAYER:AddScavExplosive(ent)
	
		local explosives = self:GetScavExplosives()
		
		self:CleanScavExplosives()
		
		local maxexpl = 6
		local wep = self:GetWeapon("scav_gun")
		
		if IsValid(wep) then
			maxexpl = wep:GetMaxExplosives()
		end
		
		if #explosives >= maxexpl then
			explosives[1].Explode = true
			--explosives[1]:Explode()
			table.remove(explosives,1)
		end
		
		table.insert(explosives,ent)
		
	end
		
	function PLAYER:CleanScavExplosives()
	
		local explosives = self:GetScavExplosives()
		local deadexplosives = {}
		
		for k,v in ipairs(explosives) do
			if not IsValid(v) then
				table.insert(deadexplosives,1,k)
			end
		end
		
		for _,v in ipairs(deadexplosives) do
			table.remove(explosives,v)
		end
		
	end
	
	function PLAYER:DetonateScavExplosives()
	
		local explosives = self:GetScavExplosives()
		
		for k,v in ipairs(explosives) do
			if IsValid(v) then
				v:Explode()
			end
		end
		
		for i=1,#explosives do
			table.remove(explosives,1)
		end
		
	end
	
	util.AddNetworkString("ent_emitsound")
		
	function PLAYER:EmitToAllButSelf(sound,vol,pitch)
	
		local vol = vol or 100
		local pitch = pitch or 100
		local rf = RecipientFilter()
		
		rf:AddAllPlayers()
		if not game.SinglePlayer() then
			rf:RemovePlayer(self)
		end
		
		net.Start("ent_emitsound")
			net.WriteEntity(self)
			net.WriteString(sound)
			net.WriteFloat(vol)
			net.WriteFloat(pitch)
		net.Send(rf)
		
	end
		
	PLAYER.MaxArmor = 100

	function PLAYER:SetMaxArmor(amt)
		if type(amt) == number then
			self.MaxArmor = amt
		end
	end

	function PLAYER:GetMaxArmor()
		return self.MaxArmor
	end
	
	util.AddNetworkString("scav_overlay")
	
	function PLAYER:SendHUDOverlay(color,duration)
		net.Start("scav_overlay")
			net.WriteColor(color)
			net.WriteFloat(duration)
		net.Send(self)
	end

end

if SERVER then
	util.AddNetworkString("scav_nwvar_e")
	util.AddNetworkString("scav_nwvar_f")
	util.AddNetworkString("scav_nwvar_s")
	util.AddNetworkString("scav_nwvar_b")
end

do

	local typetranslate = {}
	typetranslate["Player"] = function(ent,key,value) net.Start("scav_nwvar_e") net.WriteEntity(ent) net.WriteString(key) net.WriteEntity(value) net.Send(ent) end
	typetranslate["Entity"] = typetranslate["Player"]
	typetranslate["Weapon"] = typetranslate["Player"]
	typetranslate["number"] = function(ent,key,value) net.Start("scav_nwvar_f") net.WriteEntity(ent) net.WriteString(key) net.WriteFloat(value) net.Send(ent) end
	typetranslate["string"] = function(ent,key,value) net.Start("scav_nwvar_s") net.WriteEntity(ent) net.WriteString(key) net.WriteString(value) net.Send(ent) end
	typetranslate["boolean"] = function(ent,key,value) net.Start("scav_nwvar_b") net.WriteEntity(ent) net.WriteString(key) net.WriteBool(value) net.Send(ent) end
	
	net.Receive("scav_nwvar_e", function() local ent = net.ReadEntity() local key = net.ReadString() local value = net.ReadEntity() ent:SetScavNWVar(key,value) end)
	net.Receive("scav_nwvar_f", function() local ent = net.ReadEntity() local key = net.ReadString() local value = net.ReadFloat() ent:SetScavNWVar(key,value) end)
	net.Receive("scav_nwvar_s", function() local ent = net.ReadEntity() local key = net.ReadString() local value = net.ReadString() ent:SetScavNWVar(key,value) end)
	net.Receive("scav_nwvar_b", function() local ent = net.ReadEntity() local key = net.ReadString() local value = net.ReadBool() ent:SetScavNWVar(key,value) end)
	
	local PVSQueue = {}
	
	function ENTITY:SetScavNWVar(key,value) --maybe do something hacky where you add the PVS of an entity to the player when you set the value, ScavNWVars should be used sparingly
	
		if not self.ScavNWVars then
			self.ScavNWVars = {}
		end
		
		self.ScavNWVars[key] = value
		
		if SERVER then
			local pos = self:GetPos()
			table.insert(PVSQueue,pos)
			typetranslate[type(value)](self,key,value)			
		end
		
	end
	
	function ENTITY:GetScavNWVar(key)
		if not self.ScavNWVars then return end
		return self.ScavNWVars[key]
	end
	
	hook.Add("SetupPlayerVisibility","ScavNWVars",function(pl,viewent)
		for _,pl in ipairs(player.GetAll()) do
			for _,pos in ipairs(PVSQueue) do
				pl:AddOriginToPVS(pos)
			end
		end
		for k,v in pairs(PVSQueue) do
			PVSQueue[k] = nil
		end
	end)

end

PLAYER.GetProjectileShootPos = PLAYER.GetShootPos --for scav turret compatibility

local rmins = Vector()
local rmaxs = Vector()

function ScavData.SetRenderBoundsFromStartEnd(ent,startpos,endpos)
	rmins.x = math.min(startpos.x,endpos.x) - 100
	rmins.y = math.min(startpos.y,endpos.y) - 100
	rmins.z = math.min(startpos.z,endpos.z) - 100
	rmaxs.x = math.max(startpos.x,endpos.x) + 100
	rmaxs.y = math.max(startpos.y,endpos.y) + 100
	rmaxs.z = math.max(startpos.z,endpos.z) + 100
	ent:SetRenderBoundsWS(rmins,rmaxs)
end
	
function ScavData.SetRenderBoundsFromPoints(...)

	local args = {...}
	local ent = table.remove(args,1)
	
	rmins.x = args[1].x
	rmins.y = args[1].y
	rmins.z = args[1].z
	rmaxs.x = args[1].x
	rmaxs.y = args[1].y
	rmaxs.z = args[1].z
	
	for _,v in pairs(args) do
		if rmins.x > v.x then
			rmins.x = v.x
		end
		if rmins.y > v.y then
			rmins.y = v.y
		end
		if rmins.x > v.x then
			rmins.z = v.z
		end
		if rmaxs.x < v.x then
			rmaxs.x = v.x
		end
		if rmaxs.y < v.y then
			rmaxs.y = v.y
		end
		if rmaxs.x < v.x then
			rmaxs.z = v.z
		end
	end
	
	rmins.x = rmins.x - 100
	rmins.y = rmins.y - 100
	rmins.z = rmins.z - 100
	rmaxs.x = rmaxs.x + 100
	rmaxs.y = rmaxs.y + 100
	rmaxs.z = rmaxs.z + 100
	
	ent:SetRenderBoundsWS(rmins,rmaxs)

end

function PLAYER:ScavEmitSound(sound,vol,pitch)
	if SERVER then
		self:EmitToAllButSelf(sound,vol,pitch)
	else
		self:EmitSound(sound,vol,pitch)
	end
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:IsFriendlyToPlayer(pl)
	if self:IsPlayer() then
		if (GetConVar("mp_teamplay"):GetInt() == 1 and pl:Team() == self:Team()) or pl == self then
			return true
		else
			return false
		end
	elseif self:IsNPC() then
		if self:Disposition(pl) == D_LI or self:Disposition(pl) == D_NU then
			return true
		else
			return false
		end
	elseif self:IsNextBot() and self:GetClass() == "npc_zetaplayer" and _ZetasInstalled then
		if (self.IsFriendswith and self:IsFriendswith(pl)) or (self.IsInTeam and self:IsInTeam(pl)) then --Zeta compatibility
			return true
		else
			return false
		end
	else
		return false
	end
end
