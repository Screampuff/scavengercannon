--Firemodes largely related to Fistful of Frags. Can have other games' props defined!

--[[==============================================================================================
	-- Whiskey
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.whiskey"
			tab.anim = ACT_VM_IDLE
			tab.Level = 1
			local identify = {
				--[Default] = 0,
				--[[FoF]]["models/weapons/w_whiskey.mdl"] = SCAV_WHISKEY_FOF,
				["models/weapons/w_whiskey2.mdl"] = SCAV_WHISKEY_FOF,
				["models/items_fof/whiskey_world.mdl"] = SCAV_WHISKEY_FOF,
			}
			tab.Identify = setmetatable(identify, {__index = function() return SCAV_WHISKEY_DEFAULT end} )
			tab.MaxAmmo = 6
			tab.FireFunc = function(self, item)
				if IsValid(self.Owner) then
					--[[if (self.Owner:Health() >= self.Owner:GetMaxHealth() and not self.Owner:GetStatusEffect("Radiation")) then
						local tab = ScavData.models[self.inv.items[1].ammo]
						if SERVER then
							self.Owner:EmitSound(tab.Identify[item.ammo] == 1 and "player/burp.wav" or "ambient/levels/canals/drip1.wav")
						end
						tab.Cooldown = .5
						return false
					else]]if SERVER then
						self.Owner:SetHealth(math.min(self.Owner:GetMaxHealth(), self.Owner:Health() + 15))
						self.Owner:InflictStatusEffect("Radiation", -5, -1, self.Owner)
						self.Owner:EmitSound(tab.Identify[item.ammo] == SCAV_WHISKEY_FOF and "player/whiskey_glug" .. math.random(1, 4) .. ".wav" or "ambient/levels/canals/toxic_slime_gurgle4.wav", 75, 100, 1, CHAN_VOICE)
						self.Owner:InflictStatusEffect("Drunk", 20, 0.5)
						return self:TakeSubammo(item, 1)
					end
				end
			end
			tab.ReturnHealth = function(self, item)
				return 15
			end
			if SERVER then
				--CSS
				ScavData.CollectFuncs["models/props/cs_militia/caseofbeer01.mdl"] = function(self, ent) return { --15-pack
					{ScavData.FormatModelname("models/props/cs_militia/bottle01.mdl"), 6, 0},
					{ScavData.FormatModelname("models/props/cs_militia/bottle02.mdl"), 6, 0},
					{ScavData.FormatModelname("models/props/cs_militia/bottle03.mdl"), 3, 0},
				} end
				--L4D/2
				ScavData.CollectFuncs["models/props_junk/garbage_sixpackbox01a.mdl"] = function(self, ent) return {{ScavData.FormatModelname("models/props_junk/glassbottle01a.mdl"), 6, math.Round(math.Rand(0, 1))}} end --6-pack
				ScavData.CollectFuncs["models/props_junk/garbage_sixpackbox01a_fullsheet.mdl"] = ScavData.CollectFuncs["models/props_junk/garbage_sixpackbox01a.mdl"]
				--FoF
				ScavData.CollectFX["models/weapons/w_whiskey.mdl"] = function(self, ent)
					local voice = {"voice", "voice2", "voice4"}
					self.Owner:EmitSound("player/" .. voice[math.random(3)] .. "/whiskey_passwhiskey" .. math.random(2) .. ".wav", 75, 100, 1, CHAN_VOICE)
				end
				ScavData.CollectFX["models/weapons/w_whiskey2.mdl"] = ScavData.CollectFX["models/weapons/w_whiskey.mdl"]
				ScavData.CollectFX["models/items_fof/whiskey_world.mdl"] = ScavData.CollectFX["models/weapons/w_whiskey.mdl"]
				ScavData.CollectFuncs["models/elpaso/barrel2.mdl"] = function(self, ent) return {{ScavData.FormatModelname(math.random() < .5 and "models/weapons/w_whiskey.mdl" or "models/weapons/w_whiskey2.mdl"), 5, 0}} end
				ScavData.CollectFX["models/elpaso/barrel2.mdl"] = function(self, ent)
					local voice = {"voice", "voice2", "voice4"}
					self.Owner:EmitSound("player/" .. voice[math.random(3)] .. "/howl_yeehaw" .. math.random(2) .. ".wav", 75, 100, 1, CHAN_VOICE)
				end
				ScavData.CollectFuncs["models/elpaso/barrel2_small.mdl"] = ScavData.CollectFuncs["models/elpaso/barrel2.mdl"]
				ScavData.CollectFX["models/elpaso/barrel2_small.mdl"] = ScavData.CollectFX["models/elpaso/barrel2.mdl"]
			end
			tab.Cooldown = 1
		ScavData.RegisterFiremode(tab, "models/props_junk/glassjug01.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_glassbottle001a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_glassbottle002a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_glassbottle003a.mdl")
		ScavData.RegisterFiremode(tab, "models/props_junk/glassbottle01a.mdl")
		--CSS
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/bottle01.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/bottle02.mdl")
		ScavData.RegisterFiremode(tab, "models/props/cs_militia/bottle03.mdl")
		--TF2
		ScavData.RegisterFiremode(tab, "models/weapons/w_models/w_bottle.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/c_models/c_bottle/c_bottle.mdl")
		ScavData.RegisterFiremode(tab, "models/workshop/weapons/c_models/c_scotland_shard/c_scotland_shard.mdl")
		ScavData.RegisterFiremode(tab, "models/props_gameplay/bottle001.mdl")
		--L4D/2
		ScavData.RegisterFiremode(tab, "models/props_junk/garbage_glassbottle003a_static.mdl")
		--FoF
		ScavData.RegisterFiremode(tab, "models/weapons/w_whiskey.mdl")
		ScavData.RegisterFiremode(tab, "models/weapons/w_whiskey2.mdl")
		ScavData.RegisterFiremode(tab, "models/items_fof/whiskey_world.mdl")

--Rest of these firemodes require assets from FoF (and most of these props are only present in it, too)
if not FOF then return end

local eject = "brass"
--movetype enums
local move = {
	["crouch"] = 1,
	["idle"] = 2,
	["walk"] = 3,
	["run"] = 4,
	["jump"] = 5,
	["speed"] = 6,
}

--Figure out player's current movement, returning the appropriate accuracy modifier
local function aimstate(self, accuracy)
	local ply = self.Owner
	if not IsValid(ply) then return accuracy[move.run] end
	if not ply:OnGround() then return accuracy[move.jump] end
	if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_LEFT) or ply:KeyDown(IN_RIGHT) then
		--Bump us up one level of accuracy if we're crouched
		local crouch = ply:Crouching() and -1 or 0
		if ply:KeyDown(IN_SPEED) then return accuracy[move.speed + crouch] end
		if ply:IsWalking() then return accuracy[move.walk + crouch] end
		return accuracy[move.run + crouch]
	end
	if ply:Crouching() then return accuracy[move.crouch] end
	return accuracy[move.idle]
end

--Eject shells
local function RevolverCylinder(self, item, num, snd)
	if (item.subammo <= 1 and SERVER) or (item.subammo <= 0 and CLIENT) then
		timer.Simple(0.5,function()
			if SERVER then
				self.Owner:EmitSound(snd or "weapons/357/357_reload1.wav", 75, 100, 1, CHAN_WEAPON)
			end
			if CLIENT ~= game.SinglePlayer() then
				local ef = EffectData()
				local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
				if attach then
					ef:SetOrigin(attach.Pos)
					ef:SetAngles(attach.Ang)
					ef:SetEntity(self)
					for i=1, (num or 6) do
						util.Effect("ShellEject",ef)
					end
				end
			end
		end)
	end
end

--[[Note on guns, the following are taken from FoF's scripts and unless noted otherwise are accurate to FoF:
	- accuracy (numbers are divided by 10 as the raw numbers had *way* too big of a spread, don't know how much these actually match. Apparently 0.02 is "91% accurate", whatever that *means*),
	- damage,
	- clip size (pickup amount), 
	- sound settings (not timings)
	Everything else is just sorta played by ear]]

--[[==============================================================================================
	--Smith Carbine
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.fofcarbine"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end} )
			tab.MaxAmmo = 11
			local accuracy = {0.006, 0.008, 0.022, 0.03, 0.04, 0.03}
			local bullet = {}
					bullet.Num = 1
					bullet.Tracer = 1
					bullet.Force = 7
					bullet.Damage = 75
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-5,math.Rand(-1, 1), 0), 0.5)
					local aimoffset = aimstate(self, accuracy)
					bullet.Spread = Vector(aimoffset, aimoffset, 0)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self:EmitSound("^weapons/carbine/smith_carbine_fire.wav", 140, math.random(98, 101), 1)
						timer.Simple(.55, function()
							if not IsValid(self) then return end
							self:EmitSound(")weapons/carbine/carbine_open.wav", 75, 100, 0.7)
							timer.Simple(.55, function()
								if not IsValid(self) then return end
								self:EmitSound(")weapons/carbine/carbine_insert.wav", 75, 100, 0.7)
								timer.Simple(.35, function()
									if not IsValid(self) then return end
									self:EmitSound(")weapons/carbine/carbine_close.wav", 75, 100, 0.7)
								end)
							end)
						end)
					end
					if CLIENT ~= game.SinglePlayer() then
						timer.Simple(1, function()
							if not IsValid(self) or not self.Owner:GetViewModel() then return end
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("RifleShellEject",ef)
							end
						end)
					end
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.OnArmed = function(self, item,olditemname)
					if SERVER then
						if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
							self.Owner:EmitSound("items/equipment_pickup.wav")
						end
					end
				end
			tab.Cooldown = 2
		ScavData.RegisterFiremode(tab, "models/weapons/w_carbine.mdl")

--[[==============================================================================================
	--Coach Shotgun
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.coachgun"
			tab.anim = ACT_VM_SECONDARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end} )
			tab.MaxAmmo = 40
			local accuracy = {0.005, 0.005, 0.008, 0.02, 0.025, 0.033}
			local bullet = {}
					bullet.Num = 12
					bullet.Tracer = 1
					bullet.Force = 1
					bullet.Damage = 0
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-5,math.Rand(-0.2, 0.2), 0), 0.5)
					local aimoffset = aimstate(self, accuracy)
					bullet.AccuracyOffset = Vector(aimoffset * 10, aimoffset * 5, 0) --more horizontal spread
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					--The Coach gun applies its full damage if any pellets hit, don't stack multiple
					bullet.Callback = function(attacker, trace, dmginfo)
						if not IsValid(trace.Entity) then return {false, false} end
						--dmginfo won't exist next frame, get relevant info from it
						local dam = {}
							dam.pos = dmginfo:GetDamagePosition()
							dam.type = dmginfo:GetDamageType()
							dam.force = dmginfo:GetDamageForce() * 20
							dam.attack = dmginfo:GetAttacker()
							dam.inflict = dmginfo:GetInflictor()
						--Named timer means damage is only applied once next tick
						timer.Create("ScavFoFCoachgun"..tostring(trace.Entity), 0, 1, function()
							if not IsValid(trace.Entity) or not IsValid(self.Owner) then return end
							local dmginf = DamageInfo()
								dmginf:SetDamage(60)
								dmginf:SetDamagePosition(dam.pos)
								dmginf:SetDamageType(dam.type)
								dmginf:SetDamageForce(dam.force)
								dmginf:SetAttacker(dam.attack)
								dmginf:SetInflictor(dam.inflict)
							trace.Entity:TakeDamageInfo(dmginf)
							print(trace.Entity:Health())
						end)
						return {true, false}
					end
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self:EmitSound("^weapons/coachgun/coach_fire1_double.wav", 120, math.random(97, 104), 0.45, CHAN_WEAPON)
						timer.Simple(.55, function()
							if not IsValid(self) then return end
							self:EmitSound("weapons/coachgun/coach_open.wav", 75, 100, 0.7)
							timer.Simple(.55, function()
								if not IsValid(self) then return end
								self:EmitSound("weapons/coachgun/coach_extract.wav", 75, 100, 0.8)
								timer.Simple(.75, function()
									if not IsValid(self) then return end
									self:EmitSound("weapons/coachgun/coach_insert.wav", 75, 100, 0.8)
									timer.Simple(.75, function()
										if not IsValid(self) then return end
										self:EmitSound("weapons/coachgun/coach_close.wav", 75, 100, 0.7)
									end)
								end)
							end)
						end)
					end
					if CLIENT ~= game.SinglePlayer() then
						timer.Simple(.55, function()
							if not self.Owner:GetViewModel() then return end
							local ef = EffectData()
							local attach = self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment(eject))
							if attach then
								ef:SetOrigin(attach.Pos)
								ef:SetAngles(attach.Ang)
								ef:SetFlags(75) --velocity
								util.Effect("EjectBrass_12Gauge",ef)
								util.Effect("EjectBrass_12Gauge",ef)
							end
						end)
					end
					self:AddInaccuracy(aimoffset * 5, aimoffset * 5)
					if SERVER then return self:TakeSubammo(item, 2) end
				end
			tab.OnArmed = function(self, item,olditemname)
					if SERVER then
						if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
							self.Owner:EmitSound("items/equipment_pickup.wav")
						end
					end
				end
			tab.Cooldown = 3
		ScavData.RegisterFiremode(tab, "models/weapons/w_coachgun.mdl", 4) --two just isn't enough

--[[==============================================================================================
	--S&W Schofield
==============================================================================================]]--
		
		local tab = {}
			tab.Name = "#scav.scavcan.schofield"
			tab.anim = ACT_VM_PRIMARYATTACK
			tab.Level = 2
			local identify = {}
			tab.Identify = setmetatable(identify, {__index = function() return 0 end} )
			tab.MaxAmmo = 150
			local accuracy = {0.002, 0.0022, 0.004, 0.019, 0.035, 0.045}
			local bullet = {}
					bullet.Num = 1
					bullet.Tracer = 1
					bullet.Force = 5
					bullet.Damage = 40
					bullet.TracerName = "ef_scav_tr_b"
			tab.FireFunc = function(self, item)
					self.Owner:ScavViewPunch(Angle(-0.5,math.Rand(-0.2, 0.2), 0), 0.2)
					local aimoffset = aimstate(self, accuracy)
					bullet.AccuracyOffset = Vector(aimoffset, aimoffset, 0)
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self:GetAimVector()
					bullet.Spread = self:GetAccuracyModifiedCone(bullet.AccuracyOffset)
					if SERVER or not game.SinglePlayer() then
						self.Owner:FireBullets(bullet)
					end
					self:MuzzleFlash2()
					self.Owner:SetAnimation(PLAYER_ATTACK1)
					if SERVER then
						self.Owner:EmitSound("^weapons/schofield/schofield_fire.wav", 140, math.random(95, 105), 0.6, CHAN_WEAPON)
						self:AddBarrelSpin(700)
					end
					self.nextfireearly = CurTime()+0.3
					self:AddInaccuracy(aimoffset, aimoffset)
					RevolverCylinder(self, item, 6)
					if SERVER then return self:TakeSubammo(item, 1) end
				end
			tab.OnArmed = function(self, item,olditemname)
					if SERVER then
						if olditemname == "" or not ScavData.models[olditemname] or ScavData.models[item.ammo].Name ~= ScavData.models[olditemname].Name then
							self.Owner:EmitSound("items/equipment_pickup.wav")
						end
					end
				end
			tab.Cooldown = 0.7
		ScavData.RegisterFiremode(tab, "models/weapons/w_schofield.mdl", 6)
		ScavData.RegisterFiremode(tab, "models/weapons/w_schofield2.mdl", 6)
