-- Scavenger Cannon
-- By Ghor / Anya O'Quinn

PrecacheParticleSystem("scav_exp_1")
PrecacheParticleSystem("scav_muzzleflare")
PrecacheParticleSystem("scav_muzzleflare_vm")
PrecacheParticleSystem("scav_muzzleflare2")
PrecacheParticleSystem("scav_muzzleflare2_vm")
PrecacheParticleSystem("scav_muzzleflare3")
PrecacheParticleSystem("scav_muzzleflare3_vm")
PrecacheParticleSystem("scav_muzzleflare4")
PrecacheParticleSystem("scav_muzzleflare4_vm")
PrecacheParticleSystem("scav_propdeath")

AddCSLuaFile()
AddCSLuaFile("firemodes.lua")
AddCSLuaFile("item.lua")

include("item.lua")

if CLIENT then
	SWEP.PrintName				= language.GetPhrase("scav.scavcan.wepname")
	SWEP.Author 				= "Ghor/Anya O'Quinn"
	SWEP.Purpose 				= language.GetPhrase("scav.scavcan.purpose")
	SWEP.Instructions 			= language.GetPhrase("scav.scavcan.instructions")
	SWEP.Category 				= language.GetPhrase("scav.category")
end

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Slot 					= 0
SWEP.SlotPos				= 1
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType 				= "pistol"

SWEP.ViewModel 				= "models/weapons/scav/c_scavgun7.mdl"
SWEP.WorldModel 			= "models/weapons/scav/c_scavgun7.mdl"
SWEP.UseHands 				= true

SWEP.Primary.Clipsize 		= 0
SWEP.Primary.Defaultclip 	= -1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.Clipsize 	= -1
SWEP.Secondary.Defaultclip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= "none"

SWEP.DrawCrosshair 			= false

SWEP.seqendtime 			= 0
SWEP.CooldownScale 			= 1 --cooldown will be scaled by this much
SWEP.WeaponCharge 			= 0 --the amount of charge the scavgun has (Modifying this will do nothing, it's meant to be set and used by firemodes)
SWEP.skin 					= 0
SWEP.Inaccuracy 			= 1
SWEP.startlock 				= 0
SWEP.endlock 				= 0

local ENTITY 	= FindMetaTable("Entity")
local PLAYER 	= FindMetaTable("Player")
local SWEP 		= SWEP
local ScavData 	= ScavData

function SWEP:SetupDataTables()

	self:NetworkVar("Int", 0, 	"Capacity")
	self:NetworkVar("Int", 1, 	"MaxExplosives")
	self:NetworkVar("Int", 2, 	"NWLevel")
	self:NetworkVar("Float", 0, 	"CooldownScale")
	self:NetworkVar("Float", 1, 	"ForceScale")
	self:NetworkVar("Float", 2, 	"BarrelSpinSpeed")
	self:NetworkVar("Entity", 0, "NWFiremodeEnt") --you can use this if the client needs to know about an entity in a firemode (like in the grappling beam), you should reset it to NULL when you're done though
	self:NetworkVar("Bool", 0, 	"CanScav")
	self:NetworkVar("Bool", 1, 	"UpgradeLaser")
	self:NetworkVar("Bool", 3, 	"Zoomed")

	self:SetCanScav(false)
	self:SetUpgradeLaser(false)
	self:SetCapacity(20)
	self:SetMaxExplosives(6)
	self:SetCooldownScale(1)
	self:SetForceScale(1)

	if SERVER then
		self:SetNWLevel(self.StartLevel or 9)
		SWEP.StartLevel = nil
	end

	self:SetNWFiremodeEnt(NULL)

end

function SWEP:Initialize()

	self:SetHoldType(self.HoldType)
	self.LastThink = CurTime()
	self:SetDeploySpeed(1)

	if not self.inv then
		self.inv = ScavInventory(self)
	end

	if SERVER then
		self.Effects = {}
		self.soundloops = {}
	end

end

function SWEP:GetAimVector()
	return (self.Owner:GetAimVector():Angle() + self.Owner:GetCurrentScavViewPunch()):Forward()
end

function SWEP:GetNextPrimaryFire()
	return self.nextfire
end

function SWEP:GetNextSecondaryFire()
	return self.nextfire
end

function SWEP:SetNextPrimaryFire(time)
	self.nextfire = time
end

function SWEP:SetNextSecondaryFire(time)
	self.nextfire = time
end

function SWEP:SetChargeAttack(func,item) --pass no value to disable chargeattack
	self.ChargeAttack = func
	self.chargeitem = item
end

function SWEP:AddInaccuracy(amt,max) --this function is not networked, you must predict it correctly!
	self.Inaccuracy = math.Min(self.Inaccuracy + amt, (1 + max) or 1.1)
end

local cone = Vector()

function SWEP:GetAccuracyModifiedCone(vec) --this returns the same, modified vector for the sake of reducing the number of objects used. You can use a number instead of a vector for a cone.

	local innac = self.Inaccuracy - 1

	if type(vec) == "Vector" then
		cone.x = vec.x + innac
		cone.y = vec.y + innac
		cone.z = 0
	else

		cone.x = vec + innac
		cone.y = vec + innac
		cone.z = 0
	end

	return cone

end

function SWEP:CreateEnt(classname)
	local ent = ents.Create(classname)
	ent.thrownby = self
	return ent
end

if SERVER then
	util.AddNetworkString("scv_lock")
end

function SWEP:Lock(starttime,endtime) --if you can call this on the server ahead of time, it'll allow you to lock the weapon without causing any synchronization errors if the player is still firing when it gets locked

	self.startlock = starttime
	self.endlock = endtime

	if SERVER then
		net.Start("scv_lock")
			net.WriteEntity(self)
			net.WriteFloat(starttime)
			net.WriteFloat(endtime)
		net.Send(self.Owner)
	end

end

function SWEP:IsLocked()
	return (self.endlock > CurTime() and self.startlock <= CurTime())
end

function SWEP:SetSeqEndTime(endtime)
	self.seqendtime = endtime
end

function SWEP:StopChargeOnRelease()
	local keydown = self.Owner:KeyDown(IN_ATTACK)
	if not keydown then
		self.ChargeAttack = nil
	end
	return keydown
end

function SWEP:ProcessLinking(item)

	if SERVER then

		if item.subammo <= 0 then

			local newitem = self:GetNextItem()

			if newitem and (ScavData.models[newitem.ammo] == ScavData.models[item.ammo]) then
				self.chargeitem = newitem
			else
				self.ChargeAttack = nil
			end

			item:Remove()

		end

		if not self:GetCurrentItem() or (ScavData.GetFiremode(item.ammo) ~= ScavData.GetFiremode(self:GetCurrentItem().ammo) or (self:GetCurrentItem().subammo <= 0)) or not self.Owner:KeyDown(IN_ATTACK) then
			self.ChargeAttack = nil
		end

		return self.ChargeAttack ~= nil

	else

		if item.subammo <= 0 then

			local predicteditem = self.inv.items[2]

			if predicteditem then

				self.predicteditem = 2

				if ScavData.GetFiremode(item.ammo) == ScavData.GetFiremode(predicteditem.ammo) then
					self.chargeitem = predicteditem
				else
					self.ChargeAttack = nil
					self.chargeitem = nil
				end

			else
				self.ChargeAttack = nil
				self.chargeitem = nil
			end

		end

		return self.ChargeAttack ~= nil

	end

end

if SERVER then

	ScavData.GiveOneOfItem = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()), 1, ent:GetSkin()) end
	ScavData.GiveOneOfItemInf = function(self,ent) self:AddItem(ScavData.FormatModelname(ent:GetModel()), SCAV_SHORT_MAX, ent:GetSkin()) end

	local tracep = {}
	tracep.mask = CONTENTS_SOLID
	tracep.mins = Vector(-5,-5,-5)
	tracep.maxs = Vector(5,5,5)

	local dmg = DamageInfo()

	util.AddNetworkString("scv_elec")

	function ScavData.Electrocute(inflictor,attacker,position,radius,damage,effect) --works like util.blast damage but only damages entities in the water and uses shock damage

		for _,v in ipairs(ents.FindInSphere(position,radius)) do
			if v:WaterLevel() > 0 then --waterlevel is acting strange..

				tracep.start = position
				tracep.endpos = v:GetPos()+v:OBBCenter()

				local tr = util.TraceHull(tracep)

				if not tr.Hit then
					dmg:SetDamageType(DMG_SHOCK)
					dmg:SetDamage(math.max(1,(1-(tracep.endpos:Distance(position)/radius))*damage))
					dmg:SetDamagePosition(tracep.endpos)
					dmg:SetAttacker(attacker)
					dmg:SetInflictor(inflictor)
					dmg:SetDamageForce(tr.Normal*damage*100)
					v:TakeDamageInfo(dmg)
				end

			end
		end

		if effect then
			local rf = RecipientFilter()
			rf:AddAllPlayers()
			util.AddNetworkString( "scv_elc" )
			net.Start("scv_elc")
				net.WriteVector(position)
				net.WriteFloat(radius)
			net.Send(rf)
		end

	end

	util.AddNetworkString("scv_setsubammo")

	function SWEP:TakeSubammo(item,amount)

		if item.subammo ~= SCAV_SHORT_MAX and SERVER then
			item.subammo = item.subammo - amount
		end

		if game.SinglePlayer() then
			local rf = RecipientFilter()
			rf:AddAllPlayers()
			net.Start("scv_setsubammo")
				net.WriteEntity(self)
				net.WriteInt(item.subammo,16)
			net.Send(rf)
		else
			net.Start("scv_setsubammo")
				net.WriteEntity(self)
				net.WriteInt(item.subammo,16)
				net.WriteInt(item.pos,8)
			net.Send(self.Owner)
		end

		if item == item and item.subammo <= 0 then
			return true
		else
			return false
		end

	end

	function SWEP:GetProjectileShootPos()
		return self.Owner:GetShootPos() - self:GetAimVector() * 15 + self:GetAimVector():Angle():Right() * 2 - self:GetAimVector():Angle():Up() * 2
	end

else

	function SWEP:TakeSubammo(item,amount,nolink)

		if item.subammo ~= SCAV_SHORT_MAX then
			item.subammo = item.subammo - amount
		end

		if (item == item) and (item.subammo <= 0) and not nolink then
			self.predicteditem = 2
		else
			self.predicteditem = 1
		end

		return false

	end

end

function SWEP:MuzzleFlash2(effectname,isparticle)

	effectname = effectname or 1

	if not effectname or type(effectname) == "number" then
		isparticle = true
	end

	local att = self:LookupAttachment("muzzle")
	local posang = self:GetAttachment(att)
	if IsValid(posang) then
		local ef = EffectData()
		ef:SetEntity(self)
		ef:SetOrigin(posang.Pos)
		ef:SetNormal(posang.Ang:Forward())
		ef:SetStart(posang.Pos)
		ef:SetAttachment(att)

		if not isparticle then
			util.Effect(effectname,ef)
		elseif type(effectname) == "number" then
			ef:SetScale(effectname)
			util.Effect("ef_scav_muzzleflare",ef)
		end
	end
end

if SERVER then
	util.AddNetworkString("scv_falloffsound")
else
	net.Receive("scv_falloffsound", function()
		local vec = net.ReadVector()
		LocalPlayer():EmitSound(net.ReadString(),math.Clamp(100 - EyePos():Distance(vec) / 50,20,100))
	end)
end

--Localize a Scav string, replacing any instances of %#% with the second, etc. arguments
ScavLocalize = function(...)
	local arg = {...}
	local strang = language.GetPhrase(tostring(table.remove(arg,1)))
	for i,v in ipairs(arg) do
		strang = string.Replace(strang,"%"..i.."%",language.GetPhrase(tostring(v)))
	end
	return strang
end

-----------------------------------------------------------------------------------------
---------------------------------------Client Code---------------------------------------
-----------------------------------------------------------------------------------------

if CLIENT then

	CreateClientConVar("cl_scav_iconalpha","200",true,false)
	CreateClientConVar("cl_scav_autoswitchdelay",".375",true,true,"Delay firing by this many seconds when automatically switching to another firemode.",0,1)

	CL_SCAVGUN = NULL

	SWEP.nextfire 				= 0
	SWEP.receivednextfire 		= 0
	SWEP.nextfireearly 			= 0

	SWEP.predicteditem 			= 1
	SWEP.rem_waiting 			= false
	SWEP.zoomed 				= false

	SWEP.vm_angles 				= Angle(0,0,0)

	SWEP.ViewLerpTime			= 0
	SWEP.ViewLerpDuration 		= 0
	SWEP.ViewLerpAngles 		= Angle(0,0,0)

	SWEP.FOVLerpTime 			= 0
	SWEP.FOVLerpDuration 		= 0
	SWEP.FOVLerpValue 			= 0

	SWEP.BarrelRotation 		= 0

	SWEP.LastAnim 				= ACT_VM_IDLE

	local color_red = Color(255,0,0,255)
	local color_red_colorblind = Color(190,76,0,255)
	local color_green = Color(0,255,0,255)
	local color_green_colorblind = Color(124,218,255,255)

	function SWEP:Precache()
		util.PrecacheSound("buttons/lever7.wav")
	end

	net.Receive("ent_emitsound",function()

		local ent = net.ReadEntity()
		local sound = net.ReadString()
		local vol = net.ReadFloat()
		local pitch = net.ReadFloat()

		if vol == 0 then
			vol = nil
		end

		if pitch == 0 then
			pitch = nil
		end
		ent:EmitSound(sound, vol, pitch)

	end)

	function SWEP:RemoveItem(pos) --Doesn't seem to ever get called?
		print("I am here!")
		if self.inv and self.inv.items[pos] then

			self.inv.items[pos].icon:Remove()

			local postremoved = nil

			if self:GetCurrentItem() and ScavData.models[self:GetCurrentItem().ammo] then
				postremoved = ScavData.models[self:GetCurrentItem().ammo].PostRemove
			end

			local item = table.remove(self.inv,pos)

			if postremoved then
				postremoved(self,item)
			end

			local itemnew = self:GetCurrentItem()

			if pos == 1 and itemnew and ScavData.models[itemnew.ammo] and ScavData.models[itemnew.ammo].OnArmed then
				ScavData.models[itemnew.ammo].OnArmed(self,itemnew,item.ammo)
			end

			self.menu.icondisplay:Refresh()
			self.predicteditem = 1
			self.rem_waiting = false

		end

	end

	function SWEP:OnItemRemoved(item)

		if self.inv and item then

			local postremoved = nil

			if item and item:GetFiremodeTable() then
				postremoved = item:GetFiremodeTable().PostRemove
			end

			if postremoved then
				postremoved(self,item)
			end

			local itemnew = self:GetCurrentItem()

			if item.pos == 1 and itemnew and itemnew:GetFiremodeTable() and itemnew:GetFiremodeTable().OnArmed then
				itemnew:GetFiremodeTable().OnArmed(self,itemnew,item.ammo)
			end

		end

		self.predicteditem = 1
		self.rem_waiting = false

		if self:IsMenuOpen() then
			self.Menu:RemoveIconByID(item.ID)
		end

	end

	function SWEP:OnItemReady(item)
		if self:IsMenuOpen() then
			self.Menu:AddIcon(item,item.ID,item.pos)
		end
	end

	function SWEP:OnInvShift(inv)
		if self:IsMenuOpen() then
			self.Menu:UpdateDesiredAngles()
		end
	end

	net.Receive("scv_s_time", function()

		local ent = net.ReadEntity()
		local stime = net.ReadInt(32) + net.ReadFloat()

		if not IsValid(ent) then return end

		ent:SetNextPrimaryFire(stime)
		ent.nextfire = stime
		ent.receivednextfire = UnPredictedCurTime()

	end)

	function SWEP:OnRemove()
		if IsValid(self.Owner) and self.Owner == LocalPlayer() and self:IsMenuOpen() then
			if IsValid(self.Menu) then
				self.Menu:Remove()
			end
		end
		self:DestroyWModel()
	end

	function SWEP:TranslateFOV(current_fov)

		if GetViewEntity() ~= self.Owner then
			return current_fov
		end

		if not self:GetCurrentItem() or not ScavData.models[self:GetCurrentItem().ammo] or not ScavData.models[self:GetCurrentItem().ammo].fov or not self:GetZoomed() then
			self:SetZoomed(false)
		elseif self:GetZoomed() then
			current_fov = ScavData.models[self:GetCurrentItem().ammo].fov
		end

		local dfov = GetConVar("fov_desired"):GetFloat()
		local realvmfov = current_fov + 62 - dfov

		if realvmfov < 0 then
			self.ViewModelFOV = 64 - realvmfov
		else
			self.ViewModelFOV = 62
		end

		return current_fov

	end

	function SWEP:AdjustMouseSensitivity()
		if self:GetZoomed() and self:GetCurrentItem() and ScavData.models[self:GetCurrentItem().ammo].fov then
			return ScavData.models[self:GetCurrentItem().ammo].fov / GetConVar("fov_desired"):GetFloat()
		else
			return
		end
	end

	function SWEP:Think()

		local delta = CurTime() - self.LastThink

		self.BarrelRotation = (self.BarrelRotation + self:GetBarrelSpinSpeed() * delta) % 360

		if not self.Owner:KeyDown(IN_ATTACK) then
			self.Inaccuracy = math.Max(1, self.Inaccuracy - 10 * FrameTime())
		end

		if not self:IsLocked() and self.ChargeAttack and self.nextfire < CurTime() then

			local shoottime = CurTime()
			local item = self.chargeitem or self.inv.items[self.predicteditem]
			local cooldown = self:ChargeAttack(item) * self:GetCooldownScale()
			self.nextfire = CurTime() + cooldown
			self.receivednextfire = UnPredictedCurTime()

			if ScavData.models[item.ammo].chargeanim then
				self:SetSeqEndTime(shoottime + cooldown)
				self:SendWeaponAnim(ScavData.models[item.ammo].chargeanim)
			end

		end

		if LocalPlayer():KeyDown(IN_RELOAD) then
			self:OpenMenu()
		end

		if self.seqendtime ~= 0 and self.seqendtime < CurTime() then
			self:SendWeaponAnim(ACT_VM_IDLE)
			self:SetSeqEndTime(0)
		end

		self.HUD:SetVisible(true)

		if CL_SCAVGUN == self and CL_SCAVGUNTAB ~= self:GetTable() then --this should hopefully fix the problem that comes up when the client loses connection to the server for a little more than a second
			self:SetTable(CL_SCAVGUNTAB)
		elseif CL_SCAVGUN ~= self then
			CL_SCAVGUNTAB = self:GetTable()
			CL_SCAVGUN = self
		end

		self.LastThink = CurTime()
		return true

	end

	function SWEP:Holster()
		self:DestroyWModel()
		return false
	end

	function SWEP:PrimaryAttack()

		if self:IsLocked() or self.ChargeAttack then
			return
		end

		local shoottime = CurTime()

		local item = self:GetCurrentItem() --the item we're going to use to fire

		if item and ScavData.models[item.ammo] and ScavData.models[item.ammo].Level > self:GetNWLevel() then
			self:SendWeaponAnim(ACT_VM_FIDGET)
			self:SetNextPrimaryFire(shoottime + 2)
			self:SetSeqEndTime(shoottime + 1)
			return
		end

		if (self.inv:GetItemCount() ~= 0) and self.nextfire < CurTime() or (self.nextfireearly ~= 0 and self.nextfireearly < CurTime()) then
			if self.Owner:KeyPressed(IN_ATTACK) then
				self.mousepressed = false
			else
				if not self.mousepressed then
					self.mousepressed = CurTime()
				end
			end
		end

		if self.inv:GetItemCount() ~= 0 and self.nextfire < CurTime() or (self.nextfireearly ~= 0 and self.nextfireearly < CurTime() and not self.mousepressed) then

			self.nextfireearly = 0

			if not self:HasItemTypeSameAsLast() then
				self.mousepressed = false
			end

			if self:GetCurrentItem() then
				self.currentmodel = self:GetCurrentItem().ammo
			else
				self.currentmodel = nil
			end

			if item and ScavData.models[item.ammo] then
				ScavData.ProcessLocalPlayerItemKnowledge(item.ammo)
			end

			if item and ScavData.models[item.ammo] and ScavData.models[item.ammo].FireFunc then --check to make sure that this item is valid and has a firemode

				local cooldown = ScavData.models[self.currentmodel].Cooldown * self:GetCooldownScale()

				ScavData.models[item.ammo].FireFunc(self,item)

				if ScavData.models[self.currentmodel].anim then

					self:SendWeaponAnim(ScavData.models[self.currentmodel].anim)
					self.LastAnim = ScavData.models[self.currentmodel].anim

					if not self.ChargeAttack then
						self:SetSeqEndTime(shoottime + math.min(self.Owner:GetViewModel():SequenceDuration(), cooldown))
					end

				end

				local nextfire = shoottime + cooldown
				self.nextfire = nextfire
				self.receivednextfire = UnPredictedCurTime()

			elseif item and ScavData.models[item.ammo] and ScavData.models[item.ammo].anim then --just play an animation if there is an empty firemode
				self:SendWeaponAnim(ScavData.models[self:GetCurrentItem().ammo].anim)
				self.LastAnim = ScavData.models[self:GetCurrentItem().ammo].anim
				self.nextfire = shoottime + ScavData.models[self:GetCurrentItem().ammo].Cooldown * self:GetCooldownScale()
				self.receivednextfire = UnPredictedCurTime()
				self:SetSeqEndTime(self.nextfire)
			elseif item then --just play a generic animation if we have no idea what this item is
				local mass = item:GetMass()
				self.nextfire = shoottime + (math.sqrt(mass) * 0.05) * self:GetCooldownScale()
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				self.LastAnim = ACT_VM_SECONDARYATTACK
				self.receivednextfire = UnPredictedCurTime()
				self:SetSeqEndTime(self.nextfire - 0.1)
			end

			if not self.mousepressed then
				self.mousepressed = CurTime()
			end

		end

	end

	function SWEP:OnRestore()
		self.nextfire = 0
		self.nextfireearly = 0
	end

	function SWEP:GetCurrentItem()
		return self.inv.items[self.predicteditem]
	end

	function SWEP:SecondaryAttack()
	end

	--------------------------------------------------------------------------------
	--HUD Ammo Display
	--------------------------------------------------------------------------------

	local PANEL 	= {}
	PANEL.BGColor 	= Color(255,255,255,255)
	PANEL.wep 		= NULL

	function PANEL:Init()
		self.Preview = vgui.Create("SpawnIcon",self)
		self.Preview:SetSize(64,64)
		self.Preview.parent = self
		self:AutoSetPos()
	end

	function PANEL:AutoSetPos()
		self:SetSize(268,96)
		self:SetPos(ScrW() - self:GetWide() - 32, ScrH() - self:GetTall() - 16)
	end

	function PANEL:PerformLayout()
		self.Preview:SetPos(16, self:GetTall() / 2 - self.Preview:GetTall() / 2)
	end

	function PANEL:Think()
		if LocalPlayer().GetActiveWeapon then

			self.wep = LocalPlayer():GetActiveWeapon()
			local isscav = IsValid(self.wep) and self.wep:GetClass() == "scav_gun"

			self:SetVisible(isscav)

			if not IsValid(self.wep) then
				return
			end

			if isscav then
				if self.wep.ChargeAttack then
					self.item = self.wep.chargeitem
				elseif IsValid(self.wep) and self.wep.GetCurrentItem and self.wep:GetCurrentItem() then
					self.item = self.wep:GetCurrentItem()
				end
			end

			if isscav and self.item and (self.wep.ChargeAttack or self.wep.inv:GetItemCount() > 0)  then
				self.Preview:SetVisible(true)
				self.Preview:SetModel(self.item.ammo,self.item.data)
			else
				self.Preview:SetVisible(false)
				self.item = nil
			end

		end
	end

	function PANEL:PaintOver()

		if LocalPlayer():GetActiveWeapon():GetClass() ~= "scav_gun" then
			self:SetVisible(false)
			return
		end

		local wep = self.wep
		local item = wep:GetCurrentItem()

		if IsValid(wep) and wep:GetClass() == "scav_gun" then

			surface.SetTextColor(255,255,255,255)
			surface.SetFont("Scav_MenuLarge")
			surface.SetTextPos(96,48)

			local firemodename = "#scav.scavcan.unknown"

			if item then
				local itemtab = ScavData.models[item.ammo]
				if ScavData.LocalPlayerKnowsItem(item.ammo) and itemtab then
					if itemtab.Name then
						firemodename = itemtab.Name
					elseif itemtab.GetName then
						firemodename = itemtab.GetName(wep,item)
					end
				end
			end

			surface.DrawText(firemodename)
			surface.SetTextPos(96,16)

			surface.DrawText(ScavLocalize("scav.scavcan.ammo",wep.inv:GetItemCount(),wep:GetCapacity()))
			surface.SetTextPos(104,64)
			surface.SetDrawColor(255, 255, 255, 200)
			surface.DrawRect(16, 80, (wep.nextfire-UnPredictedCurTime()) * 256 / (wep.nextfire - wep.receivednextfire) - 32, 8)

			if item then
				if self.item.subammo == SCAV_SHORT_MAX then
					surface.DrawText(ScavLocalize("scav.scavcan.subammo","scav.scavcan.inf"))
				else
					surface.DrawText(ScavLocalize("scav.scavcan.subammo",self.item.subammo))
				end
			else
				surface.DrawText(ScavLocalize("scav.scavcan.subammo","0"))
			end
		end
	end

	vgui.Register("scav_hud",PANEL,"DPanel")

	SWEP.HUD = vgui.Create("scav_hud")

	local HUD = SWEP.HUD
	HUD:SetVisible(false)
	HUD:SetSkin("sg_menu")

	function SWEP:HasItemTypeSameAsLast()
		if not self:GetCurrentItem() then
			return false
		else
			return (ScavData.models[self.currentmodel] == ScavData.models[self:GetCurrentItem().ammo])
		end
	end

	function SWEP:Deploy()
		self:SetHoldType(self.HoldType)
		self.seqendtime = 0
		self.BarrelRotation = 0
	end

	net.Receive("scv_asgn", function()
		local self = net.ReadEntity()
		local id = net.ReadInt(16)
		local inv = GetScavInventoryByID(id)
		self.inv = inv
	end)

	net.Receive("scv_ht",function()
		local self = net.ReadEntity()
		local htype = net.ReadString()
		if IsValid(self) and IsValid(self.Owner) and self.Owner ~= LocalPlayer() and self.SetHoldType then
			self:SetHoldType(htype)
		end
	end)

	net.Receive("scv_lock", function()
		local self = net.ReadEntity()
		local start = net.ReadFloat()
		local endtime = net.ReadFloat()
		self:Lock(start,endtime)
	end)

	if game.SinglePlayer() then
		net.Receive("scv_setsubammo", function()
			local self = net.ReadEntity()
			local int = net.ReadInt(16)
			if IsValid(self) and int and self.inv.items[1] then
				self.inv.items[1].subammo = int
			end
		end)
	else
		net.Receive("scv_setsubammo", function()
			local self = net.ReadEntity()
			local int = net.ReadInt(16)
			local pos = net.ReadInt(8)
			if IsValid(self) and int and self.inv.items[pos] then
				self.inv.items[pos].subammo = int
			end
		end)
	end

	local function applyeffect(ent)
		if IsValid(ent) then
			ent:SetModelScale(0,0.1)
			local edata = EffectData()
			edata:SetOrigin(ent:GetPos())
			edata:SetEntity(ent)
			util.Effect("ef_scav_launch",edata,true,true)
			return true
		end
		return false
	end

	hook.Add("OnEntityCreated","scv_leffect",function(ent)
		if IsValid(ent) and ent:GetMaterial() == "scv_leffect" then
			ent:SetMaterial()
			applyeffect(ent)
		end
	end)

	-------------------------------------
	------------/Drawing-----------------
	-------------------------------------

	local vec_white 		= Vector(1,1,1)

	local selecttex 		= surface.GetTextureID("hud/weapons/scav_gun")
	local screencolvec 		= Vector(1,1,1)

	SWEP.CrosshairFraction 	= 0
	local c_hairtex 		= surface.GetTextureID("hud/scav_crosshair_corner")
	local c_hairrotation 	= 0

	function SWEP:DrawWeaponSelection(x,y,w,h,a)
		local size = math.min(w,h)
		surface.SetTexture(selecttex)
		surface.SetDrawColor(255,255,255,a)
		surface.DrawTexturedRect(x + (w - size) / 2, y + (h - size) / 2, size, size)
	end

	--------------------------------------------------------------------------------
	--Screen
	--------------------------------------------------------------------------------

	local SCAV_RTMAT = Material("models/weapons/scavenger/screen")
	local SCAV_RTSCREEN = GetRenderTarget("scav_screen","256","256")
	local col_renderclear = Color(0,0,0,255)

	surface.CreateFont("ScavScreenFont", {font = "Trebuchet MS", size = 40, weight = 900, antialiasing = true, additive = false, outlined = false, blur = false})
	surface.CreateFont("ScavScreenFontSm", {font = "Trebuchet MS", size = 32, weight = 900, antialiasing = true, additive = false, outlined = false, blur = false})
	surface.CreateFont("ScavScreenFontSmX", {font = "Trebuchet MS", size = 24, weight = 900, antialiasing = true, additive = false, outlined = false, blur = false})

	alpha = 12
	greenscr = Color(108,172,24,alpha)
	greenscr_colorblind = Color(124,218,255,alpha)
	yellowscr = Color(172,172,24,alpha)
	yellowscr_colorblind = Color(172,172,24,alpha)
	redscr = Color(172,24,24,alpha)
	redscr_colorblind = Color(190,76,0,alpha)

	function DrawScreenBKG(col)
		--edge fade
		surface.SetDrawColor(color_black)
		surface.DrawRect(0,0,256,256)
		local i = 8
		local j = 4
		local u = 256-i*2
		local v = 128-j*2
		local a = alpha
		while u > 0 and v > 0 and a < 255 do
			draw.RoundedBox(32,i,j,math.max(1,u),math.max(1,v),col)
			i = i + 1
			j = j + 1
			u = u - 2
			v = v - 2
			a = a + alpha
		end
	end

	hook.Add("ScavScreenDrawOverride","NoOverride", function(self,check)
		local runcheck = check or false
		if check then return nil end
	end)

	hook.Add("ScavScreenDrawOverrideIdle","NoOverride", function(self,check)
		local runcheck = check or false
		if check then return nil end
	end)

	hook.Add("ScavScreenDrawOverridePost","NoOverride", function(self,check)
		local runcheck = check or false
		if check then return nil end
	end)

	hook.Add("ScavScreenDrawOverridePost","RadStatic",function(self)
		radthink = radthink or CurTime()
		geiger = geiger or SCAV_SHORT_MAX
		--GetInternalVariable("m_iGeigerRange")
		if radthink <= CurTime() then
			--geiger decay (effect trails off nicely instead of just abruptly ending)
			if geiger < 800 then
				geiger = geiger + 50
			end
			for _,v in pairs(ents.FindInBox(self.Owner:GetPos()-Vector(800,800,800),self.Owner:GetPos()+Vector(800,800,800))) do
				if v:GetStatusEffect("Radiation") then
					geiger = math.min(geiger,self.Owner:GetPos():Distance(v:GetPos()))
				end
			end
			radthink = CurTime() + 0.25
		end
		if geiger < 800 then
			for i=1,(800-geiger) do
				surface.SetDrawColor(255,255,255)
				surface.DrawRect(math.Rand(0,255),math.Rand(0,127),math.Rand(1,math.ceil(i/100)),math.Rand(1,math.ceil(i/100)))
			end
		end
	end)

	function SWEP:DrawIdle()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(greenscr)
		else
			DrawScreenBKG(greenscr_colorblind)
		end
		local vpos = 32
		if string.find(language.GetPhrase("scav.scavcan.ok"),"\n") then
			vpos = 12
		end
		local fontsize = "ScavScreenFont"
		if #language.GetPhrase("scav.scavcan.ok") > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.ok"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
	end

	function SWEP:DrawNice()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(greenscr)
		else
			DrawScreenBKG(greenscr_colorblind)
		end
		local vpos = 32
		if string.find(language.GetPhrase("scav.scavcan.nice"),"\n") then
			vpos = 12
		end
		local fontsize = "ScavScreenFont"
		if #language.GetPhrase("scav.scavcan.nice") > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.nice"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
	end

	function SWEP:DrawLocked()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(redscr)
		else
			DrawScreenBKG(redscr_colorblind)
		end
		local vpos = 32
		if string.find(language.GetPhrase("scav.scavcan.locked"),"\n") then
			vpos = 12
		end
		local fontsize = "ScavScreenFont"
		if #language.GetPhrase("scav.scavcan.locked") > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		local _, use = math.modf(CurTime())
		if use < .5 then
			draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.locked"),fontsize,128,vpos,color_white,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(ScavLocalize("scav.scavcan.status","scav.scavcan.locked"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		end
	end

	function SWEP:DrawCooldown()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(yellowscr)
		else
			DrawScreenBKG(yellowscr_colorblind)
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","\0"),"ScavScreenFont",128,12,color_black,TEXT_ALIGN_CENTER)
		local _, use = math.modf(math.abs(CurTime()-self.nextfire))
		if use < .25 then
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress0"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		elseif use < .5 then
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress3"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		elseif use < .75 then
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress2"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(language.GetPhrase("scav.scavcan.recharge")..language.GetPhrase("scav.scavcan.progress1"),"ScavScreenFontSm",128,20,color_black,TEXT_ALIGN_CENTER)
		end
	end

	function SWEP:DrawFiring()
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			DrawScreenBKG(greenscr)
		else
			DrawScreenBKG(greenscr_colorblind)
		end
		local vpos = 12
		local fontsize = "ScavScreenFont"
		if #(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress3")) > 15 then
			fontsize = "ScavScreenFontSm"
			vpos = vpos + 8
		end
		draw.DrawText(ScavLocalize("scav.scavcan.status","\0"),"ScavScreenFont",128,12,color_black,TEXT_ALIGN_CENTER)
		local _, use = math.modf(CurTime())
		if use < .25 then
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress0"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		elseif use < .5 then
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress1"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		elseif use < .75 then
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress2"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(language.GetPhrase("scav.scavcan.attack")..language.GetPhrase("scav.scavcan.progress3"),fontsize,128,vpos,color_black,TEXT_ALIGN_CENTER)
		end
	end

		function SWEP:DrawAutoTargetScreen(on)
		if not GetConVar("cl_scav_colorblindmode"):GetBool() then
			if on then
				DrawScreenBKG(greenscr)
			else
				DrawScreenBKG(redscr)
			end
		else
			if on then
				DrawScreenBKG(greenscr_colorblind)
			else
				DrawScreenBKG(redscr_colorblind)
			end
		end
		local vpos = 12
		local fontsize = "ScavScreenFontSm"
		if #language.GetPhrase("scav.scavcan.autotarget") > 14 then
			fontsize = "ScavScreenFontSmX"
			vpos = vpos + 8
		end
		local _, use = math.modf(CurTime())
		local col = color_black
		if not on and use < .5 then
			col = color_white
		end
		draw.DrawText(language.GetPhrase("scav.scavcan.autotarget"),fontsize,128,vpos,col,TEXT_ALIGN_CENTER)
		if on then
			draw.DrawText(language.GetPhrase("scav.scavcan.on"),"ScavScreenFont",128,20+vpos,col,TEXT_ALIGN_CENTER)
		else
			draw.DrawText(language.GetPhrase("scav.scavcan.off"),"ScavScreenFont",128,20+vpos,col,TEXT_ALIGN_CENTER)
		end
	end

	local idle = idle or true

	function SWEP:DrawScreen()
		local swide = ScrW()
		local shigh = ScrH()
		local rend = render.GetRenderTarget()
		render.SetRenderTarget(SCAV_RTSCREEN)
		--render.ClearRenderTarget(SCAV_RTSCREEN,col_renderclear)
		render.SetViewPort(0,0,256,256)
		cam.Start2D()
			local item = nil
			if IsValid(self.inv.items[1]) then
				item = ScavData.models[self.inv.items[1].ammo]
			end
			--Locked screen
			if self:IsLocked() then
				self:DrawLocked()
			--Screen Draw Override Hook
			elseif hook.Run("ScavScreenDrawOverride",self,true) then
				hook.Run("ScavScreenDrawOverride",self)
			--Auto-Targeting System screen
			elseif item and item.Name == "#scav.scavcan.computer" then
				self:DrawAutoTargetScreen(item.On)
			--Cooldown screen
			elseif ((self.nextfire - CurTime() > 0.25 and self.nextfireearly == 0) or self.nextfireearly - CurTime() > 0.25) and not self.ChargeAttack then
				self:DrawCooldown()
				idle = false
			--Nice screen
			elseif IsValid(self.inv.items[1]) and self.inv.items[1].subammo == 69 then
				self:DrawNice()
			--Charge Attack Firing screen
			elseif self.ChargeAttack then
				self:DrawFiring()
			--Seeking Rocket Screen
			elseif item and item.Name == "#scav.scavcan.rocket" then
				local seeking = false
				for i,v in pairs(self.inv.items) do
					if ScavData.models[v.ammo] and ScavData.models[v.ammo].Name == "#scav.scavcan.computer" then
						seeking = ScavData.models[v.ammo].On
						break
					end
				end
				if seeking then
					self:DrawAutoTargetScreen(seeking)
				elseif hook.Run("ScavScreenDrawOverrideIdle",true) then
					hook.Run("ScavScreenDrawOverrideIdle")
				else
					self:DrawIdle()
					idle = true
				end
			--Screen Draw Override Idle Hook
			elseif hook.Run("ScavScreenDrawOverrideIdle",self,true) and self.nextfire <= CurTime() then
				hook.Run("ScavScreenDrawOverrideIdle",self)
			--Idle Screen
			elseif self.nextfire <= CurTime() or idle then
				self:DrawIdle()
				idle = true
			--Cooldown Screen ending catch
			else
				self:DrawCooldown()
			end
			--Screen Post Draw Hook
			if hook.Run("ScavScreenDrawOverridePost",self,true) then
				hook.Run("ScavScreenDrawOverridePost",self)
			end
		cam.End2D()
		render.SetRenderTarget(rend)
		render.SetViewPort(0,0,swide,shigh)
		SCAV_RTMAT:SetTexture("$basetexture",SCAV_RTSCREEN)
	end


	function SWEP:DrawCrosshairs()

		local tr = self.Owner:GetEyeTraceNoCursor()
		local pos = tr.HitPos:ToScreen()

		if IsValid(tr.Entity) and tr.Entity:GetMoveType() == MOVETYPE_VPHYSICS then
			self.CrosshairFraction = math.Approach(self.CrosshairFraction, 1, FrameTime() * 10)
		else
			self.CrosshairFraction = math.Approach(self.CrosshairFraction, 0, FrameTime() * 2)
			if self.CrosshairFraction == 0 then
				c_hairrotation = 0
			end
		end

		surface.SetTexture(c_hairtex)


		local frac = self.CrosshairFraction
		local x = pos.x
		local y = pos.y
		local cfrac = math.cos(c_hairrotation * 5) * frac * 16
		local cfrac2 = math.cos(c_hairrotation * 5 + math.pi / 2) * frac * 16
		local sfrac = math.sin(c_hairrotation * 5) * frac * 16
		local sfrac2 = math.sin(c_hairrotation * 5 + math.pi / 2) * frac * 16
		local size = frac * 16
		local angoffset = -1 * math.deg(c_hairrotation * 5)

		if self:GetCanScav() and IsValid(tr.Entity) then
			if not GetConVar("cl_scav_colorblindmode"):GetBool() then
				surface.SetDrawColor(color_green)
			else
				surface.SetDrawColor(color_green_colorblind)
			end
			c_hairrotation = c_hairrotation + FrameTime()
		elseif IsValid(tr.Entity) then
			if not GetConVar("cl_scav_colorblindmode"):GetBool() then
				surface.SetDrawColor(color_red)
			else
				surface.SetDrawColor(color_red_colorblind)
			end
			-- X on the crosshair if we're trying to suck the unsuckable
			if self.Owner:KeyDown(IN_ATTACK2) then
				surface.DrawLine(x-size/2,y-size/2,x+size/2,y+size/2)
				surface.DrawLine(x-size/2+1,y-size/2,x+size/2+1,y+size/2)
				surface.DrawLine(x-size/2-1,y-size/2,x+size/2-1,y+size/2)
				surface.DrawLine(x-size/2,y+size/2,x+size/2,y-size/2)
				surface.DrawLine(x-size/2+1,y+size/2,x+size/2+1,y-size/2)
				surface.DrawLine(x-size/2-1,y+size/2,x+size/2-1,y-size/2)
			end
		else
			surface.SetDrawColor(150,150,150,150)
		end
		--draw the rotating colored crosshair
		surface.DrawTexturedRectRotated(x + cfrac, y + sfrac, size, size, 225 + angoffset)
		surface.DrawTexturedRectRotated(x + cfrac2, y + sfrac2, size, size, 135 + angoffset)
		surface.DrawTexturedRectRotated(x - cfrac2, y - sfrac2, size, size, 315 + angoffset)
		surface.DrawTexturedRectRotated(x - cfrac, y - sfrac, size, size, 45 + angoffset)

		--draw the normal crosshair
		local x = ScrW() / 2
		local y = ScrH() / 2
		local frac = 1 - self.CrosshairFraction
		surface.DrawCircle(x, y, 6 * frac, color_white)
		surface.SetTexture(0)
		surface.DrawTexturedRect(x - 1, y, 3 * frac, 1)
		surface.DrawTexturedRect(x, y - 1, 1, 3 * frac)

	end

	function SWEP:PreDrawViewModel(vm,wep,pl)
	end

	function SWEP:PostDrawViewModel(vm,wep,pl)
	end

	function SWEP:DestroyWModel()
		if IsValid(self.wmodel) then
			SafeRemoveEntity(self.wmodel)
		end
	end

	function SWEP:BuildWModel() --using a cmodel since SetPoseParameter only works on the LocalPlayer's weapon normally
		if not IsValid(self) then return end
		self:DestroyWModel()
		self.wmodel = ClientsideModel(self.WorldModel, RENDERGROUP_OPAQUE)
		self.wmodel:SetParent(self:GetOwner()) --just a heads up, if you parent it to the weapon its pose parameters won't work because of bonemerging to existing bones
		local meffects = bit.bor(EF_BONEMERGE,EF_NODRAW,EF_NOSHADOW)
		self.wmodel:AddEffects(meffects)
		self.wmodel:SetSkin(self:GetSkin())
	end

	function SWEP:DrawWorldModel()

		if IsValid(pl) and IsValid(self.wmodel) and IsValid(self.Owner) then

			self.wmodel:SetPoseParameter("panel", self:GetPoseParameter("panel"))
			self.wmodel:SetPoseParameter("block", self:GetPoseParameter("block"))

			if self.Owner == LocalPlayer() then
				self.wmodel:SetPoseParameter("spin", self.BarrelRotation)
			else
				local param = self:GetPoseParameter("spin")
				self.wmodel:SetPoseParameter("spin", param * 360)
			end

			self.wmodel:DrawModel()

		else
			timer.Simple(0, function() if self.BuildWModel then self:BuildWModel(self) end end)
			self:DrawModel()
		end

	end

	function SWEP:DrawHUD()
		self:DrawCrosshairs()
		self:DrawScreen()
	end

	-------------------------------------
	----------------Menu-----------------
	-------------------------------------

	SWEP.Menu = NULL

	function SWEP:IsMenuOpen()
		if IsValid(self.Menu) then
			return true
		end
	end

	SWEP.tips = { --TODO: don't think these are used at all anymore. Make them usable?

		"#scav.scavtips.acid",
		"#scav.scavtips.flamethrower",
		--"Some items allow you to zoom in. Click on the icon in the ACTIVE SLOT to activate zoom mode for that item.", TODO: Get this working again!
		"#scav.scavtips.zoom",
		"#scav.scavtips.scrollbinds",
		"#scav.scavtips.projectilecatch",
		"#scav.scavtips.delete",
		"#scav.scavtips.select",
		"#scav.scavtips.experiment",
		"#scav.scavtips.medkit",
		"#scav.scavtips.inf",
		"#scav.scavtips.passive",
		"#scav.scavtips.acid2",
		"#scav.scavtips.rocketjump",
		"#scav.scavtips.superphysjump",
		"#scav.scavtips.shower",
		"#scav.scavtips.crossfire"
	}

	local sh = ScrH()
	local sw = ScrW()

	local iconradius = 120

	local ITEMICON = {}
	ITEMICON.currentangle = 0
	ITEMICON.desiredangle = 0

	function ITEMICON:Init()
		self:SetAlpha(GetConVar("cl_scav_iconalpha"):GetFloat())
		self.item = nil
	end

	function ITEMICON:SetItem(item)
		self:SetModel(item:GetAmmoType(), item:GetData())
		self.item = item
	end

	function ITEMICON:GetItem()
		return self.item
	end

	function ITEMICON:Think()
		if not IsValid(self:GetParent()) then
			self:Remove()
		end
	end

	function ITEMICON:OnCursorEntered()
		self:SetAlpha(255)
	end

	function ITEMICON:OnCursorExited()
		self:SetAlpha(GetConVar("cl_scav_iconalpha"):GetFloat())
	end

	function ITEMICON:OnMousePressed(mc)
		if mc == MOUSE_LEFT then
			local amt = -self.pos
			RunConsoleCommand("scv_itm_shft", amt)
		elseif mc == MOUSE_RIGHT then
			RunConsoleCommand("scv_itm_rem", self.id)
		end
	end

	function ITEMICON:PaintOver()
		if self.item.subammo == SCAV_SHORT_MAX then
			draw.DrawText("#scav.scavcan.inf", "Scav_DefaultSmallDropShadow", 60, 52, color_white, TEXT_ALIGN_RIGHT) --∞
		else
			draw.DrawText(self.item.subammo, "Scav_DefaultSmallDropShadow", 60, 52, color_white, TEXT_ALIGN_RIGHT)
		end
	end

	vgui.Register("scavitemicon",ITEMICON,"spawnicon")

	local PANEL = {}
	PANEL.Weapon = NULL
	PANEL.iconradius = iconradius
	PANEL.angupdatesuppress = false

	function PANEL:Init()
		self.icons = {}
		self.iconids = {}
		self.Initialized = true
	end

	--allow mouse scrolling to move inventory while menu is open
	function PANEL:OnMouseWheeled(delta)
		if delta > 0 then
			RunConsoleCommand("scv_itm_shft",1)
			return true
		elseif delta < 0 then
			RunConsoleCommand("scv_itm_shft",-1)
			return true
		end
	end

	function PANEL:InvalidateLayout()
		if not self.Initialized then
			return
		end
	end

	function PANEL:Think()

		if not LocalPlayer():KeyDown(IN_RELOAD) then
			gui.EnableScreenClicker(false)
			for _,v in ipairs(self.icons) do
				if IsValid(v) then
					v:Remove()
				end
			end
			hook.Remove("HUDPaintBackground","Scav_Menu")
			self:Remove()
		end

		local delta = FrameTime()
		local w = self:GetWide()/2
		local h = self:GetTall()/2

		for _,icon in pairs(self.icons) do
			if icon.desiredangle then
				icon.currentangle = math.ApproachAngle(icon.currentangle,icon.desiredangle,delta * 720)
				icon:SetPos(w + math.cos(math.rad(icon.currentangle)) * self.iconradius - 32, h - math.sin(math.rad(icon.currentangle)) * self.iconradius - 48)
			end
		end
	end

	function PANEL:SetWeapon(wep)
		self.Weapon = wep
	end

	function PANEL:UpdateDesiredAngles()

		if self.angupdatesuppress then
			return
		end
		local itemnum = 0

		for _,v in pairs(self.Weapon.inv.items) do

			local icon = self.iconids[v.ID]

			if icon then
				icon.desiredangle = (itemnum) * 360 / self.Weapon:GetCapacity()
				icon.pos = itemnum
				icon:SetZPos(self.Weapon:GetCapacity() - itemnum)
				itemnum = itemnum + 1
			end

		end

	end

	function PANEL:RemoveIconByID(itemid)

		local icon = self.iconids[itemid]

		for k,v in pairs(self.icons) do
			if icon == v then
				table.remove(self.icons,k)
				break
			end
		end

		icon:Remove()
		self.iconids[itemid] = nil
		self:UpdateDesiredAngles()

	end

	function PANEL:AddIcon(item,itemid,pos)
		local icon = vgui.Create("scavitemicon", self)
		icon:SetItem(item)
		icon.id = itemid
		self.iconids[itemid] = icon
		table.insert(self.icons,pos or #self.icons + 1, icon)
		self:UpdateDesiredAngles()
		icon.currentangle = icon.desiredangle
		return icon
	end

	--local bkgcol = Color(50,50,50)

	function PANEL:Rebuild()

		for k,v in pairs(self.icons) do
			v:Remove()
			self.icons[k] = nil
		end

		for k,v in pairs(self.iconids) do
			self.iconids[k] = nil
		end

		local itemnum = 0
		self.angupdatesuppress = true

		for k,v in pairs(self.Weapon.inv.items) do
			local icon = self:AddIcon(v, v.ID)
			icon:SetZPos(self.Weapon:GetCapacity() - itemnum)
			icon.pos = itemnum
			icon.desiredangle = (itemnum) * 360 / self.Weapon:GetCapacity()
			icon.currentangle = icon.desiredangle
			itemnum = itemnum + 1
		end

		self.angupdatesuppress = false

	end

	function PANEL:AutoSetup()
		self:SetSize(320,350)
		self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetWide() / 2)
	end

	vgui.Register("scav_menu",PANEL,"DPanel")

	-- local triangle = {
	-- 	{ x = sw*.51+(iconradius-32), y = (sh+iconradius/2-32)*.5 },
	-- 	{ x = sw*.4975+(iconradius-32), y = (sh+iconradius/2-32)*.5125 },
	-- 	{ x = sw*.4975+(iconradius-32), y = (sh+iconradius/2-32)*.4875 }
	-- }

	function SWEP:OpenMenu()
		if not IsValid(self.Menu) then
			self.Menu = vgui.Create("scav_menu")
			self.Menu:SetSkin("sg_menu")
			self.Menu:SetWeapon(self)
			self.Menu:AutoSetup()
			self.Menu:Rebuild()
			self.Menu:SetVisible(true)
			self.Menu:MakePopup()
			self.Menu:SetKeyboardInputEnabled(false)
			--hook.Add("HUDPaintBackground","Scav_Menu",function()
				--better show our active item
				--surface.SetDrawColor( 50,50,50 )
				--draw.NoTexture()
				--draw.RoundedBoxEx(8,sw/2+iconradius-32,sh/2-32,64,64,bkgcol,true,true,true,false)
				--surface.DrawPoly(triangle)
			--end)
		end
	end

	-------------------------------------
	-------------View Punch--------------
	-------------------------------------

	local PLAYER = FindMetaTable("Player")

	ScavData.ViewPunches = {}

	function SWEP:SetViewLerp(oldangle,duration)
		duration = duration or 1
		self.ViewLerpTime = CurTime()
		self.ViewLerpDuration = duration
		self.ViewLerpAngles = oldangle
	end

	function SWEP:SetFOVLerp(oldfov,duration)
		duration = duration or 1
		self.FOVLerpTime = CurTime()
		self.FOVLerpDuration = duration
		self.FOVLerpValue = oldfov
	end

	net.Receive("scv_svl", function()
		local self = net.ReadEntity()
		if not self then
			return
		end
		self:SetViewLerp(net.ReadAngle(),net.ReadFloat())
	end)

	net.Receive("scv_sfl", function()
		local self = net.ReadEntity()
		if not self then
			return
		end
		self:SetFOVLerp(net.ReadFloat(),net.ReadFloat())
	end)

	function SWEP:CalcView(pl,origin,angles,fov)

		local totalviewpunch = nil

		if self.ViewLerpDuration ~= 0 then
			local ang = LerpAngle(math.Clamp((CurTime() - self.ViewLerpTime) / self.ViewLerpDuration, 0, 1), self.ViewLerpAngles, angles)
			angles = ang
			self.vm_angles = ang * 1
			if CurTime() - self.ViewLerpTime > self.ViewLerpDuration then
				self.ViewLerpDuration = 0
			end
		end

		if self.FOVLerpDuration ~= 0 then
			fov = Lerp(math.Clamp((CurTime() - self.FOVLerpTime) / self.FOVLerpDuration, 0, 1), self.FOVLerpValue, fov)
			if CurTime() - self.FOVLerpTime > self.FOVLerpDuration then
				self.FOVLerpDuration = 0
			end
		end

		if totalviewpunch then
			self.vm_angles = self.vm_angles + totalviewpunch
			angles = angles + totalviewpunch
		end

		return origin,angles,fov

	end

	function SWEP:GetViewModelPosition(pos,ang)
		local totalviewpunch = ang
		if self.Owner.viewpunch and (CurTime() - self.Owner.viewpunch.Created) < self.Owner.viewpunch.lifetime then
			local wat = (CurTime() - self.Owner.viewpunch.Created) / self.Owner.viewpunch.lifetime
			totalviewpunch = ang + self.Owner.viewpunch.angle * math.sin(math.sqrt(wat) * math.pi)
		end
		return pos, totalviewpunch
	end

	net.Receive("scv_vwpnch", function() LocalPlayer():ScavViewPunch(net.ReadAngle(), net.ReadFloat()) end)

	local function NewViewPunch(angles,duration)
		local tab = {}
		tab.angle = angles
		tab.lifetime = duration
		tab.Created = UnPredictedCurTime()
		return tab
	end

	function PLAYER:ScavViewPunch(angles,duration,freeze)
		if not self.ScavViewPunches then
			self.ScavViewPunches = {}
		end
		local vp = NewViewPunch(angles,duration)
		table.insert(self.ScavViewPunches,vp)
	end

	local totalviewpunch = Angle()
	local expiredVPs = {}

	hook.Add("CalcView","ScavViewPunch",function(pl,origin,angles,fov)
		if not pl.ScavViewPunches or pl ~= GetViewEntity() then return end
		local vpang = pl:GetCurrentScavViewPunch()
		angles.p = angles.p + vpang.p
		angles.y = angles.y + vpang.y
		angles.r = angles.r + vpang.r
	end)

	function PLAYER:GetCurrentScavViewPunch(dodebug)

		if not self.ScavViewPunches then
			self.ScavViewPunches = {}
		end

		local angles = Angle(0,0,0)

		totalviewpunch.p = 0
		totalviewpunch.y = 0
		totalviewpunch.r = 0

		for k,v in pairs(self.ScavViewPunches) do
			local progress = (UnPredictedCurTime() - v.Created) / v.lifetime
			if progress > 1 then
				table.insert(expiredVPs,k)
			else
				local progress = math.Clamp(progress, 0, 1)
				local multiplier = math.sin(math.sqrt(progress) * math.pi)
				totalviewpunch.p = totalviewpunch.p + multiplier * v.angle.p
				totalviewpunch.y = totalviewpunch.y + multiplier * v.angle.y
				totalviewpunch.r = totalviewpunch.r + multiplier * v.angle.r
			end
		end

		local numexpVPs = #expiredVPs
		for i=0,numexpVPs - 1 do
			table.remove(self.ScavViewPunches, expiredVPs[numexpVPs - i])
			expiredVPs[numexpVPs - i] = nil
		end

		totalviewpunch.p = math.Max(-90 - angles.p, totalviewpunch.p)
		totalviewpunch.p = math.Min(90 - angles.p, totalviewpunch.p)

		angles.p = angles.p + totalviewpunch.p
		angles.y = angles.y + totalviewpunch.y
		angles.r = angles.r + totalviewpunch.r

		self.LastScavVPAngle = angles * 1
		self.LastScavViewPunchCalc = CurTime()

		return angles

	end

end

-----------------------------------------------------------------------------------------
---------------------------------------Server Code---------------------------------------
-----------------------------------------------------------------------------------------

if SERVER then

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
		if IsValid(wep) then
			wep:SetNWLevel(math.max(self:GetNWLevel(),wep:GetNWLevel()))
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
			self:SetNWLevel(math.max(self.Owner:GetPlayerScavLevel(), self:GetNWLevel()))
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

		local availableslots = self:GetCapacity() - self.inv:GetItemCount()

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

		if availableslots == self:GetCapacity() and modeinfo then
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

		self:SaveInventorySnapshot()
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
			self:SaveInventorySnapshot()
		end

	end

	concommand.Add("scv_itm_rem", CMDRemoveItem)

	function SWEP:UpdateTransmitState()
		return TRANSMIT_NEVER
	end

	function SWEP:AddBarrelSpin(speed)
		--self:SetBarrelSpinSpeed(self:GetBarrelSpinSpeed() + speed)
		--self:SetBarrelSpinSpeed(math.Clamp(self:GetBarrelSpinSpeed(), -1440, 1440))
		self:SetBarrelSpinSpeed(math.Clamp(self:GetBarrelSpinSpeed() + speed, -1440, 1440))
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
			self:SetCanScav(false)
		else
			if tr.Entity ~= self.lastlookent then
				self.lastlookentcanscav = self:CheckCanScav(tr.Entity)
				self.lastlookent = tr.Entity
			end
			if IsValid(tr.Entity) then
				self:SetCanScav(self.lastlookentcanscav)
			else
				self:SetCanScav(false)
			end
		end

		if not self.Owner:KeyDown(IN_ATTACK) then
			self.Inaccuracy = math.Max(1, self.Inaccuracy - 10 * FrameTime())
		end

		self:SetBarrelSpinSpeed(math.Approach(self:GetBarrelSpinSpeed(), self.BarrelRestSpeed, 600 * FrameTime()))
		self.BarrelRotation = (self.BarrelRotation + self:GetBarrelSpinSpeed() * FrameTime()) % 360

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
			local cooldown = self:ChargeAttack(item) * self:GetCooldownScale()

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

		if game.SinglePlayer() then
			self:CallOnClient("Think")
		end

		self.LastThink = CurTime()
		return true

	end

	function SWEP:SaveInventorySnapshot()
		if self.inv and IsValid(self.Owner) then
			saverestore.AddSaveHook("scavsave_"..self.Owner:SteamID64(), function(save)
				saverestore.WriteTable(self.inv,save)
				saverestore.SaveEntity(self,save)
				print(save)
			end)
		end
	end

	function SWEP:OnRestore()
		self.nextfire = 0
		self.nextfireearly = 0

		saverestore.AddRestoreHook("scavsave_"..self.Owner:SteamID64(), function(save)
			local savedinv = saverestore.ReadTable(save)
			if savedinv then
				self.inv = savedinv
			end
		end)

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

		self:SetBarrelSpinSpeed(0)
		self.BarrelRestSpeed = 0
		self.BarrelRotation = 0

		if game.SinglePlayer() then
			self:CallOnClient("Deploy")
		end

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

			if game.SinglePlayer() then
				self:CallOnClient("Holster")
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

		if not IsValid(tr.Entity) or tr.HitWorld then
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

			if ScavData.models[item.ammo] and ScavData.models[item.ammo].Level > self:GetNWLevel() then
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

				local cooldown = ScavData.models[self.currentmodel].Cooldown * self:GetCooldownScale()

				if ScavData.models[self.currentmodel].anim then
					self:SendWeaponAnim(ScavData.models[self.currentmodel].anim)
					if not self.ChargeAttack then
						self:SetSeqEndTime(shoottime + math.min(self.Owner:GetViewModel():SequenceDuration(), cooldown))
					end
				end

				self:SaveInventorySnapshot()
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
						phys:SetVelocity(self:GetAimVector() * 2000 * self:GetForceScale())
						phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
						mass = mass + phys:GetMass()
					end
				end

				self.nextfire = shoottime+(math.sqrt(mass) * 0.05) * self:GetCooldownScale()
				self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				EntReaper.AddDyingEnt(prop,10)
				prop:CallOnRemove("scavdeath",deathshit)
				hook.Add("PropBreak","ScavPropDeathEffectCheck",function(client,prp)
					prp:RemoveCallOnRemove("scavdeath")
				end)
				self:SetSeqEndTime(self.nextfire - 0.1)
				self:RemoveItem(1)
				self.Owner:EmitSound(self.shootsound, 100, math.Clamp(120 - (self.nextfire - CurTime()) * 50, 30, 255))

				self:SaveInventorySnapshot()

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

		if game.SinglePlayer() then
			self:CallOnClient("PrimaryAttack")
		end

	end

	function SWEP:CheckCanScav(ent)
		if self.inv:GetItemCount() < self:GetCapacity() and self.Owner:CanScavPickup(ent) then
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
		self:SaveInventorySnapshot()

		return true

	end
	
end

include("firemodes.lua") --load last
