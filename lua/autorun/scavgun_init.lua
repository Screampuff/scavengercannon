AddCSLuaFile()

local refangle = Angle(0,0,0)
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

SCAV_SHORT_MAX = 32767

CreateClientConVar("cl_scav_high",0,true,false)

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
game.AddParticles("particles/scav_particles91.pcf")
game.AddParticles("particles/scav_weather.pcf")

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
	scav_cartridge = true,
	prop_combine_ball = true,
	prop_physics = true,
	prop_physics_respawnable = true,
	prop_physics_multiplayer = true,
	prop_ragdoll = true,
	helicopter_chunk = true,
	gib = true,
	scav_projectile_rocket = true,
	rpg_missile = true,
	phys_magnet = true,
	prop_ragdoll_attached = true,
	gmod_wire_hoverdrivecontroler = true,
	scav_projectile_comball = true,
	scav_projectile_arrow = true,
	scav_projectile_cannonball = true,
	scav_c4 = true,
	scav_tripmine = true,
	scav_proximity_mine = true,
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

	local ITEMFILE = "scavdata/knownitems.txt"
	local read = file.Read(ITEMFILE,"DATA")
	
	if read then
		knownmodels = util.JSONToTable(read)
	else
		knownmodels = {}
	end

	hook.Add("InitPostEntity","Scav_LoadKnownFiremodes",function()
	
		local PlayerID = util.CRC(LocalPlayer():SteamID())
		if not file.Exists(ITEMFILE,"DATA") then
			knownmodels.ID = PlayerID
		end
		
		if knownmodels.ID ~= PlayerID then
			print("Invalid firemode memory table, deleting file.")
			file.Delete(ITEMFILE)
			knownmodels = {["ID"] = PlayerID}
		end
		
	end)

	function ScavData.ProcessLocalPlayerItemKnowledge(modelname)
		if not knownmodels[modelname] and ScavData.models[modelname] then
			knownmodels[modelname] = true
			writestring = util.TableToJSON(knownmodels)
			file.Write(ITEMFILE,writestring)
		end
	end

	function ScavData.LocalPlayerKnowsItem(modelname)
		return knownmodels[modelname]
	end
	
	hook.Add("GravGunOnDropped","__GGEntDrop",function(pl,ent) if ent.OnGravGunDropped then ent:OnGravGunDropped(pl) end end)
	hook.Add("GravGunOnPickedUp","__GGEntPickup",function(pl,ent) if ent.OnGravGunPickup then ent:OnGravGunPickup(pl) end end)

end

/*=======================================================================*/
--		New Player methods
/*=======================================================================*/

if SERVER then

	local PLAYER = FindMetaTable("Player")
	
	function PLAYER:GetPlayerScavLevel()
		if self:IsAdmin() then
			return 9
		else
			return GetConVarNumber("scav_defaultlevel")
		end
	end
	
	function PLAYER:CanScavPickup(ent)
		if not IsValid(ent) then return end
		if GetConVarNumber("scav_pickupconstrained") == 0 and constraint.HasConstraints(ent) then
			return false
		end
		if GetConVarNumber("scav_propprotect") == 1 and ent.CPPIGetOwner and ent:CPPIGetOwner() and ent:CPPIGetOwner() ~= self then
			return false
		end
		if ent.CanScav or ((ScavData.OKClasses[ent:GetClass()] and (ent:GetMoveType() == MOVETYPE_VPHYSICS)) and not ent.NoScav) then return true end
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
			maxexpl = wep.dt.MaxExplosives
		end
		
		if #explosives >= maxexpl then
			explosives[1]:Explode()
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
			if v:IsValid() then
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
		if (GetConVarNumber("mp_teamplay") == 1 and pl:Team() == self:Team()) or pl == self then
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
	end
end