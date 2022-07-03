local SWEP = SWEP
SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/scav/c_alchgun.mdl"
SWEP.WorldModel = "models/weapons/scav/c_alchgun.mdl"
SWEP.UseHands = true

SWEP.AdminSpawnable = true
SWEP.Primary.Clipsize = 0
SWEP.Primary.Defaultclip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.Defaultclip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ammo = 0
SWEP.PanelPose = 0
SWEP.DragVMin = Vector(-16,-16,-16)
SWEP.DragVMax = Vector(16,16,16)

PrecacheParticleSystem("alch_spawn")
PrecacheParticleSystem("alch_ghost")

AddCSLuaFile("surfaces.lua")
AddCSLuaFile("ghost.lua")
AddCSLuaFile("meltdown.lua")
AddCSLuaFile("menu.lua")

include("surfaces.lua")
include("ghost.lua")
include("meltdown.lua")

SWEP.StockProps = {
					{["model"] = "models/props_debris/metal_panel02a.mdl", ["skin"] = 0},
					{["model"] = "models/items/boxsrounds.mdl", ["skin"] = 0},
					{["model"] = "models/items/boxmrounds.mdl", ["skin"] = 0},
					{["model"] = "models/items/boxbuckshot.mdl", ["skin"] = 0},
					{["model"] = "models/props_c17/doll01.mdl", ["skin"] = 0},
					{["model"] = "models/props_c17/canister_propane01a.mdl", ["skin"] = 0},
					{["model"] = "models/props_junk/propanecanister001a.mdl", ["skin"] = 0},
					{["model"] = "models/props_junk/gascan001a.mdl", ["skin"] = 0},
					{["model"] = "models/props_c17/oildrum001_explosive.mdl", ["skin"] = 0},
					{["model"] = "models/combine_helicopter/helicopter_bomb01.mdl", ["skin"] = 0},
					{["model"] = "models/props_junk/popcan01a.mdl", ["skin"] = 0},
					{["model"] = "models/weapons/w_missile_closed.mdl", ["skin"] = 0},
					{["model"] = "models/weapons/w_slam.mdl", ["skin"] = 0},				
					{["model"] = "models/healthvial.mdl", ["skin"] = 0},
					{["model"] = "models/items/healthkit.mdl", ["skin"] = 0},
					{["model"] = "models/roller.mdl", ["skin"] = 0},
					{["model"] = "models/items/car_battery01.mdl", ["skin"] = 0},
					{["model"] = "models/weapons/w_stunbaton.mdl", ["skin"] = 0},
					--{["model"] = "models/props_c17/substation_transformer01d.mdl", ["skin"] = 0},
					{["model"] = "models/weapons/w_physics.mdl", ["skin"] = 0},
					{["model"] = "models/props_junk/sawblade001a.mdl", ["skin"] = 0},
					{["model"] = "models/props_junk/cinderblock01a.mdl", ["skin"] = 0},
					{["model"] = "models/props_vehicles/tire001c_car.mdl", ["skin"] = 0},
					{["model"] = "models/props_borealis/bluebarrel001.mdl", ["skin"] = 0},
					{["model"] = "models/props_wasteland/controlroom_filecabinet001a.mdl", ["skin"] = 0} 
					}

for k,v in pairs(SWEP.StockProps) do
	util.PrecacheModel(v.model)
end

function SWEP:Initialize()
	self.LearnedProps = {}
	self.HoldSound = CreateSound(self,"weapons/physcannon/hold_loop.wav")
	self:SetHoldType("melee2") --TODO: change its model up and get this on a more reasonable 3rd person anim (shotgun, ar2, etc)
	if SERVER then
		self.CreatedItems = {}
	elseif LocalPlayer () == self.Owner then
		self:Deploy()
	end
	if game.SinglePlayer() then
		self:CallOnClient("Initialize")
	end
end

function SWEP:Think()
	if self.M1Down and not self.Owner:KeyDown(IN_ATTACK) then
		self:SetGhosting(false)
		self.M1Down = false
		self:PrimaryRelease()
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	end
	if self.endlock ~= 0 and (self.endlock < CurTime()) then
		self.endlock = 0
		self:OnUnlock()
	end
	if SERVER then
		if self:GetGhosting() then
			self.PanelPose = math.Approach(self.PanelPose,1,FrameTime()*5)
		else
			self.PanelPose = math.Approach(self.PanelPose,0,FrameTime()*5)
		end
		self.Owner:GetViewModel():SetPoseParameter("panel",self.PanelPose)
	else
		self.HUD:SetVisible(true)
		self.HUD:SetWeapon(self)
	end
	if game.SinglePlayer() then
		self:CallOnClient("Think")
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool",0,"Ghosting")
	self:NetworkVar("Float",0,"Ammo1")
	self:NetworkVar("Float",1,"Ammo2")
	self:NetworkVar("Float",2,"Ammo3")
	self:NetworkVar("Float",3,"Ammo4")
end

function SWEP:GetAmmo(slot)
	return self:GetDTFloat(slot)
end

function SWEP:SetAmmo(slot,amount)
	self:SetDTFloat(slot,amount)
end

SWEP.startlock = 0
SWEP.endlock = 0

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
	self:CancelGhosting()
	self:SendWeaponAnim(ACT_VM_FIDGET)
	if SERVER then
		if IsValid(self.BrokenEffect) then
			self.BrokenEffect:Kill()
		end
		local ef = ents.Create("scav_stream_alchoverload")
		ef:SetOwner(self)
		ef:Spawn()
		self.BrokenEffect = ef
	end
end

function SWEP:OnUnlock()
	if SERVER then
		if IsValid(self.BrokenEffect) then
			self.BrokenEffect:Kill()
		end
	end
	self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:IsLocked()
	return (self.endlock > CurTime() and self.startlock <= CurTime())
end

function SWEP:PrimaryAttack()
	local model = self.Owner:GetInfo("scav_ag_model")
	local skin = tonumber(self.Owner:GetInfo("scav_ag_skin"))
	local modelinfo = self:GetAlchemyInfo(model)
	local surfaceinfo = self:GetSurfaceInfo(modelinfo.material)
	if self:IsLocked() or not self:KnowsItem(model,skin) or (self:GetAmmo1() < surfaceinfo.metal*modelinfo.mass) or (self:GetAmmo2() < surfaceinfo.chem*modelinfo.mass) or (self:GetAmmo3() < surfaceinfo.org*modelinfo.mass) or (self:GetAmmo4() < surfaceinfo.earth*modelinfo.mass) then
		return false
	end
	if self.Owner:KeyDown(IN_ATTACK2) then
		if SERVER then
			self:CancelGhosting()
		end
		return
	end
	if not self.M1Down then
		if not util.IsValidProp(model) and not util.IsValidRagdoll(model) then
			return
		end
		self.M1Down = true
		self:SetGhosting(true)
		self:SendWeaponAnim(ACT_VM_FIDGET)
		if SERVER then
			self.Ghost = ents.Create("scav_alchghost")
			self.Ghost.Weapon = self
			self.Ghost:SetModel(model)
			self.Ghost:SetOwner(self.Owner)
			self.Ghost:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*64)
			self.Ghost:SetAngles(self.Owner:GetAimVector():Angle())
			self.Ghost.AlchGun = {
				["gun"]=self,
				["owner"]=self:GetOwner()
			}
			self.Ghost:Spawn()
			if SERVER then
				if IsValid(self.ActiveEffect) then
					self.ActiveEffect:Kill()
				end
				local ef = ents.Create("scav_stream_alchactive")
				ef:SetOwner(self)
				ef:Spawn()
				self.ActiveEffect = ef
			end
		end
		self.HoldSound:Play()
	end
	if game.SinglePlayer() then
		self:CallOnClient("PrimaryAttack")
	end
end

function SWEP:PrimaryRelease()
	if self:IsLocked() then
		return false
	end
	if SERVER and IsValid(self.Ghost) then
		local model = self.Ghost:GetModel()
		local modelinfo = self:GetAlchemyInfo(model)
		local surfaceinfo = self:GetSurfaceInfo(modelinfo.material)
		self:SetAmmo1(self:GetAmmo1()-surfaceinfo.metal*modelinfo.mass)
		self:SetAmmo2(self:GetAmmo2()-surfaceinfo.chem*modelinfo.mass)
		self:SetAmmo3(self:GetAmmo3()-surfaceinfo.org*modelinfo.mass)
		self:SetAmmo4(self:GetAmmo4()-surfaceinfo.earth*modelinfo.mass)
		local prop
		local ragdoll = false
		if util.IsValidRagdoll(model) then
			prop = ents.Create("prop_ragdoll")
			ragdoll = true
		else
			prop = ents.Create("prop_physics")
		end
		prop:SetModel(model)
		prop:SetPos(self.Ghost:GetPos())
		prop:SetAngles(self.Ghost:GetAngles())
		self.Ghost:SetParent(prop)
		self.Ghost:AddEffects(EF_BONEMERGE)
		SafeRemoveEntityDelayed(self.Ghost,1)
		prop:Spawn()
		prop:GetPhysicsObject():SetVelocity(self.Ghost:GetVelocity())
		prop:SetPhysicsAttacker(self.Owner)
		prop.AlchGun = {
			["gun"]=self,
			["owner"]=self:GetOwner()
		}
		SuppressHostEvents(NULL)
		--ParticleEffectAttach("alch_spawn",PATTACH_ABSORIGIN_FOLLOW,prop,0)
		SuppressHostEvents(self.Owner)
		self:AddItem(prop)
		self:KillGhost()
		if ragdoll then
			gamemode.Call("PlayerSpawnedRagdoll",self.Owner,model,prop)
		else
			gamemode.Call("PlayerSpawnedProp",self.Owner,model,prop)
		end
	end
	self.HoldSound:Stop()
end

local dragtrace = {}
dragtrace.mask = MASK_SHOT

function SWEP:SecondaryAttack()
	if self:IsLocked() or IsValid(self.MeltdownEnt) then
		return false
	end
	self:CancelGhosting()
	if CLIENT then
		return
	end
	local tr = self.Owner:GetEyeTraceNoCursor()
	local ent = tr.Entity
	if not tr.Entity:IsValid() or tr.HitWorld then
		local tracep = {}
			tracep.start = self.Owner:GetShootPos()
			tracep.endpos = self.Owner:GetShootPos()+self.Owner:GetAimVector()*56100*FrameTime()
			tracep.filter = {self.Owner,game.GetWorld()}
			tracep.mask = MASK_SHOT
			tracep.mins = self.vmin1
			tracep.maxs = self.vmax1
		tr = util.TraceHull(tracep)
		ent = tr.Entity
	end
	if not ent or not ent:IsValid() then
		return false
	end
	local phys = ent:GetPhysicsObject()
	if tr.StartPos:Distance(tr.HitPos) > 100 then
		if phys:IsValid() then
			phys:ApplyForceOffset(tr.Normal*-33000*FrameTime(),tr.HitPos)
		end
	elseif self:CheckCanScav(ent) then
		self.MeltdownEnt = ents.Create("scav_alchmelt")
		self.MeltdownEnt:SetPos(ent:GetPos())
		self.MeltdownEnt:SetAngles(ent:GetAngles())
		self.MeltdownEnt:SetProp(ent)
		self.MeltdownEnt:SetWeapon(self)
		self.MeltdownEnt:Spawn()
	end
end

function SWEP:KillGhost()
	self.HoldSound:Stop()
	self.Ghost = NULL
	self.M1Down = false
	self:SetGhosting (false)
	if IsValid(self.ActiveEffect) then
		self.ActiveEffect:Kill()
	end
end

function SWEP:CancelGhosting(suppressanim)
	if SERVER then
		if IsValid(self.Ghost) and not self.Ghost.Killed then
			timer.Simple(0, function() ParticleEffectAttach("alch_fizzle",PATTACH_ABSORIGIN_FOLLOW,self.Ghost,0) end)
			self.Ghost:SetSolid(SOLID_NONE)
			self.Ghost:Fire("Kill",nil,0.3)
		end
	end
	if not suppressanim then
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
	if self.M1Down then
		self:EmitSound("weapons/physcannon/physcannon_claws_close.wav")
	end
	self:KillGhost()
end

function SWEP:Holster()
	if self:IsLocked() then
		return false
	end
	self:CancelGhosting(true)
	if CLIENT then
		self:DestroyWModel()
		self:CloseMenu()
		self.HUD:SetVisible(false)
	end
	if game.SinglePlayer() then
		self:CallOnClient("Holster")
	end
	return true
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DEPLOY)
end

function SWEP:OnRemove()
	if CLIENT then
		self:DestroyWModel()
		self.Menu:ForgetModels()
		self.HUD:SetVisible(false)
	else
		self:DestroyAllItems()
	end
	self:CancelGhosting()
end

function SWEP:KnowsItem(model,skin)
	for k,v in pairs(self.StockProps) do
		if (v.model == model) and (v.skin == skin) then
			return true
		end
	end
	for k,v in pairs(self.LearnedProps) do
		if (v.model == model) and (v.skin == skin) then
			return true
		end
	end
	return false
end

if SERVER then
	util.AddNetworkString("scav_ag_lrn")
end

function SWEP:LearnItem(model,skin)
	if not self:KnowsItem(model,skin) then
		table.insert(self.LearnedProps,{
			["model"] = model,
			["skin"] = skin
			}
		)
		if SERVER then
			net.Start("scav_ag_lrn")
				net.WriteEntity(self)
				net.WriteString(model)
				net.WriteInt(skin,9)
			net.Send(self.Owner)
		else
			self.Menu:AddModel(model,skin,false)
		end
	end
end

if CLIENT then
	net.Receive("scav_ag_lrn",function()
		local self = net.ReadEntity()
		local model = net.ReadString()
		local skin = net.ReadInt(9)
		if IsValid(self) then
			self:LearnItem(model,skin)
		end
	end)
end
