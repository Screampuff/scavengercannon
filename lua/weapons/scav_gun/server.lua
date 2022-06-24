/////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////Server Code///////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

if SERVER then

	AddCSLuaFile()
	AddCSLuaFile("firemodes.lua")
	AddCSLuaFile("item.lua")
	
	CreateConVar("scav_defaultlevel", 9, {FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_GAMEDLL})
	CreateConVar("scav_pickupconstrained", 0, {FCVAR_ARCHIVE,FCVAR_GAMEDLL})
	CreateConVar("scav_propprotect", 1, {FCVAR_ARCHIVE,FCVAR_GAMEDLL})

	SWEP.spread 			= 0.1
	SWEP.shootsound 		= "physics/metal/metal_barrel_impact_hard6.wav"
	SWEP.mousepressed 		= false
	SWEP.currentmodel 		= ""
	
	SWEP.nextfire 			= 0
	SWEP.nextfireearly 		= 0
	
	SWEP.vmin1 				= Vector(-16,-16,-16)
	SWEP.vmax1 				= Vector(16,16,16)
	
	SWEP.BarrelRotation 	= 0
	SWEP.BarrelRestSpeed 	= 0
	
	SWEP.PanelSpeed 		= 0
	SWEP.PanelPose 			= 0
	SWEP.PanelTo 			= 0
	SWEP.BlockSpeed 		= 0
	SWEP.BlockPose 			= 0
	SWEP.BlockTo 			= 0
	
	util.AddNetworkString("scv_ht")
	
	function SWEP:SetHoldType(htype)
		local rf = RecipientFilter()
		rf:AddAllPlayers()
		net.Start("scv_ht")
			net.WriteEntity(self)
			net.WriteString(htype)
		net.Send(rf)
		self.BaseClass.SetHoldType(self,htype)
	end
	
	util.AddNetworkString("scv_asgn")

	function SWEP:AssignInventory()
		self.inv:AddOnClient(self.Owner)
		self.inv:AddPlayerToRecipientFilter(self.Owner)
		net.Start("scv_asgn")
			net.WriteEntity(self)
			net.WriteInt(self.inv.ID,16)
		net.Send(self.Owner)
	end

	function SWEP:EquipAmmo(pl)
		local wep = pl:GetWeapon("scav_gun")
		if wep:IsValid() then
			wep.dt.Level = math.max(self.dt.Level,wep.dt.Level)
		end
	end

	function depifvalid(wep)
		if IsValid(wep) then
			wep:Deploy(true)
		end
	end

	function SWEP:Equip(pl)
		self.StartLevel = pl:GetPlayerScavLevel()
		timer.Simple(1, function() depifvalid(self) end)
	end	
	
	function SWEP:OwnerChanged()
		if IsValid(self.Owner) then
			self.dt.Level = math.max(self.Owner:GetPlayerScavLevel(), self.dt.Level)
			self:AssignInventory()
		end
	end
	
	local massindex = {}

	local function lookupmass(modelname)

		if not massindex[modelname] then
		
			local prop = {}
			
			if util.IsValidRagdoll(modelname) then
				prop = ents.Create("prop_ragdoll")
			else
				prop = ents.Create("prop_physics")
			end
			
			prop:SetModel(modelname)
			prop:Spawn()
			
			local mass = 0
			
			for i=0,prop:GetPhysicsObjectCount()-1 do
				mass = mass+prop:GetPhysicsObjectNum(i):GetMass()
			end
			
			prop:Remove()
			massindex[modelname] = mass
			
		end
		
		return massindex[modelname]
		
	end

	function SWEP:AddItem(--[[string]] modelname, --[[int]] subammo, --[[int]] data, --[[int]] number, --[[int, optional, if nil then the entry will be added to the end of the list]] pos)

		local availableslots = self.dt.Capacity - self.inv:GetItemCount()
		
		if availableslots <= 0 then
			return
		end
		
		number = number or 1

		for i=1,math.min(number, availableslots) do
		
			local item = ScavItem(self.inv, pos)
			
			if item then
				item:SetAmmoType(modelname)
				item:SetSubammo(subammo)
				item:SetData(data)
				item:SetMass(lookupmass(modelname))
				item:FinishSetup()
			end
			
			item:AddOnClient(self.Owner)
			
			local modeinfo = ScavData.models[item.ammo]
			if modeinfo and modeinfo.OnPickup then
				modeinfo.OnPickup(self,item)
			end
			
		end
		
		local item = self:GetCurrentItem()
		
		if not item then
			self:SetBarrelRestSpeed(0)
			return
		end
		
		local modeinfo = ScavData.models[item.ammo]
		
		if availableslots == self.dt.Capacity and modeinfo then
			if modeinfo.OnArmed then
				modeinfo.OnArmed(self,item,"")
			end
			self:SetBarrelRestSpeed(modeinfo.BarrelRestSpeed or 0)
		end
		
	end

	function SWEP:SendWholeTable()
		self.inv:ClearOnClient(self.Owner)
		self.inv:AddAllToClient(self.Owner)
	end
	
	--called when most (but not all, naturally) firemodes are removed by the cannon itself
	function SWEP:RemoveItem(pos)
		
		if self.inv:GetItemCount() == 0 then
			return false
		end
		
		local postremoved = nil
		local itemold = self.inv.items[pos]
		
		if itemold:GetFiremodeTable() then
			postremoved = itemold:GetFiremodeTable().PostRemove
		end
		
		if postremoved then
			postremoved(self,itemold)
		end
		
		itemold:Remove()
		
		local itemnew = self:GetCurrentItem()
		
		if not itemnew then
			self:SetBarrelRestSpeed(0)
			return true
		end
		
		local modeinfo = itemnew:GetFiremodeTable()
		
		if (pos == 1) and itemnew and modeinfo then
			if modeinfo.OnArmed then
				modeinfo.OnArmed(self, itemnew, itemold.ammo)
			end
			self:SetBarrelRestSpeed(modeinfo.BarrelRestSpeed or 0)
		end
		
		return true
		
	end
	
	--Called in charge attacks to remove the item from the inventory, also for removing cloak when ammo is fully drained
	function SWEP:RemoveItemValue(item)
		for k,v in ipairs(self.inv.items) do
			if v == item then
				return self:RemoveItem(k)
			end
		end
	end

	function SWEP:GetInventory()
		return self.inv
	end

	function SWEP:GetCurrentItem()
		return self.inv.items[1]
	end

	function SWEP:GetNextItem()
		return self.inv.items[2]
	end

	--Player manually switches items in inventory
	function SWEP.ShiftItems(pl,cmd,args)

		local self = pl:GetActiveWeapon()
		
		if not IsValid(self) or self:GetClass() ~= "scav_gun" or self.inv:GetItemCount() == 0 or self.ChargeAttack then
			return
		end
		
		amt = math.Clamp(tonumber(args[1],10), -127, 128)
		
		local item = self:GetCurrentItem()
		
		self.inv:ShiftItems(amt,pl)
		
		local itemnew = self:GetCurrentItem()
		if not itemnew then
			return
		end
		
		local modeinfo = ScavData.models[itemnew.ammo]
		
		if (item ~= itemnew) and modelfino then
			self:SetBarrelRestSpeed(modeinfo.BarrelRestSpeed or 0)
			if modeinfo.OnArmed then
				modeinfo.OnArmed(self, itemnew, item.ammo)
			end
		end
		
		pl:EmitSound("weapons/smg1/switch_single.wav", 100, 100 + math.abs(amt * 2))
		
	end
	
	concommand.Add("scv_itm_shft", SWEP.ShiftItems)
	
	function SWEP:HasItem(name,exclude)
		for _,v in ipairs(self.inv.items) do
			if string.find(v.ammo,name,0,true) and ((exclude and not string.find(v.ammo, exclude, 0, true)) or not exclude) then
				return true
			end
		end
		return false
	end

	function SWEP:HasItemName(name)
		for _,v in ipairs(self.inv.items) do
			if v.ammo == name then
				return true
			end
		end
		return false
	end
	
	local function CMDRemoveItem(pl,cmd,args)

		local self = pl:GetActiveWeapon()
		
		if self:GetClass() ~= "scav_gun" or self.inv:GetItemCount() == 0 or self.ChargeAttack then
			return
		end
		
		local itemid = tonumber(args[1])
		
		if self.inv.itemids[itemid] then
			self.inv.itemids[itemid]:Remove(false,nil,true)
		end
		
	end

	concommand.Add("scv_itm_rem", CMDRemoveItem)
	
	function SWEP:UpdateTransmitState()
		return TRANSMIT_NEVER
	end

	function SWEP:AddBarrelSpin(speed)
		self.dt.BarrelSpinSpeed = self.dt.BarrelSpinSpeed + speed
		self.dt.BarrelSpinSpeed = math.Clamp(self.dt.BarrelSpinSpeed, -1440, 1440)
	end

	function SWEP:SetBarrelRestSpeed(speed)
		self.BarrelRestSpeed = speed
	end


	function SWEP:SetPanelPose(pose,speed)
		self.PanelTo = pose
		self.PanelSpeed = speed
	end

	function SWEP:SetPanelPoseInstant(pose,speed)
		self.PanelPose = pose
		self.PanelSpeed = speed or self.PanelSpeed
	end

	function SWEP:SetBlockPose(pose,speed)
		self.BlockTo = pose
		self.BlockSpeed = speed
	end

	function SWEP:SetBlockPoseInstant(pose,speed)
		self.BlockPose = pose
		self.PanelSpeed = speed or self.PanelSpeed
	end
	
	function SWEP:Think()

		local tr = self.Owner:GetEyeTraceNoCursor()
		
		if not IsValid(tr.Entity) then
			self.dt.CanScav = false
		else
			if tr.Entity ~= self.lastlookent then
				self.lastlookentcanscav = self:CheckCanScav(tr.Entity)
				self.lastlookent = tr.Entity
			end
			if IsValid(tr.Entity) then
				self.dt.CanScav = self.lastlookentcanscav
			else
				self.dt.CanScav = false
			end
		end

		if not self.Owner:KeyDown(IN_ATTACK) then
			self.Inaccuracy = math.Max(1, self.Inaccuracy - 10 * FrameTime())
		end
		
		self.dt.BarrelSpinSpeed = math.Approach(self.dt.BarrelSpinSpeed, self.BarrelRestSpeed, 600 * FrameTime())
		self.BarrelRotation = (self.BarrelRotation + self.dt.BarrelSpinSpeed * FrameTime()) % 360
		
		local vm = self.Owner:GetViewModel()
		local vmexists = IsValid(vm)
		
		if vmexists then
			vm:SetPoseParameter("spin", self.BarrelRotation)
		end
		
		self:SetPoseParameter("spin",self.BarrelRotation)
		
		if self.PanelPose ~= self.PanelTo then
		
			self.PanelPose = math.Approach(self.PanelPose, self.PanelTo, self.PanelSpeed * FrameTime())
			
			if vmexists then
				vm:SetPoseParameter("panel", self.PanelPose)
			end
			
			self:SetPoseParameter("panel", self.PanelPose)
			
		else
			self.PanelSpeed = 1
		end
		
		if self.BlockPose ~= self.BlockTo then
		
			self.BlockPose = math.Approach(self.BlockPose,self.BlockTo,self.BlockSpeed*FrameTime())
			
			if vmexists then
				vm:SetPoseParameter("block",self.BlockPose)
			end
			
			self:SetPoseParameter("block",self.BlockPose)
			
		else
			self.BlockSpeed = 1
		end
		
		if self.bsoundplay and not self.Owner:KeyDown(IN_ATTACK2) or self.nextfire > CurTime() or self.ChargeAttack then
			if self.soundloops.barrelspin then
				self.soundloops.barrelspin:FadeOut(0.5)
			end
			self.bsoundplay = false
		end
		
		if not self:IsLocked() and self.ChargeAttack and self.nextfire < CurTime() then
		
			local item = self.chargeitem
			local cooldown = self:ChargeAttack(item) * self.dt.CooldownScale
			
			self.nextfire = CurTime()+cooldown
			
			if item:GetFiremodeTable().chargeanim then
				self:SetSeqEndTime(self.nextfire)
				self:SendWeaponAnim(item:GetFiremodeTable().chargeanim)
			end
			
		end
		
		if self.shouldholster and self.nextfire < CurTime()then
			self.Owner:SelectWeapon(self.shouldholster)
		end
		
		if self.seqendtime ~= 0 and self.seqendtime < CurTime() then
			self:SendWeaponAnim(ACT_VM_IDLE)
			self:SetSeqEndTime(0)
		end
		
		if self:IsLocked() or not self.Owner:KeyDown(IN_ATTACK) then
			self:KillEffect()
			self.mousepressed = false
		end
		
		self.LastThink = CurTime()
		return true
		
	end
	
	function SWEP:OnRestore()
		self.nextfire = 0
		self.nextfireearly = 0
		ReinitializeScavInventory(self.inv)
		if IsValid(self.Owner) then
			self.inv:AddOnClient(self.Owner)
		end
	end

	function SWEP:KillEffect(effectent)
	end

	function SWEP:TimerKillEffect(ef)
	end

	function SWEP:CreateToggleEffect(name)
		local ef = ents.Create(name)
		if ef then
			ef:SetOwner(self)
			ef:Spawn()
			return ef
		end
	end

	function SWEP:OnRemove()
		for _,v in pairs(self.soundloops) do
			v:Stop()
		end
		if self:GetInventory() then
			self:GetInventory():Remove()
		end
		if self.soundloops.barrelspin then
			self.soundloops.barrelspin:Stop()
		end
	end
	
	function SWEP:Deploy(manual)

		if not IsValid(self.Owner) then
			return
		end
		
		if not manual then
			self.Owner:EmitSound("npc/sniper/reload1.wav", 50, 100)
			self.Owner:GetViewModel():SetPoseParameter("Block", 1)
			self.BlockPose = 1
			self:SetBlockPose(0,2)
		end
		
		if not self.soundloops.barrelspin then
			self.soundloops.barrelspin = CreateSound(self.Owner,"npc/combine_gunship/engine_rotor_loop1.wav")
		end
		
		self:SetSkin(self.skin)
		self.Owner:GetViewModel():SetSkin(self.skin)
		
		self.seqendtime = 0
		self:SetHoldType(self.HoldType)
		
		if not self.inv.AddOnClient then
			ReinitializeScavInventory(self.inv)
		end
		
		self.inv:AddOnClient(self.Owner)
		self.shouldholster = false

		self.dt.BarrelSpinSpeed = 0
		self.BarrelRestSpeed = 0
		self.BarrelRotation = 0

		return true
		
	end
	
	function SWEP:Holster(wep)

		self:KillEffect()
		
		if self:IsLocked() or self.ChargeAttack or self.nextfire > CurTime() then
		
			if IsValid(wep) then
				self.shouldholster = wep:GetClass()
			end
			
			self:NextThink(CurTime()+0.05)
			return false
			
		else
		
			for _,v in pairs(self.soundloops) do
				v:Stop()
			end
			
			if self.soundloops.barrelspin then
				self.soundloops.barrelspin:Stop()
			end
			
			return true
			
		end
		
	end
	
	function SWEP:SecondaryAttack()

		if self.nextfire > CurTime() then return end
		
		if not self.bsoundplay then
			if self.soundloops.barrelspin then
				self.soundloops.barrelspin:PlayEx(1,70)
			end
			self.bsoundplay = true
		end
		
		self:AddBarrelSpin(90)
		
		local tr = self.Owner:GetEyeTraceNoCursor()
		local ent = tr.Entity
		
		if not tr.Entity:IsValid() or tr.HitWorld then
			local tracep = {}
			tracep.start = self.Owner:GetShootPos()
			tracep.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 56100 * FrameTime()
			tracep.filter = {self.Owner,game.GetWorld()}
			tracep.mask = MASK_SHOT
			tracep.mins = self.vmin1
			tracep.maxs = self.vmax1
			tr = util.TraceHull(tracep)
			ent = tr.Entity
		end
		
		if not IsValid(ent) then return false end
		
		local phys = ent:GetPhysicsObject()
		if tr.StartPos:Distance(tr.HitPos) > 100 then
			if IsValid(phys) then
				phys:ApplyForceOffset(tr.Normal * -500, tr.HitPos)
			end
		elseif self:CheckCanScav(ent) then
			self:Scavenge(ent)
		end
		
	end

	local function deathshit(ent)
		local ef = ents.Create("scav_model")
		if ef then
			ef:SetModel(ent:GetModel())
			ef:SetPos(ent:GetPos())
			ef:SetAngles(ent:GetAngles())
			ef:Spawn()
			ParticleEffectAttach("scav_propdeath",PATTACH_ABSORIGIN_FOLLOW,ef,0)
		end
	end
	
	util.AddNetworkString("scv_s_time")
	
	function SWEP:PrimaryAttack()

		local shoottime = CurTime()
		
		if self.ChargeAttack or self:IsLocked() then
			return
		end
		
		if self.inv:GetItemCount() == 0 and self.nextfire < CurTime() then
			self.Owner:EmitSound("weapons/shotgun/shotgun_empty.wav")
			self:SetNextPrimaryFire(CurTime() + 0.4)
			return
		end
		
		if self.inv:GetItemCount() ~= 0 and (self.nextfire < CurTime() or (self.nextfireearly ~= 0 and self.nextfireearly < CurTime() and not self.mousepressed)) then
		
			self.nextfireearly = 0
			
			local item = self:GetCurrentItem()
			
			if ScavData.models[item.ammo] and ScavData.models[item.ammo].Level > self.dt.Level then
				self.Owner:EmitSound("vehicles/APC/apc_shutdown.wav",80)
				self:SendWeaponAnim(ACT_VM_FIDGET)
				self:SetNextPrimaryFire(shoottime + 2)
				self:SetSeqEndTime(shoottime + 1)
				return
			end
			
			if not self:HasItemTypeSameAsLast() then
				self:KillEffect()
				self.mousepressed = false
			end
			
			local modeinfo = ScavData.models[item.ammo]
			
			if modeinfo then
			
				if modeinfo.FireFunc(self,item) then
					self.currentmodel = item.ammo
					self:RemoveItem(1)
				else
					self.currentmodel = item.ammo
				end
				
				self:AddBarrelSpin(modeinfo.BarrelSpeedAdd or 0)
				
				local cooldown = ScavData.models[self.currentmodel].Cooldown * self.dt.CooldownScale
				
				if ScavData.models[self.currentmodel].anim then
					self:SendWeaponAnim(ScavData.models[self.currentmodel].anim)
					if not self.ChargeAttack then
						self:SetSeqEndTime(shoottime + math.min(self.Owner:GetViewModel():SequenceDuration(), cooldown))
					end
				end
				
				self.nextfire = shoottime + cooldown
				
			else
			
				local prop = nil
				
				if util.IsValidRagdoll(item.ammo) then
					prop = ents.Create("prop_ragdoll")
					prop.thrownby = self.Owner
				elseif util.IsValidProp(item.ammo) then
					prop = ents.Create("prop_physics")
				elseif string.find(item.ammo,"*%d",0,false) then
					prop = ents.Create("func_physbox")
				end

				if not prop then
					self:RemoveItem(1)
					return
				end
				
				local angoffset = ScavData.GetEntityFiringAngleOffset(prop)
				
				prop:SetModel(item.ammo)
				prop:SetSkin(item.data)
				prop.Owner = self.Owner
				prop:SetAngles(self.Owner:GetAimVector():Angle() + angoffset)
				prop:SetPos(self.Owner:GetShootPos())
				prop:SetOwner(self.Owner)
				prop:SetMaterial("scv_leffect")
				prop:Spawn()
				prop:SetHealth(1)
				prop:SetPhysicsAttacker(self.Owner)
				
				local phys = prop:GetPhysicsObject()
				local mass = 0
				
				for i=0,prop:GetPhysicsObjectCount()-1 do --setup bone positions
					local phys = prop:GetPhysicsObjectNum(i)
					if IsValid(phys) then
						phys:SetVelocity(self:GetAimVector() * 2000 * self.dt.ForceScale)
						phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
						mass = mass + phys:GetMass()
					end
				end
				
				self.nextfire = shoottime+(math.sqrt(mass) * 0.05) * self.dt.CooldownScale
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				EntReaper.AddDyingEnt(prop,10)
				prop:CallOnRemove("scavdeath",deathshit)
				self:SetSeqEndTime(self.nextfire - 0.1)
				self:RemoveItem(1)
				self.Owner:EmitSound(self.shootsound, 100, math.Clamp(120 - (self.nextfire - CurTime()) * 50, 30, 255))
				
				net.Start("scv_s_time")
					net.WriteEntity(self)
					net.WriteInt(math.floor(self.nextfire),32)
					net.WriteFloat(self.nextfire - math.floor(self.nextfire))
				net.Send(self.Owner)
				
			end
		end
		
		if self:GetCurrentItem() then
			if not self.mousepressed then
				self.mousepressed = CurTime()
			end
		else
			self:KillEffect()
			self.mousepressed = false
		end
		
	end
	
	function SWEP:CheckCanScav(ent)
		if self.inv:GetItemCount() < self.dt.Capacity and self.Owner:CanScavPickup(ent) then
			return true
		end
		return false
	end
	
	function SWEP:IsMousePressed()
		return self.mousepressed
	end

	function SWEP:HasItemTypeSameAsLast()
		if not self:GetCurrentItem() then
			return false
		else
			return ScavData.models[self.currentmodel] == ScavData.models[self:GetCurrentItem().ammo]
		end
	end

	function SWEP:Scavenge(ent)

		local modelname = ScavData.FormatModelname(ent:GetModel())
		
		if ScavData.CollectFuncs[modelname] then
			ScavData.CollectFuncs[modelname](self,ent)
		elseif string.find(modelname,"*%d",0,false) then
			self:AddItem(modelname,1,0)
		else
			self:AddItem(modelname,1,ent:GetSkin())
		end
		
		ent.NoScav = true
		
		local ef = EffectData()
		ef:SetRadius(ent:OBBMaxs():Distance(ent:OBBMins())/2)
		ef:SetEntity(self.Owner)
		ef:SetOrigin(ent:GetPos())
		
		util.Effect("scav_pickup",ef,nil,true)
		
		local pickup = ents.Create("scav_pickup")
		
		if pickup then
			pickup:SetModel(ent:GetModel())
			pickup:SetPos(ent:GetPos())
			pickup:SetAngles(ent:GetAngles())
			pickup:Spawn()
		end
		
		ent:Remove()
		self.inv:SendSnapshot()
		
		return true
		
	end
	
end