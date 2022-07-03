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

AddCSLuaFile("client.lua")
AddCSLuaFile("server.lua")
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

	if game.SinglePlayer() then
		self:CallOnClient("Initialize")
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

include("client.lua")
include("server.lua")

--Load last
include("firemodes.lua")
