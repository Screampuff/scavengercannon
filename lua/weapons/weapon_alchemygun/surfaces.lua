AddCSLuaFile()

--basic compositions
local alchmetal = {earth = 0.1,chem = 0.1,metal = 0.7,org = 0.1}
local alchearth = {earth = 0.7,chem = 0.1,metal = 0.1,org = 0.1}
local alchchem = {earth = 0.1,chem = 0.7,metal = 0.1,org = 0.1}
local alchorg = {earth = 0.1,chem = 0.1,metal = 0.1,org = 0.7}
local alchnone = {earth = 0.25,chem = 0.25,metal = 0.25,org = 0.25}
local alchplant = {earth = 0.4,chem = 0.1,metal = 0.1,org = 0.4}

local AlchSurfs = {}
AlchSurfs["baserock"]				= alchearth
AlchSurfs["boulder"]				= alchearth
AlchSurfs["brick"]					= alchearth
AlchSurfs["concrete"]				= alchearth
AlchSurfs["concrete_block"]			= alchearth
AlchSurfs["gravel"]					= alchearth
AlchSurfs["rock"]					= alchearth

AlchSurfs["slime"]					= alchorg
AlchSurfs["water"]					= alchorg
AlchSurfs["wade"]					= alchorg

AlchSurfs["canister"]              = alchmetal
AlchSurfs["chain"]                 = alchmetal
AlchSurfs["chainlink"]             = alchmetal
AlchSurfs["combine_metal"]         = alchmetal
AlchSurfs["crowbar"]               = alchmetal
AlchSurfs["floating_metal_barrel"] = alchmetal
AlchSurfs["grenade"]               = alchmetal
AlchSurfs["gunship"]               = alchmetal
AlchSurfs["metal"]                 = alchmetal
AlchSurfs["metal_barrel"]          = alchmetal
AlchSurfs["metal_bouncy"]          = alchmetal
AlchSurfs["metal_box"]             = alchmetal
AlchSurfs["metal_seafloorcar"]     = alchmetal
AlchSurfs["metalgrate"]            = alchmetal
AlchSurfs["metalpanel"]            = alchmetal
AlchSurfs["metalvent"]             = alchmetal
AlchSurfs["metalvehicle"]          = alchmetal
AlchSurfs["paintcan"]              = alchmetal
AlchSurfs["popcan"]                = alchmetal
AlchSurfs["roller"]                = alchmetal
AlchSurfs["slipperymetal"]         = alchmetal
AlchSurfs["solidmetal"]            = alchmetal
AlchSurfs["strider"]               = alchmetal
AlchSurfs["weapon"]                = alchmetal

AlchSurfs["brakingrubbertire"] = alchchem
AlchSurfs["cardboard"] = alchplant
AlchSurfs["carpet"] = alchplant
AlchSurfs["ceiling_tile"]  = alchearth
AlchSurfs["combine_glass"] = alchearth
AlchSurfs["computer"] = alchmetal
AlchSurfs["default"] = alchnone
AlchSurfs["default_silent"] = alchnone
AlchSurfs["floatingstandable"] = alchnone
AlchSurfs["glass"] = alchearth
AlchSurfs["glassbottle"] = alchearth
AlchSurfs["item"] = alchnone
AlchSurfs["jeeptire"] = alchchem
AlchSurfs["ladder"] = alchmetal
AlchSurfs["no_decal"] = alchnone
AlchSurfs["paper"] = alchplant
AlchSurfs["papercup"] = alchplant
AlchSurfs["plaster"] = alchchem
AlchSurfs["plastic_barrel"] = alchchem
AlchSurfs["plastic_barrel_buoyant"] = alchchem
AlchSurfs["plastic_box"] = alchchem
AlchSurfs["plastic"] = alchchem
AlchSurfs["player"] = alchorg
AlchSurfs["player_control_clip"] = alchnone
AlchSurfs["pottery"] = alchearth
AlchSurfs["porcelain"] = alchearth
AlchSurfs["rubber"] = alchchem
AlchSurfs["rubbertire"] = alchchem
AlchSurfs["slidingrubbertire"] = alchchem
AlchSurfs["slidingrubbertire_front"] = alchchem
AlchSurfs["slidingrubbertire_rear"] = alchchem

AlchSurfs["alienflesh"] = alchorg
AlchSurfs["antlion"] = alchorg
AlchSurfs["armorflesh"] = alchorg
AlchSurfs["bloodyflesh"] = alchorg
AlchSurfs["flesh"] = alchorg
AlchSurfs["foliage"] = alchorg
AlchSurfs["watermelon"] = alchorg
AlchSurfs["zombieflesh"] = alchorg

AlchSurfs["ice"] = alchorg
AlchSurfs["snow"] = alchorg

AlchSurfs["antlionsand"] = alchearth
AlchSurfs["dirt"] = alchearth
AlchSurfs["grass"] = alchorg
AlchSurfs["gravel"] = alchorg
AlchSurfs["mud"]  = alchearth
AlchSurfs["quicksand"]  = alchearth
AlchSurfs["sand"]  = alchearth
AlchSurfs["slipperyslime"]  = alchearth
AlchSurfs["tile"]  = alchearth

AlchSurfs["wood"] = alchorg
AlchSurfs["wood_box"] = alchorg
AlchSurfs["wood_crate"] = alchorg
AlchSurfs["wood_furniture"] = alchorg
AlchSurfs["wood_lowdensity"] = alchorg
AlchSurfs["wood_plank"] = alchorg
AlchSurfs["wood_panel"] = alchorg
AlchSurfs["wood_solid"] = alchorg

local propcache = {}

function SWEP:GetAlchemyInfo(model) //IMPORTANT!!! This function can be passed any model on the server, but if you are attempting to get info about a model on the client it must be precached on the server first!
	model = ScavData.FormatModelname(model)
	local cache = propcache[model] //if we have the model cached, we will return that
	if !cache then //if the model is not cached, we must gather the information about it by spawning an entity using that model and collecting the material from its physics object
		local prop
		if SERVER then
			prop = ents.Create("prop_physics") --would check all physics objects if it was a ragdoll prop, but there's no way to get ragdoll info on the client so we're just going to stay consistent
			prop:SetModel(model)
		else
			prop = ClientsideModel(model)
		end
		prop:PhysicsInit(SOLID_VPHYSICS)
		local phys = prop:GetPhysicsObject()
		if phys:IsValid() then
			propcache[model] = {
				["material"] = phys:GetMaterial(),
				["mass"] = phys:GetMass()
				}
		else
			propcache[model] = {
				["material"] = "default",
				["mass"] = 1
				}
		end
		prop:Remove()
		cache = propcache[model]
	end
	return cache
end

function SWEP:CheckForAlchemyInfo(model)
	return propcache[model]
end

function SWEP:GetSurfaceInfo(surf)
	return AlchSurfs[surf]||alchnone
end