-- Items whose primary purpose is granting other props to the gun

--[[==============================================================================================
	--Misc Goodies Giving
==============================================================================================]]--

--Radioactive/Biohazard Barrels
local tab = {}
	function tab.GetName(self, item)
		if (istable(item) and item:GetData() > 1 and item:GetData() < 7) or (not istable(item) and item > 1 and item < 7) then
			return "#scav.scavcan.disease"
		else
			return "#scav.scavcan.gammaray"
		end
	end
	tab.anim = ACT_VM_SECONDARYATTACK
	tab.Level = 4
	local identify = {} --both should return 0
	tab.Identify = setmetatable(identify, {__index = function() return 0 end})
	tab.MaxAmmo = 10 --luckily, both are ten
	tab.FireFunc = function(self, item)
		local tab = ScavData.models["models/props/de_train/barrel.mdl"]
		if (item.data > 1) and (item.data < 7) then
			tab.Cooldown = ScavData.models["models/props/de_train/biohazardtank.mdl"].Cooldown
			tab.anim = ScavData.models["models/props/de_train/biohazardtank.mdl"].anim
			if SERVER then --no clientside firefunction here
				return ScavData.models["models/props/de_train/biohazardtank.mdl"].FireFunc(self, item)
			else
				return true
			end
		else
			tab.Cooldown = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].Cooldown
			tab.anim = ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].anim
			return ScavData.models["models/props/de_nuke/nuclearcontainerboxclosed.mdl"].FireFunc(self, item)
		end
	end
	if SERVER then
		tab.OnArmed = function(self, item, olditemname)
			if (item.ammo ~= olditemname) and ((item.data < 2) or (item.data > 6)) then
				self.Owner:EmitSound("weapons/scav_gun/chargeup.wav")
			end
		end
		ScavData.CollectFuncs["models/props/de_train/barrel.mdl"] = function(self, ent)
			if (ent:GetSkin() > 1) and (ent:GetSkin() < 7) then
				return {{ScavData.FormatModelname(ent:GetModel()), 1, ent:GetSkin()}}
			else
				return {{ScavData.FormatModelname(ent:GetModel()), 10, ent:GetSkin()}}
			end
		end
		ScavData.CollectFuncs["models/props/de_train/pallet_barrels.mdl"] = function(self, ent) return {
			{ScavData.FormatModelname("models/props/de_train/barrel.mdl"), 4, math.random(2, 5)},
			{ScavData.FormatModelname("models/props/de_prodigy/wood_pallet_01.mdl"), 1, 0}
		} end
	end
	tab.Cooldown = 0.1
	ScavData.RegisterFiremode(tab, "models/props/de_train/barrel.mdl")

--Bonk/Crit-A-Cola
local tab = {}
	function tab.GetName(self, item)
		if (istable(item) and item:GetData() > 1) or (not istable(item) and item > 1) then
			return "#scav.scavcan.crit"
		else
			return "#scav.scavcan.stim"
		end
	end
	function tab.GetMaxAmmo(self, item)
		if (istable(item) and item:GetData() < 2) or (not istable(item) and item < 2) then
			return 6
		end
	end
	tab.anim = ACT_VM_IDLE
	tab.Level = 1
	tab.Identify = ScavData.models["models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"].Identify
	tab.FireFunc = function(self, item)
		local tab = ScavData.models["models/weapons/c_models/c_energy_drink/c_energy_drink.mdl"]
		if item.data > 1 then
			tab.Cooldown = ScavData.models["models/weapons/w_package.mdl"].Cooldown
			tab.anim = ScavData.models["models/weapons/w_package.mdl"].anim
			if SERVER then return ScavData.models["models/weapons/w_package.mdl"].FireFunc(self, item) end
		else
			tab.Cooldown = ScavData.models["models/items/powerup_speed.mdl"].Cooldown
			tab.anim = ScavData.models["models/items/powerup_speed.mdl"].anim
			if SERVER then return ScavData.models["models/items/powerup_speed.mdl"].FireFunc(self, item) end
		end
	end
	if SERVER then
		tab.OnArmed = function(self, item, olditemname)
			if item:GetData() < 2 then
				self.MaxAmmo = ScavData.models["models/items/powerup_speed.mdl"].MaxAmmo
			end
			self.Owner:EmitSound("player/pl_scout_dodge_can_open.wav")
		end
	end
	tab.Cooldown = 0.1
	ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl")

local tab = {}
	if SERVER then
		ScavData.CollectFuncs["models/items/ammopack_small.mdl"] = function(self, ent)
			return {{"models/weapons/shells/shell_shotgun.mdl", 2, 0},
					{"models/weapons/w_models/w_pistol.mdl", 12, 0, 1}}
		end
		ScavData.CollectFuncs["models/items/ammopack_small_bday.mdl"] = ScavData.CollectFuncs["models/items/ammopack_small.mdl"]
		ScavData.CollectFuncs["models/items/ammopack_medium.mdl"] = function(self, ent)
			return {{"models/weapons/shells/shell_shotgun.mdl", 4, 0},
					{"models/weapons/w_models/w_pistol.mdl", 24, 0}}
		end
		ScavData.CollectFuncs["models/items/ammopack_medium_bday.mdl"] = ScavData.CollectFuncs["models/items/ammopack_medium.mdl"]
		ScavData.CollectFuncs["models/items/ammopack_large.mdl"] = function(self, ent)
			return {{"models/weapons/w_models/w_rocket.mdl", 2, 0},
					{"models/weapons/w_models/w_minigun.mdl", 50, 0}}
		end
		ScavData.CollectFuncs["models/items/ammopack_large_bday.mdl"] = ScavData.CollectFuncs["models/items/ammopack_large.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"] = function(self, ent)
			return {{"models/props_c17/trappropeller_engine.mdl", 1, 0},
					{"models/props_vehicles/carparts_tire01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_axel01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_muffler01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_wheel01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_wheel01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_door01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_tire01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_axel01a.mdl", 1, 0},
					{"models/items/car_battery01.mdl", 20, 0}}
		end
		ScavData.CollectFuncs["models/props_vehicles/car001a_hatchback.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005b.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/vehicles/vehicle_van.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/truck003a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/truck001a.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/truck002a_cab.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car001b_phy.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car001a_phy.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car002b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car003b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car004b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/car005b_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a_nodoor.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/props_vehicles/van001a_nodoor_physics.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
		ScavData.CollectFuncs["models/vehicle.mdl"] = function(self, ent)
			return {{"models/vehicle/vehicle_engine_block.mdl", 1, 0},
					{"models/props_vehicles/carparts_tire01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_axel01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_muffler01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_wheel01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_wheel01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_tire01a.mdl", 1, 0},
					{"models/props_vehicles/carparts_axel01a.mdl", 1, 0},
					{"models/items/car_battery01.mdl", 20, 0}}
		end

	--Breaking up big cluster props into smaller ones

	--main reason for these zombie pickups is that we can't get the bodygroup in the gun, so we'll separate the headcrab if it's present
	ScavData.CollectFuncs["models/zombie/classic_torso.mdl"] = function(self, ent)
		local items = {{"models/zombie/classic_torso.mdl", 1, 0}}
		if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
			table.insert(items, {"models/headcrabclassic.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/zombie/classic.mdl"] = function(self, ent)
		local items = ScavData.CollectFuncs["models/zombie/classic_torso.mdl"](self, ent)
		table.insert(items, 2, {"models/zombie/classic_legs.mdl", 1, 0})
		return items
	end
	ScavData.CollectFuncs["models/zombie/fast_torso.mdl"] = function(self, ent)
		local items = {{"models/gibs/fast_zombie_torso.mdl", 1, 0}}
		if tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
			table.insert(items, {"models/headcrab.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/zombie/fast.mdl"] = function(self, ent)
		local items = ScavData.CollectFuncs["models/zombie/fast_torso.mdl"](self, ent)
		table.insert(items, 2, {"models/gibs/fast_zombie_legs.mdl", 1, 0})
		return items
	end
	--Black Mesa flipped these, headcrab's on 0 now
	ScavData.CollectFuncs["models/zombies/zombie_grunt_torso.mdl"] = function(self, ent)
		local items = {{"models/zombies/zombie_grunt_torso.mdl", 1, 0}}
		if not tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
			table.insert(items, {"models/xenians/headcrab.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/zombies/zombie_grunt.mdl"] = function(self, ent)
		local items = ScavData.CollectFuncs["models/zombies/zombie_grunt_torso.mdl"](self, ent)
		table.insert(items, 2, {"models/gibs/zombies/zombie_grunt/legs.mdl", 1, 0})
		return items
	end
	ScavData.CollectFuncs["models/player/mp_zombie_marine.mdl"] = ScavData.CollectFuncs["models/zombies/zombie_grunt.mdl"]
	ScavData.CollectFuncs["models/zombies/zombie_marine.mdl"] = ScavData.CollectFuncs["models/zombies/zombie_grunt.mdl"]

	ScavData.CollectFuncs["models/zombies/zombie_guard_torso.mdl"] = function(self, ent)
		local items = {{"models/zombies/zombie_guard_torso.mdl", 1, 0}}
		if not tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
			table.insert(items, {"models/xenians/headcrab.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/zombies/zombie_guard.mdl"] = function(self, ent)
		local items = ScavData.CollectFuncs["models/zombies/zombie_guard_torso.mdl"](self, ent)
		table.insert(items, 2, {"models/gibs/zombies/zombie_guard/legs.mdl", 1, 0})
		return items
	end
	ScavData.CollectFuncs["models/player/mp_zombie_guard.mdl"] = ScavData.CollectFuncs["models/zombies/zombie_guard.mdl"]

	ScavData.CollectFuncs["models/zombies/zombie_hev_torso.mdl"] = function(self, ent)
		local items = {{"models/zombies/zombie_hev_torso.mdl", 1, 0}}
		if not tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
			table.insert(items, {"models/xenians/headcrab.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/zombies/zombie_hev.mdl"] = function(self, ent)
		local items = ScavData.CollectFuncs["models/zombies/zombie_hev_torso.mdl"](self, ent)
		table.insert(items, 2, {"models/gibs/zombies/zombie_hev/legs.mdl", 1, 0})
		return items
	end
	ScavData.CollectFuncs["models/player/mp_zombie_sci.mdl"] = ScavData.CollectFuncs["models/zombies/zombie_sci.mdl"]

	ScavData.CollectFuncs["models/zombies/zombie_sci_torso.mdl"] = function(self, ent)
		local items = {{"models/zombies/zombie_sci_torso.mdl", 1, 0}}
		if not tobool(ent:GetBodygroup(ent:FindBodygroupByName("headcrab1"))) then
			table.insert(items, {"models/xenians/headcrab.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/zombies/zombie_sci.mdl"] = function(self, ent)
		local items = ScavData.CollectFuncs["models/zombies/zombie_sci_torso.mdl"](self, ent)
		table.insert(items, 2, {"models/gibs/zombies/zombie_sci/legs.mdl", 1, 0})
		return items
	end
	ScavData.CollectFuncs["models/player/mp_zombie_sci.mdl"] = ScavData.CollectFuncs["models/zombies/zombie_sci.mdl"]

	ScavData.CollectFuncs["models/props_junk/garbage128_composite001a.mdl"] = function(self, ent)
		local items = {
			{"models/props_junk/garbage_plasticbottle001a.mdl", 50, 0},
			{"models/props_junk/garbage_milkcarton002a.mdl", 1, 0},
			{"models/props_junk/garbage_metalcan001a.mdl", 1, 0},
			{"models/props_junk/garbage_syringeneedle001a.mdl", 1, 0, 3}
		}
		if L4D then
			table.insert(items, 3, {"models/props_junk/garbage_coffeecup01a.mdl", 1, 0})
			table.insert(items, 3, {"models/props_junk/garbage_spraypaintcan01a.mdl", 30, 0})
			table.insert(items, 3, {"models/props_junk/garbage_fastfoodcontainer01a.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/props_junk/garbage128_composite001b.mdl"] = function(self, ent)
		local items = {
			{"models/props_junk/garbage_metalcan002a.mdl", 1, 0},
			{"models/props_canal/mattpipe.mdl", 1, 0, 2},
			{"models/props_junk/garbage_glassbottle003a.mdl", 1, 0},
			{"models/props_junk/garbage_glassbottle002a.mdl", 1, 0},
			{"models/props_junk/garbage_metalcan001a.mdl", 1, 0},
			{"models/props_junk/garbage_syringeneedle001a.mdl", 1, 0}
		}
		if L4D then
			table.insert(items, 5, {"models/props_junk/garbage_fastfoodcontainer01a.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/props_junk/garbage128_composite001c.mdl"] = function(self, ent)
		local items = {
			{"models/props_junk/garbage_plasticbottle001a.mdl", 50, 0},
			{"models/props_junk/garbage_plasticbottle002a.mdl", 50, 0, 2},
			{"models/props_junk/garbage_milkcarton001a.mdl", 1, 0},
			{"models/props_junk/garbage_energydrinkcan001a.mdl", 1, 0, 3},
			{"models/props_junk/garbage_plasticbottle003a.mdl", 1, 0, 3},
			{"models/props_junk/garbage_metalcan002a.mdl", 1, 0},
			{"models/props_junk/garbage_metalcan001a.mdl", 1, 0, 2},
			{"models/props_junk/garbage_glassbottle003a.mdl", 1, 0}
		}
		if L4D then
			table.insert(items, 5, {"models/props_junk/garbage_coffeecup01a.mdl", 1, 0, 2})
		end
		return items
	end
	ScavData.CollectFuncs["models/props_junk/garbage128_composite001d.mdl"] = function(self, ent)
		local items = {
			{"models/props_junk/garbage_plasticbottle001a.mdl", 50, 0, 2},
			{"models/props_junk/garbage_plasticbottle002a.mdl", 50, 0},
			{"models/props_junk/garbage_milkcarton001a.mdl", 1, 0},
			{"models/props_junk/garbage_energydrinkcan001a.mdl", 1, 0, 3},
			{"models/props_junk/garbage_plasticbottle003a.mdl", 1, 0, 2}
		}
		if L4D then
			table.insert(items, 5, {"models/props_junk/garbage_coffeecup01a.mdl", 1, 0})
			table.insert(items, 5, {"models/props_junk/garbage_spraypaintcan01a.mdl", 30, 0, 2})
		end
		return items
	end
	ScavData.CollectFuncs["models/props_junk/garbage256_composite001a.mdl"] = function(self, ent)
		local items = {
			{"models/props_junk/garbage_metalcan002a.mdl", 1, 0, 3},
			{"models/props_junk/garbage_glassbottle003a.mdl", 1, 0, 2},
			{"models/props_vehicles/carparts_muffler01a.mdl", 1, 0},
			{"models/props_junk/garbage_syringeneedle001a.mdl", 1, 0},
			{"models/props_junk/garbage_energydrinkcan001a.mdl", 1, 0},
			{"models/props_junk/garbage_glassbottle002a.mdl", 1, 0}
		}
		if L4D then
			table.insert(items, 6, {"models/props_junk/garbage_spraypaintcan01a.mdl", 30, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/props_junk/garbage256_composite001b.mdl"] = function(self, ent)
		local items = {
			{"models/props_junk/garbage_metalcan002a.mdl", 1, 0, 3},
			{"models/props_junk/garbage_plasticbottle002a.mdl", 50, 0},
			{"models/props_junk/garbage_glassbottle003a.mdl", 1, 0, 2},
			{"models/props_junk/garbage_takeoutcarton001a.mdl", 1, 0},
			{"models/props_junk/garbage_syringeneedle001a.mdl", 1, 0},
			{"models/props_junk/garbage_plasticbottle003a.mdl", 1, 0},
			{"models/props_junk/garbage_glassbottle002a.mdl", 1, 0},
			{"models/props_junk/garbage_milkcarton002a.mdl", 1, 0}
		}
		if L4D then
			table.insert(items, 7, {"models/props_junk/garbage_coffeecup01a.mdl", 1, 0})
			table.insert(items, 7, {"models/props_junk/garbage_fastfoodcontainer01a.mdl", 1, 0, 2})
			table.insert(items, 7, {"models/props_junk/garbage_frenchfrycup01a.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/props_junk/garbage256_composite002a.mdl"] = function(self, ent)
		local items = {}
		for i=1, 4 do
			table.insert(models, {"models/props_junk/garbage_carboard00" .. tostring(math.Round(math.random(2))) .. "a.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/props_junk/garbage256_composite002b.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage256_composite002a.mdl"]
	ScavData.CollectFuncs["models/props_junk/ibeam01a_cluster01.mdl"] = function(self, ent) return {{"models/props_junk/ibeam01a.mdl", 1, 0, 4}} end
	ScavData.CollectFuncs["models/props_lab/securitybank.mdl"] = function(self, ent)
		return {{ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"), 8, 0, 2},
				{ScavData.FormatModelname("models/props_lab/powerbox02a.mdl"), 8, 0},
				{ScavData.FormatModelname("models/props_lab/citizenradio.mdl"), 10, 0, 2},
				{ScavData.FormatModelname("models/props_lab/monitor01b.mdl"), 1, 0, 4},
				{ScavData.FormatModelname("models/props_lab/monitor02.mdl"), 1, 0, 2},
				{ScavData.FormatModelname("models/props_lab/clipboard.mdl"), 1, 0},
				{ScavData.FormatModelname("models/props_c17/computer01_keyboard.mdl"), 1, 0},
				{ScavData.FormatModelname("models/props_lab/harddrive02.mdl"), SCAV_SHORT_MAX, 0}, -- only need one, they're infinite
				{ScavData.FormatModelname("models/props_wasteland/controlroom_desk001a.mdl"), 1, 0}}
	end
	ScavData.CollectFuncs["models/props_lab/servers.mdl"] = function(self, ent)
		return {{ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"), 8, 0, 2},
				{ScavData.FormatModelname("models/props_lab/citizenradio.mdl"), 10, 0, 2},
				{ScavData.FormatModelname("models/props_lab/monitor02.mdl"), 1, 0},
				{ScavData.FormatModelname("models/props_lab/monitor01b.mdl"), 1, 0, 4},
				{ScavData.FormatModelname("models/props_lab/clipboard.mdl"), 1, 0},
				{ScavData.FormatModelname("models/props_lab/harddrive02.mdl"), SCAV_SHORT_MAX, 0}, -- only need one, they're infinite
				{ScavData.FormatModelname("models/alyx_emptool_prop.mdl"), SCAV_SHORT_MAX, 0},
				{ScavData.FormatModelname("models/props_wasteland/kitchen_shelf001a.mdl"), 1, 0}}
	end
	ScavData.CollectFuncs["models/props_lab/workspace001.mdl"] = function(self, ent)
		return {{ScavData.FormatModelname("models/scav/rad_hl2.mdl"), 10, 0, 2},
				{ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"), 8, 0, 2},
				{ScavData.FormatModelname("models/props_lab/monitor02.mdl"), 1, 0, 3},
				{ScavData.FormatModelname("models/props_junk/plasticcrate01a.mdl"), 1, 2},
				{ScavData.FormatModelname("models/props_lab/harddrive02.mdl"), SCAV_SHORT_MAX, 0}, -- only need one, they're infinite
				{ScavData.FormatModelname("models/alyx_emptool_prop.mdl"), SCAV_SHORT_MAX, 0},
				{ScavData.FormatModelname("models/props_wasteland/cafeteria_table001a.mdl"), 1, 0}}
	end
	ScavData.CollectFuncs["models/props_lab/workspace002.mdl"] = function(self, ent)
		return {{ScavData.FormatModelname("models/props_c17/consolebox05a.mdl"), 8, 0, 3},
				{ScavData.FormatModelname("models/props_lab/citizenradio.mdl"), 10, 0, 2},
				{ScavData.FormatModelname("models/props_lab/monitor02.mdl"), 1, 0, 2},
				{ScavData.FormatModelname("models/props_lab/monitor01b.mdl"), 1, 0, 2},
				{ScavData.FormatModelname("models/props_lab/powerbox02b.mdl"), 8, 0},
				{ScavData.FormatModelname("models/props_lab/harddrive02.mdl"), SCAV_SHORT_MAX, 0}, -- only need one, they're infinite
				{ScavData.FormatModelname("models/props_wasteland/cafeteria_table001a.mdl"), 1, 0}}
	end
	ScavData.CollectFuncs["models/props_lab/workspace003.mdl"] = function(self, ent)
		return {{ScavData.FormatModelname("models/props_lab/monitor02.mdl"), 1, 0, 4},
				{ScavData.FormatModelname("models/props_lab/monitor01b.mdl"), 1, 0, 3},
				{ScavData.FormatModelname("models/props_lab/harddrive02.mdl"), SCAV_SHORT_MAX, 0}, -- only need one, they're infinite
				{ScavData.FormatModelname("models/props_wasteland/kitchen_shelf001a.mdl"), 1, 0, 2}}
	end
	ScavData.CollectFuncs["models/props_lab/workspace004.mdl"] = function(self, ent)
		return {{ScavData.FormatModelname("models/scav/rad_hl2.mdl"), 10, 0, 3},
				{ScavData.FormatModelname("models/props_lab/monitor02.mdl"), 1, 0, 4},
				{ScavData.FormatModelname("models/props_junk/plasticcrate01a.mdl"), 1, 2},
				{ScavData.FormatModelname("models/props_c17/computer01_keyboard.mdl"), 1, 0},
				{ScavData.FormatModelname("models/props_lab/harddrive02.mdl"), SCAV_SHORT_MAX, 0}, -- only need one, they're infinite
				{ScavData.FormatModelname("models/alyx_emptool_prop.mdl"), SCAV_SHORT_MAX, 0},
				{ScavData.FormatModelname("models/props_wasteland/cafeteria_table001a.mdl"), 1, 0}}
	end
	ScavData.CollectFuncs["models/props_silo/tirestack.mdl"] = function(self, ent)
		return {{"models/props_silo/tire1.mdl", 1, 0, 4},
				{CSS and "models/props/de_prodigy/wood_pallet_01.mdl" or "models/props_junk/wood_pallet001a.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/props_silo/tirestack2.mdl"] = function(self, ent)
		return {{"models/props_silo/tire2.mdl", 1, 0},
				{"models/props_silo/tire1.mdl", 1, 0, 3},
				{CSS and "models/props/de_prodigy/wood_pallet_01.mdl" or "models/props_junk/wood_pallet001a.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/props_silo/tirestack3.mdl"] = function(self, ent)
		return {{"models/props_silo/tire1.mdl", 1, 0, 2},
				{CSS and "models/props/de_prodigy/wood_pallet_01.mdl" or "models/props_junk/wood_pallet001a.mdl", 1, 0}}
	end
	--CSS
	ScavData.CollectFuncs["models/props/de_nuke/cinderblock_stack.mdl"] = function(self, ent) return {{"models/props_junk/CinderBlock01a.mdl", 1, 0, 11}} end
	ScavData.CollectFuncs["models/props/de_inferno/hay_bail_stack.mdl"] = function(self, ent) return {{"models/props/de_inferno/hay_bails.mdl", 1, 0, 15}} end
	ScavData.CollectFuncs["models/props/cs_militia/haybale_target.mdl"] = function(self, ent) return {{"models/props/de_inferno/hay_bails.mdl", 1, 0, 5}} end
	ScavData.CollectFuncs["models/props/cs_militia/haybale_target_02.mdl"] = function(self, ent) return {{"models/props/de_inferno/hay_bails.mdl", 1, 0, 4}} end
	ScavData.CollectFuncs["models/props/cs_militia/haybale_target_03.mdl"] = function(self, ent) return {{"models/props/de_inferno/hay_bails.mdl", 1, 0, 3}} end
	ScavData.CollectFuncs["models/props/de_prodigy/tirestack.mdl"] = function(self, ent)
		return {{"models/props/de_prodigy/tire1.mdl", 1, 0, 4},
				{"models/props/de_prodigy/wood_pallet_01.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/props/de_prodigy/tirestack2.mdl"] = function(self, ent)
		return {{"models/props/de_prodigy/tire2.mdl", 1, 0},
				{"models/props/de_prodigy/tire1.mdl", 1, 0, 3},
				{"models/props/de_prodigy/wood_pallet_01.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/props/de_prodigy/tirestack3.mdl"] = function(self, ent)
		return {{"models/props/de_prodigy/tire1.mdl", 1, 0, 2},
				{"models/props/de_prodigy/wood_pallet_01.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/props/cs_assault/box_stack1.mdl"] = function(self, ent)
		return {{"models/props/cs_assault/dryer_box.mdl", 1, 0, 5},
				{"models/props/cs_assault/washer_box2.mdl", 1, 0, 7}}
	end
	ScavData.CollectFuncs["models/props/cs_assault/box_stack2.mdl"] = function(self, ent)
		return {{"models/props/cs_assault/dryer_box.mdl", 1, 0, 3},
				{"models/props/cs_assault/washer_box.mdl", 1, 0},
				{"models/props/cs_assault/dryer_box2.mdl", 1, 0},
				{"models/props/cs_assault/washer_box2.mdl", 1, 0, 4}}
	end
	ScavData.CollectFuncs["models/props/cs_assault/moneypallet_washerdryer.mdl"] = function(self, ent)
		return {{"models/props/cs_assault/dryer_box.mdl", 1, 0},
				{"models/props/cs_assault/washer_box2.mdl", 1, 0, 2},
				{"models/props/cs_militia/dryer.mdl", 25, 0, 2},
				{"models/props/cs_assault/money.mdl", 1, 0, 5},
				{"models/props/de_prodigy/wood_pallet_01.mdl", 1, 0, 1}}
	end
	--TF2
	ScavData.CollectFuncs["models/props_2fort/tire002.mdl"] = function(self, ent) return {{"models/props_2fort/tire001.mdl", 1, 0, 5}} end
	ScavData.CollectFuncs["models/props_2fort/tire003.mdl"] = function(self, ent) return {{"models/props_2fort/tire001.mdl", 1, 0, 3}} end
	ScavData.CollectFuncs["models/props_2fort/trainwheel002.mdl"] = function(self, ent) return {{"models/props_2fort/trainwheel001.mdl", 1, 0, 5}} end
	ScavData.CollectFuncs["models/props_2fort/trainwheel003.mdl"] = function(self, ent) return {{"models/props_2fort/trainwheel001.mdl", 1, 0, 8}} end
	--L4D/2
	ScavData.CollectFuncs["models/props_unique/haybails_farmhouse.mdl"] = function(self, ent) return {{"models/props_unique/haybails_single.mdl", 1, 0, 20}} end
	ScavData.CollectFuncs["models/props_interiors/medicalcabinet02.mdl"] = function(self, ent) 
		local choice = math.Rand(0, 2)
		local num = math.Rand(1, 2)
		if choice < 1 then
			return {{"models/w_models/weapons/w_eq_medkit.mdl", math.Round(num), 0}}
		else
			return {{"models/w_models/weapons/w_eq_painpills.mdl", math.Round(num), 0}}
		end
	end
	--BMS
	ScavData.CollectFuncs["models/props_industrial/tirestack.mdl"] = ScavData.CollectFuncs["models/props_silo/tirestack.mdl"]
	ScavData.CollectFuncs["models/props_vehicles/jeep01.mdl"] = ScavData.CollectFuncs["models/props_vehicles/car001b_hatchback.mdl"]
	ScavData.CollectFuncs["models/props_vehicles/jeep01_phys.mdl"] = ScavData.CollectFuncs["models/props_vehicles/jeep01.mdl"]
	ScavData.CollectFuncs["models/props_vehicles/jeep02.mdl"] = ScavData.CollectFuncs["models/props_vehicles/jeep01.mdl"]
	ScavData.CollectFuncs["models/props_vehicles/jeep03.mdl"] = ScavData.CollectFuncs["models/props_vehicles/jeep01.mdl"]
	ScavData.CollectFuncs["models/props_vehicles/jeep01_burnt.mdl"] = ScavData.CollectFuncs["models/props_vehicles/jeep01.mdl"]
	ScavData.CollectFuncs["models/props_vehicles/jeep01_burnt_dynamic.mdl"] = ScavData.CollectFuncs["models/props_vehicles/jeep01_burnt.mdl"]
	ScavData.CollectFuncs["models/props_vehicles/jeep01_phys_burn.mdl"] = ScavData.CollectFuncs["models/props_vehicles/jeep01_burnt.mdl"]
	--CRATES
	ScavData.CollectFuncs["models/items/item_item_crate.mdl"] = function(self, ent) --some random HL2 supplies
		local supplies = {
			{"models/healthvial.mdl", 1, 0},
			{"models/items/battery.mdl", 1, 0},
			{"models/scav/nail.mdl", 15, 0},
			{"models/props_junk/metalgascan.mdl", 25, 0},
			{"models/props_junk/popcan01a.mdl", 1, 0},
			{"models/props_junk/shoe001a.mdl", 1, 0},
			{"models/props_junk/watermelon01.mdl", 1, 0},
			{"models/props_junk/glassjug01.mdl", 1, 0},
			{"models/props_junk/plasticbucket001a.mdl", 200, 0},
			{"models/props_lab/jar01a.mdl", 1, 0},
			{"models/props_lab/huladoll.mdl", 1, 0},
			{"models/props_combine/breenbust.mdl", 1, 0},
			{"models/props_c17/doll01.mdl", 1, 0},
			{"models/props_lab/tpplug.mdl", 100, 0},
			{"models/props_junk/metalbucket01a.mdl", 10, 0},
			{"models/scav/rad_hl2.mdl", 10, 0},
			{"models/props_junk/metal_paintcan001b.mdl", 30, 0},
			{"models/items/car_battery01.mdl", 25, 0},
			{"models/props_junk/garbage_coffeemug001a.mdl", 1, 0},
			{"models/weapons/w_stunbaton.mdl", 8, 0},
			{"models/weapons/w_pistol.mdl", 18, 0},
			{"models/weapons/w_357.mdl", 6, 0},
			{"models/weapons/w_smg1.mdl", 45, 0},
			{"models/items/ar2_grenade.mdl", 1, 0},
			{"models/weapons/w_irifle.mdl", 30, 0},
			{"models/items/combine_rifle_ammo01.mdl", 1, 0},
			{"models/weapons/shotgun_shell.mdl", 6, 0},
			{"models/props_trainstation/payphone_reciever001a.mdl", 6, 0},
			{"models/crossbow_bolt.mdl", 1, 0},
			{"models/weapons/w_grenade.mdl", 1, 0},
			{"models/weapons/rifleshell.mdl", 5, 0},
		}
		local items = {}
		if ScavData.FormatModelname(ent:GetModel()) == "models/items/item_item_crate.mdl" then
			if (self.Owner:Health() + self:PotentialHealing()) * 1.3 <= self.Owner:GetMaxHealth() then -- about 76% health or lower
				table.insert(items, {"models/items/healthkit.mdl", 1, 0})
			end
			if (self.Owner:Armor() + self:PotentialArmor()) * 3 <= self.Owner:GetMaxArmor() then
				table.insert(items, {"models/items/battery.mdl", 1, 0})
			end
			for i=1, math.random(3) do
				table.insert(items, supplies[math.random(#supplies)])
			end
		else --Pot of Greed allows you to draw two cards
			for i=1, 2 do
				table.insert(items, supplies[math.random(#supplies)])
			end
		end
		return items
	end
	ScavData.CollectFX["models/items/item_item_crate.mdl"] = function(self, ent)
		if ScavData.FormatModelname(ent:GetModel()) == "models/items/item_item_crate.mdl" then
			self.Owner:EmitSound("physics/wood/wood_box_break1.wav", 75, math.Rand(90, 120), 0.5)
		else --Pot of Greed allows you to draw two cards
			self.Owner:EmitSound("weapons/scav_gun/drawtwocards.wav", 75)
		end
	end
	ScavDataCollectCopy("models/props_c17/pottery01a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery02a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery03a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery04a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery05a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery06a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery07a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery08a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery09a.mdl", "models/items/item_item_crate.mdl")
	ScavDataCollectCopy("models/props_c17/pottery_large01a.mdl", "models/items/item_item_crate.mdl")
	ScavData.CollectFuncs["models/items/item_beacon_crate.mdl"] = function(self, ent) --some random Episodic supplies
		local supplies = {
			--{"models/healthvial.mdl", 1, 0},
			{"models/items/battery.mdl", 1, 0},
			{"models/scav/nail.mdl", 15, 0},
			{"models/props_junk/metalgascan.mdl", 25, 0},
			--{"models/props_junk/popcan01a.mdl", 1, 0},
			{"models/props_junk/shoe001a.mdl", 1, 0},
			{"models/props_junk/watermelon01.mdl", 1, 0},
			{"models/props_junk/glassjug01.mdl", 1, 0},
			{"models/props_junk/plasticbucket001a.mdl", 200, 0},
			--{"models/props_lab/jar01a.mdl", 1, 0},
			--{"models/props_lab/huladoll.mdl", 1, 0},
			{"models/props_combine/breenbust.mdl", 1, 0},
			--{"models/props_c17/doll01.mdl", 1, 0},
			{"models/props_lab/tpplug.mdl", 100, 0},
			{"models/props_junk/metalbucket01a.mdl", 10, 0},
			{"models/scav/rad_hl2.mdl", 10, 0},
			{"models/props_junk/metal_paintcan001b.mdl", 30, 0},
			--{"models/items/car_battery01.mdl", 25, 0},
			{"models/props_junk/garbage_coffeemug001a.mdl", 1, 0},
			--{"models/weapons/w_stunbaton.mdl", 8, 0},
			{"models/weapons/w_pistol.mdl", 18, 0},
			{"models/weapons/w_357.mdl", 6, 0},
			{"models/weapons/w_smg1.mdl", 45, 0},
			{"models/items/ar2_grenade.mdl", 1, 0},
			{"models/weapons/w_irifle.mdl", 30, 0},
			{"models/items/combine_rifle_ammo01.mdl", 1, 0},
			{"models/weapons/shotgun_shell.mdl", 6, 0},
			{"models/props_trainstation/payphone_reciever001a.mdl", 6, 0},
			{"models/crossbow_bolt.mdl", 1, 0},
			{"models/weapons/w_grenade.mdl", 1, 0},
			{"models/weapons/w_combine_sniper.mdl", 5, 0},
			--Ep2 stuff
			{"models/magnusson_device.mdl", 1, 0},
			{"models/props_junk/flare.mdl", 1, 0},
			{"models/props_mining/railroad_spike01.mdl", 1, 0},
			{"models/weapons/hunter_flechette.mdl", 25, 0},
			{"models/props_silo/acunit02.mdl", 50, 0},
			{"models/grub_nugget_large.mdl", 1, 0},
			{"models/props_forest/stove01.mdl", 20, 0},
		}
		local items = {}
		if (self.Owner:Health() + self:PotentialHealing()) * 1.3 <= self.Owner:GetMaxHealth() then -- about 76% health or lower
			table.insert(items, {"models/items/healthkit.mdl", 1, 0})
		end
		if (self.Owner:Armor() + self:PotentialArmor()) * 3 <= self.Owner:GetMaxArmor() then
			table.insert(items, {"models/items/battery.mdl", 1, 0})
		end
		for i=1, math.random(3) do
			table.insert(items, supplies[math.random(#supplies)])
		end
		return items
	end
	ScavData.CollectFX["models/items/item_beacon_crate.mdl"] = function(self, ent)
		self.Owner:EmitSound("vehicles/junker/radar_ping_friendly1.wav", 75, 100, 0.5)
	end
	ScavData.CollectFuncs["models/props_halloween/halloween_gift.mdl"] = function(self, ent) --some random TF2 supplies
		local teamskin = math.random(0, 1)
		local supplies = {
			{"models/items/medkit_small.mdl", 1, 0},
			{"models/weapons/c_models/c_sandwich/c_sandwich.mdl", 1, 0},
			{"models/scav/nail.mdl", 25, 0},
			{"models/props_farm/oilcan01.mdl", 25, 0},
			{"models/weapons/w_models/w_grenade_grenadelauncher.mdl", 4, teamskin},
			{"models/weapons/w_models/w_flaregun_shell.mdl", 3, teamskin},
			{"models/props_gameplay/pill_bottle01.mdl", 1, 0},
			{"models/weapons/c_models/c_flameball/c_flameball.mdl", 20, teamskin},
			{"models/weapons/w_models/w_rocket.mdl", 4, 0},
			{"models/weapons/c_models/urinejar.mdl", 1, 0},
			{"models/weapons/w_models/w_repair_claw.mdl", 4, 0},
			{"models/buildables/sentry1.mdl", 100, teamskin},
			{"models/weapons/w_models/w_stickybomb.mdl", 3, teamskin},
			{"models/props_2fort/fire_extinguisher.mdl", 100, 0},
			{"models/props_2fort/sink001.mdl", 25, 0},
			{"models/props_badlands/barrel03.mdl", 10, 0},
			{"models/weapons/c_models/c_spy_watch.mdl", 30, 0},
			{"models/flag/briefcase.mdl", 1, teamskin},
			{"models/weapons/c_models/c_energy_drink/c_energy_drink.mdl", 1, teamskin},
			{"models/weapons/c_models/c_sapper/c_sapper.mdl", 8, 0},
			{"models/weapons/c_models/c_pistol/c_pistol.mdl", 12, 0},
			{"models/weapons/c_models/c_revolver/c_revolver.mdl", 6, 0},
			{"models/weapons/c_models/c_smg/c_smg.mdl", 25, 0},
			{"models/weapons/c_models/c_claymore/c_claymore.mdl", 1, 0},
			{"models/weapons/c_models/c_minigun/c_minigun.mdl", 200, 0},
			{"models/props_trainyard/cart_bomb_separate.mdl", 1, 0},
			{"models/weapons/shells/shell_shotgun.mdl", 6, 0},
			{"models/props_2fort/telephone001.mdl", 6, 0},
			{"models/weapons/w_models/w_arrow.mdl", 3, 0},
			{"models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", 200, teamskin},
			{"models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl", 25, 0},
		}
		local items = {}
		if ScavData.FormatModelname(ent:GetModel()) ~= "models/props_manor/vase_01.mdl" then
			if (self.Owner:Health() + self:PotentialHealing()) * 1.3 <= self.Owner:GetMaxHealth() then -- about 76% health or lower
				table.insert(items, {"models/items/medkit_small.mdl", 1, 0})
			end
			if (self.Owner:Armor() + self:PotentialArmor()) * 3  <= self.Owner:GetMaxArmor() then
				table.insert(items, {"models/pickups/pickup_powerup_defense.mdl", 1, 0})
			end
			for i=0, math.random(3) do
				table.insert(items, supplies[math.random(#supplies)])
			end
		else
			for i=1, 2 do
				table.insert(items, supplies[math.random(#supplies)])
			end
		end
		return items
	end
	ScavData.CollectFX["models/props_halloween/halloween_gift.mdl"] = function(self, ent) --some random TF2 supplies
		if ScavData.FormatModelname(ent:GetModel()) ~= "models/props_manor/vase_01.mdl" then
			if ent:GetModel() == "models/props_halloween/halloween_gift.mdl" or
				ent:GetModel() == "models/items/tf_gift.mdl" then
				self.Owner:EmitSound("items/gift_drop.wav", 75, 100, 0.5)
			else
				self.Owner:EmitSound("items/regenerate.wav", 75, 100, 0.5)
			end
		else
			self.Owner:EmitSound("weapons/scav_gun/drawtwocards.wav", 75)
		end
	end
	ScavDataCollectCopy("models/props_gameplay/resupply_locker.mdl", "models/props_halloween/halloween_gift.mdl")
	ScavDataCollectCopy("models/props_medieval/medieval_resupply.mdl", "models/props_halloween/halloween_gift.mdl")
	ScavDataCollectCopy("models/items/tf_gift.mdl", "models/props_halloween/halloween_gift.mdl")
	ScavDataCollectCopy("models/props_manor/vase_01.mdl", "models/props_halloween/halloween_gift.mdl")
	--HL1 Crate
	ScavData.CollectFuncs["models/mp/crate.mdl"] = function(self, ent)
		local supplies = {
			{"models/w_medkit.mdl", 1, 0},
			{"models/w_battery.mdl", 1, 0},
			{"models/w_9mmhandgun.mdl", 17, 0},
			{"models/w_silencer.mdl", 17, 0},
			{"models/w_357.mdl", 6, 0},
			{"models/w_9mmar.mdl", 25, 0},
			{"models/grenade.mdl", 2, 0},
			{"models/shotgunshell.mdl", 8, 0},
			{"models/w_grenade.mdl", 5, 0},
			{"models/rpgrocket.mdl", 3, 0},
			{"models/w_tripmine.mdl", 1, 0},
			{"models/w_satchel.mdl", 1, 0},
			{"models/w_hgun.mdl", 50, 0},
			{"models/hassassin.mdl", 30, 0},
			{"models/w_gaussammo.mdl", 10, 0},
			{"models/w_flare.mdl", 1, 0},
		}
		local items = {}
		if (self.Owner:Health() + self:PotentialHealing()) * 1.3 <= self.Owner:GetMaxHealth() then -- about 76% health or lower
			table.insert(items, {"models/w_medkit.mdl", 1, 0})
		end
		if (self.Owner:Armor() + self:PotentialArmor()) * 3  <= self.Owner:GetMaxArmor() then
			table.insert(items, {"models/w_battery.mdl", 1, 0})
		end
		for i=0, math.random(3) do
			table.insert(items, supplies[math.random(#supplies)])
		end
		return items
	end
	--BMS Crate
	ScavData.CollectFuncs["models/props_generic/bm_supplycrate01.mdl"] = function(self, ent)
		local supplies = {
			{"models/weapons/w_medkit_classic.mdl", 1, 0},
			{"models/weapons/w_medkit_stiff.mdl", 1, 0},
			{"models/weapons/w_battery.mdl", 1, 0},
			{"models/weapons/w_glock.mdl", 17, 0},
			{"models/weapons/w_357_mp.mdl", 6, 0},
			{"models/weapons/w_mp5.mdl", 25, 0},
			{"models/weapons/w_argrenade.mdl", 1, 0},
			{"models/weapons/w_shotgun_mp.mdl", 8, 0},
			{"models/weapons/w_grenade_mp.mdl", 5, 0},
			{"models/weapons/w_rpg_projectile.mdl", 3, 0},
			{"models/weapons/w_tripmine.mdl", 1, 0},
			{"models/weapons/w_satchel.mdl", 1, 0},
			{"models/weapons/w_hgun.mdl", 50, 0},
			{"models/props_junk/spraycan.mdl", 30, 0},
			{"models/weapons/w_gaussammo.mdl", 10, 0},
			{"models/props_junk/flare.mdl", 1, 0},
			{"models/props_equipment/portablebattery01.mdl", 100, 0},
			{"models/props_generic/bm_batteryradio01.mdl", 10, 0},
			{"models/props_generic/safetyshower.mdl", 30, 0},
			{"models/props_junk/coffeemug01a.mdl", 1, 0},
			{"models/props_questionableethics/smoking_boots_right.mdl", 1, 0},
			{"models/props_canteen/spork.mdl", 1, 0},
			{"models/props_junk/pen.mdl", 1, 0},
			{"models/weapons/crossbow_bolt.mdl", 1, 0},
			{"models/props_industrial/gascanister01.mdl", 50, 0},
			{"models/props_generic/plant_office.mdl", 1, 0},
			{"models/props_canteen/donutbox.mdl", 1, 0},
			{"models/props_canteen/pizza_box.mdl", 1, 0},
			{"models/props_canteen/taco.mdl", 1, 0},
		}
		local items = {}
		if (self.Owner:Health() + self:PotentialHealing()) * 1.3 <= self.Owner:GetMaxHealth() then -- about 76% health or lower
			table.insert(items, {math.random(2) == 1 and "models/weapons/w_medkit_classic.mdl" or "models/weapons/w_medkit_stiff.mdl", 1, 0})
		end
		if (self.Owner:Armor() + self:PotentialArmor()) * 3  <= self.Owner:GetMaxArmor() then
			table.insert(items, {"models/weapons/w_battery.mdl", 1, 0})
		end
		for i=0, math.random(3) do
			table.insert(items, supplies[math.random(#supplies)])
		end
		return items
	end
	ScavDataCollectCopy("models/props_generic/bm_supplycrate01a_box.mdl", "models/props_generic/bm_supplycrate01.mdl")
	ScavDataCollectCopy("models/items/xen_supplypod01a.mdl", "models/props_generic/bm_supplycrate01.mdl")
	ScavDataCollectCopy("models/items/xen_supplypod01a_p1.mdl", "models/props_generic/bm_supplycrate01.mdl")
	ScavDataCollectCopy("models/items/xen_supplypod01b_p1.mdl", "models/props_generic/bm_supplycrate01.mdl")
	ScavDataCollectCopy("models/items/xen_supplypod01c_p1.mdl", "models/props_generic/bm_supplycrate01.mdl")
	--L4D2 Gift
	--Portal Cake (isn't solid :c)
	--Make HL2 Oil Drums sometimes provide Radioactive/BioHazard Barrel Firemodes?
	
	--Uniform Locker (give us three random classes' stuff)
	ScavData.CollectFuncs["models/props_gameplay/uniform_locker.mdl"] = function(self, ent)
		local classpick = {
			"models/player/scout.mdl",
			"models/player/soldier.mdl",
			"models/player/pyro.mdl",
			"models/player/demo.mdl",
			"models/player/heavy.mdl",
			"models/player/engineer.mdl",
			"models/player/medic.mdl",
			"models/player/sniper.mdl",
			"models/player/spy.mdl"
		}
		local items = {}
		for i=1, 3 do
			class = classpick[math.random(#classpick)]
			classitems = ScavData.CollectFuncs[class](self, ent)
			for i=1, #classitems do
				table.insert(items, classitems[i])
			end
		end
		return items
	end
	
	--Poopy Joe's Locker
	ScavData.CollectFuncs["models/props_gameplay/uniform_locker_pj.mdl"] = function(self, ent)
		return {{"models/weapons/c_models/c_bugle/c_bugle.mdl", 10, 0},
				{"models/weapons/c_models/c_claymore/c_claymore.mdl", 1, 0},
				{"models/weapons/c_models/c_pickaxe/c_pickaxe.mdl", 1, 0},
				{FOF and "models/elpaso/horse_poo.mdl" or "models/weapons/c_models/urinejar.mdl", 1, 0}}
	end

	--precache helps with the hiccup of initially sucking the mercs/locker up
	if TF2 then
		util.PrecacheModel("models/weapons/c_models/c_scattergun.mdl")
		util.PrecacheModel("models/weapons/c_models/c_shotgun/c_shotgun.mdl")
		util.PrecacheModel("models/weapons/w_models/w_pistol.mdl")
		util.PrecacheModel("models/weapons/c_models/c_energy_drink/c_energy_drink.mdl")
		util.PrecacheModel("models/weapons/w_models/w_rocket.mdl")
		util.PrecacheModel("models/weapons/c_models/c_bugle/c_bugle.mdl")
		util.PrecacheModel("models/weapons/c_models/c_flamethrower/c_flamethrower.mdl")
		util.PrecacheModel("models/weapons/w_models/w_flaregun_shell.mdl")
		util.PrecacheModel("models/weapons/w_models/w_grenade_grenadelauncher.mdl")
		util.PrecacheModel("models/weapons/w_models/w_stickybomb.mdl")
		util.PrecacheModel("models/weapons/c_models/c_claymore/c_claymore.mdl")
		util.PrecacheModel("models/weapons/w_models/w_minigun.mdl")
		util.PrecacheModel("models/weapons/c_models/c_sandwich/c_sandwich.mdl")
		util.PrecacheModel("models/weapons/w_models/w_wrangler.mdl")
		util.PrecacheModel("models/weapons/w_models/w_syringegun.mdl")
		util.PrecacheModel("models/weapons/c_models/c_medigun/c_medigun.mdl")
		util.PrecacheModel("models/items/medkit_medium.mdl")
		util.PrecacheModel("models/weapons/w_models/w_sniperrifle.mdl")
		util.PrecacheModel("models/weapons/w_models/w_arrow.mdl")
		util.PrecacheModel("models/weapons/w_models/w_smg.mdl")
		util.PrecacheModel("models/weapons/c_models/urinejar.mdl")
		util.PrecacheModel("models/weapons/c_models/c_machete/c_machete.mdl")
		util.PrecacheModel("models/weapons/c_models/c_revolver/c_revolver.mdl")
		util.PrecacheModel("models/weapons/w_models/w_sapper.mdl")
		util.PrecacheModel("models/weapons/w_models/w_knife.mdl")
		util.PrecacheModel("models/weapons/c_models/c_spy_watch.mdl")
	end

	--Scout
	ScavData.CollectFuncs["models/player/scout.mdl"] = function(self, ent)
		return {{"models/weapons/c_models/c_scattergun.mdl", 6, 0},
				{"models/weapons/w_models/w_pistol.mdl", 12, 0},
				{"models/weapons/c_models/c_energy_drink/c_energy_drink.mdl", 1, math.fmod(ent:GetSkin(), 2)}}
	end
	ScavData.CollectFuncs["models/bots/scout/bot_scout.mdl"] = ScavData.CollectFuncs["models/player/scout.mdl"]
	ScavData.CollectFuncs["models/bots/scout_boss/bot_scout_boss.mdl"] = ScavData.CollectFuncs["models/player/scout.mdl"]

	ScavData.CollectFX["models/player/scout.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/scout_battlecry0" .. math.random(5) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/scout/bot_scout.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/scout_mvm_battlecry0" .. math.random(5) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/scout_boss/bot_scout_boss.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/mght/scout_mvm_m_battlecry0" .. math.random(5) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/scout.mdl", "models/player/scout.mdl")
	
	--Soldier
	ScavData.CollectFuncs["models/player/soldier.mdl"] = function(self, ent)
		local items =  {{"models/weapons/c_models/c_shotgun/c_shotgun.mdl", 6, 0},
						{"models/weapons/c_models/c_buffpack/c_buffpack.mdl", 1, 0},
						{"models/weapons/c_models/c_bugle/c_bugle.mdl", 10, 0}}
		table.remove(items, math.random(#items))	
		table.insert(items, 1, {"models/weapons/w_models/w_rocket.mdl", 4, 0})
		return items
	end
	ScavData.CollectFuncs["models/bots/soldier/bot_soldier.mdl"] = ScavData.CollectFuncs["models/player/soldier.mdl"]
	ScavData.CollectFuncs["models/bots/soldier_boss/bot_soldier_boss.mdl"] = ScavData.CollectFuncs["models/player/soldier.mdl"]

	ScavData.CollectFX["models/player/soldier.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/soldier_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/soldier/bot_soldier.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/soldier_mvm_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/soldier_boss/bot_soldier_boss.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/mght/soldier_mvm_m_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/soldier.mdl", "models/player/soldier.mdl")
	
	--Pyro
	ScavData.CollectFuncs["models/player/pyro.mdl"] = function(self, ent)
		local items = {{"models/weapons/c_models/c_shotgun/c_shotgun.mdl", 6, 0},
					{"models/weapons/w_models/w_flaregun_shell.mdl", 5, ent:GetSkin() % 2}}
		if math.random(2) == 1 then
			table.insert(items, 1, {"models/weapons/c_models/c_flamethrower/c_flamethrower.mdl", 200, ent:GetSkin() % 2})
		else
			table.insert(items, 1, {"models/weapons/c_models/c_flameball/c_flameball.mdl", 40, ent:GetSkin() % 2})
		end
		return items
	end
	ScavData.CollectFuncs["models/bots/pyro/bot_pyro.mdl"] = ScavData.CollectFuncs["models/player/pyro.mdl"]
	ScavData.CollectFuncs["models/bots/pyro_boss/bot_pyro_boss.mdl"] = ScavData.CollectFuncs["models/player/pyro.mdl"]

	ScavData.CollectFX["models/player/pyro.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/pyro_battlecry0" .. math.random(2) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/pyro/bot_pyro.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/pyro_mvm_battlecry0" .. math.random(2) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/pyro_boss/bot_pyro_boss.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/mght/pyro_mvm_m_battlecry0" .. math.random(2) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/pyro.mdl", "models/player/pyro.mdl")
	
	--Demoman
	ScavData.CollectFuncs["models/player/demo.mdl"] = function(self, ent)
		return {{"models/weapons/w_models/w_grenade_grenadelauncher.mdl", 4, ent:GetSkin() % 2},
				{"models/weapons/w_models/w_stickybomb.mdl", 6, ent:GetSkin() % 2},
				{math.random(2) == 1 and "models/weapons/c_models/c_bottle/c_bottle.mdl" or "models/weapons/c_models/c_claymore/c_claymore.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/bots/demo/bot_demo.mdl"] = ScavData.CollectFuncs["models/player/demo.mdl"]
	ScavData.CollectFuncs["models/bots/demo_boss/bot_demo_boss.mdl"] = ScavData.CollectFuncs["models/player/demo.mdl"]

	ScavData.CollectFX["models/player/demo.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/demoman_battlecry0" .. math.random(7) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/demo/bot_demo.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/demoman_mvm_battlecry0" .. math.random(7) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/demo_boss/bot_demo_boss.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/mght/demoman_mvm_m_battlecry0" .. math.random(7) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/demo.mdl", "models/player/demo.mdl")
	
	--Heavy
	ScavData.CollectFuncs["models/player/heavy.mdl"] = function(self, ent)
		return {{"models/weapons/w_models/w_minigun.mdl", 200, 0},
				{"models/weapons/c_models/c_shotgun/c_shotgun.mdl", 6, 0},
				{"models/weapons/c_models/c_sandwich/c_sandwich.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/bots/heavy/bot_heavy.mdl"] = ScavData.CollectFuncs["models/player/heavy.mdl"]
	ScavData.CollectFuncs["models/bots/heavy_boss/bot_heavy_boss.mdl"] = ScavData.CollectFuncs["models/player/heavy.mdl"]

	ScavData.CollectFX["models/player/heavy.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/heavy_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/heavy/bot_heavy.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/heavy_mvm_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/heavy_boss/bot_heavy_boss.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/mght/heavy_mvm_m_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/heavy.mdl", "models/player/heavy.mdl")
	
	--Engineer
	ScavData.CollectFuncs["models/player/engineer.mdl"] = function(self, ent)
		return {{"models/weapons/c_models/c_shotgun/c_shotgun.mdl", 6, 0},
				{"models/weapons/w_models/w_pistol.mdl", 12, 0},
				{"models/weapons/w_models/w_wrangler.mdl", SCAV_SHORT_MAX, math.fmod(ent:GetSkin(), 2)}}
	end
	ScavData.CollectFuncs["models/bots/engineer/bot_engineer.mdl"] = ScavData.CollectFuncs["models/player/engineer.mdl"]

	ScavData.CollectFX["models/player/engineer.mdl"] = function(self, ent)
		local voiceclipnum = math.random(6)
		if voiceclipnum > 1 then voiceclipnum = voiceclipnum + 1 end --no engineer_battlecry02.mp3
		self.Owner:EmitSound("vo/engineer_battlecry0" .. voiceclipnum .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/engineer/bot_engineer.mdl"] = function(self, ent)
		local voiceclipnum = math.random(6)
		if voiceclipnum > 1 then voiceclipnum = voiceclipnum + 1 end --no engineer_battlecry02.mp3
		self.Owner:EmitSound("vo/mvm/norm/engineer_mvm_battlecry0" .. voiceclipnum .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/engineer.mdl", "models/player/engineer.mdl")
	
	--Medic
	ScavData.CollectFuncs["models/player/medic.mdl"] = function(self, ent)
		return {{"models/weapons/w_models/w_syringegun.mdl", 40, ent:GetSkin()},
				{"models/weapons/c_models/c_medigun/c_medigun.mdl", SCAV_SHORT_MAX, math.fmod(ent:GetSkin(), 2)},
				{"models/items/medkit_medium.mdl", 1, 0}}
	end
	ScavData.CollectFuncs["models/bots/medic/bot_medic.mdl"] = ScavData.CollectFuncs["models/player/medic.mdl"]

	ScavData.CollectFX["models/player/medic.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/medic_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/medic/bot_medic.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/medic_mvm_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/medic.mdl", "models/player/medic.mdl")
	
	--Sniper
	ScavData.CollectFuncs["models/player/sniper.mdl"] = function(self, ent)
		local items = {{"models/weapons/c_models/c_machete/c_machete.mdl", 1, 0}}
		local pickone = math.random(2)
		if pickone == 1 then
			table.insert(items, 1, {"models/weapons/w_models/w_sniperrifle.mdl", 25, 0})
		else
			table.insert(items, 1, {"models/weapons/w_models/w_arrow.mdl", 3, 0})
		end
		pickone = math.random(2)
		if pickone == 1 then
			table.insert(items, 2, {"models/weapons/w_models/w_smg.mdl", 25, 0})
		else
			table.insert(items, 2, {"models/weapons/c_models/urinejar.mdl", 1, 0})
		end
		return items
	end
	ScavData.CollectFuncs["models/bots/sniper/bot_sniper.mdl"] = ScavData.CollectFuncs["models/player/sniper.mdl"]

	ScavData.CollectFX["models/player/sniper.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/sniper_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/sniper/bot_sniper.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/sniper_mvm_battlecry0" .. math.random(6) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/sniper.mdl", "models/player/sniper.mdl")
	
	--Spy
	ScavData.CollectFuncs["models/player/spy.mdl"] = function(self, ent)
		return {{"models/weapons/c_models/c_revolver/c_revolver.mdl", 6, 0},
				{"models/weapons/w_models/w_sapper.mdl", 8, 0},
				{"models/weapons/w_models/w_knife.mdl", 1, 0},
				{"models/weapons/c_models/c_spy_watch.mdl", 30, 0}}
	end
	ScavData.CollectFuncs["models/bots/spy/bot_spy.mdl"] = ScavData.CollectFuncs["models/player/spy.mdl"]

	ScavData.CollectFX["models/player/spy.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/spy_battlecry0" .. math.random(4) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavData.CollectFX["models/bots/spy/bot_spy.mdl"] = function(self, ent)
		self.Owner:EmitSound("vo/mvm/norm/spy_mvm_battlecry0" .. math.random(4) .. ".mp3", 75, 100, 1, CHAN_VOICE)
	end
	ScavDataCollectCopy("models/player/hwm/spy.mdl", "models/player/spy.mdl")
	
	--Human Grunt
	ScavData.CollectFuncs["models/hgrunt.mdl"] = function(self, ent)
		if ent:GetBodygroup(2) == 0 then
			return {{"models/w_9mmar.mdl", 25, 0}}
		elseif ent:GetBodygroup(2) == 1 then
			return {{"models/shotgunshell.mdl", 8, 0}}
		else
			return {{"models/w_grenade.mdl", 1, 0}}
		end
	end
	ScavData.CollectFX["models/hgrunt.mdl"] = function(self, ent)
		self.Owner:EmitSound("hgrunt/bastard!.wav", 75, 100, 0.125, CHAN_VOICE)
	end

end
