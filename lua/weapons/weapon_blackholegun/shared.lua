include("gravball.lua")
include("waypointwarning.lua")
include("pickup.lua")

SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Slot = 2
SWEP.SlotPos = 0

SWEP.ViewModel = "models/weapons/scav/c_bhg.mdl"
SWEP.WorldModel = "models/weapons/scav/c_bhg.mdl"
SWEP.UseHands = true

SWEP.Primary.Clipsize = 0
SWEP.Primary.Defaultclip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.Defaultclip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.BeginIdle = 0
SWEP.ChargeTime = 0
SWEP.MaxCharge = 250
SWEP.Charge = 0
SWEP.LastCharge = 0
SWEP.ChargeRate = 100

local tracep = {}
tracep.mask = MASK_SHOT
tracep.mins = Vector(-4,-4,-4)
tracep.maxs = Vector(4,4,4)

function SWEP:GetTrace()
	self.Owner:LagCompensation(true)
	tracep.filter = self.Owner
	tracep.start = self.Owner:GetShootPos()
	tracep.endpos = tracep.start+self.Owner:GetAimVector()*8000
	local tr = util.TraceHull(tracep)
	self.Owner:LagCompensation(false)
	return tr
end

local function waypointiterate(startent,currentent)
	if IsValid(currentent:GetwaypointNext()) then
		return currentent:GetwaypointNext()
	end
end

function SWEP.WaypointIterate(startent)
	return waypointiterate, startent, startent
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"Ammo")
	self:NetworkVar("Int",1,"MaxAmmo")
	self:NetworkVar("Int",2,"WaypointCount")
	self:NetworkVar("Int",3,"MaxWaypoints")
	self:NetworkVar("Entity",0,"waypointNext")
	self:SetMaxAmmo(1000)
	self:SetMaxWaypoints(4)
end

function SWEP:Initialize()
	self:SetHoldType("crossbow")
	if SERVER then
		self.WayPoints = {}
	end
end

function SWEP:ViewmodelAnimation(anim)
	self:SendWeaponAnim(anim)
	self.BeginIdle = CurTime()+self.Owner:GetViewModel():SequenceDuration()
end

function SWEP:GetAmmo(predicted)
	if CLIENT then
		if self.LastDTAmmo < self:GetAmmo() then
			self.Ammo = self:GetAmmo()
		end
		self.LastDTAmmo = self:GetAmmo()
		return self.Ammo
	end
	return self:GetAmmo()
end

function SWEP:GetMaxAmmo()
	return self:GetMaxAmmo()
end

function SWEP:TakeAmmo(amt)
	if CLIENT then
		self.Ammo = math.max(self.Ammo-amt,0)
	else
		self:SetAmmo(math.max(self:GetAmmo()-amt,0))
	end
end

function SWEP:GetCharge()
	return self.Charge
end

function SWEP:SetNextFire(time)
	self:SetNextPrimaryFire(time)
	self:SetNextSecondaryFire(time)
end

function SWEP:Think()
	local ctime = CurTime()
	if (self.ChargeTime ~= 0) then
		if (self:GetAmmo() > 0) and IsFirstTimePredicted() then
			self.Charge = math.Clamp(self.Charge+FrameTime()*self.ChargeRate,0,self.MaxCharge)
			if math.floor(self.Charge) > self.LastCharge then
				--if SERVER then
					self:TakeAmmo(math.floor(self.Charge-self.LastCharge))
				--end
				self.LastCharge = math.floor(self.Charge)
			end
		end
		if SERVER then
			self.SoundCharge:ChangePitch((self.Charge/self.MaxCharge)*254+1)
			if IsValid(self.ChargeEffect) then
				self.ChargeEffect:SetCharge(self.Charge/self.MaxCharge)
			end
		end
		if not self.Owner:KeyDown(IN_ATTACK) and (self.Charge >= 50) then
			self:PrimaryRelease()
		end
	elseif (self.BeginIdle ~= 0) and (self.BeginIdle < ctime) then
		self:ViewmodelAnimation(ACT_VM_IDLE)
		--self.BeginIdle = 0
	end	
end

function SWEP:Reload()
	if SERVER and self.Owner:KeyPressed(IN_RELOAD) and (self.ChargeTime ~= 0) then
		local tr = self:GetTrace()
		if tr.Hit and tr.HitPos then
			self:AddWaypoint(tr.Entity,tr.Entity:WorldToLocal(tr.HitPos))
		end
	end
end

function SWEP:PrimaryAttack()
	if (self.ChargeTime == 0) and (self:GetAmmo() >= 50) and IsFirstTimePredicted() then
		if SERVER then
			self.SoundRattle:PlayEx(50,170)
			self.SoundCharge:Play()
			local ef = ents.Create("scav_stream_bhgcharge")
				ef:SetOwner(self)
				ef:Spawn()
				self.ChargeEffect = ef
		end
		self:SendWeaponAnim(ACT_VM_FIDGET)
		self.ChargeTime = CurTime()
		self.LastCharge = 0
		
	end
end



function SWEP:PrimaryRelease()
	self:ViewmodelAnimation(ACT_VM_PRIMARYATTACK)
	if not IsFirstTimePredicted() then
		return
	end
	local tr = self:GetTrace()

	local charge = math.floor(self.Charge)
	if SERVER then
		self.SoundRattle:Stop()
		self.SoundCharge:Stop()
		util.ScreenShake(self.Owner:GetShootPos(),charge/20,5,2,4000)
		if IsValid(self.ChargeEffect) then
			self.ChargeEffect:Kill()
		end
		local proj = ents.Create("scav_gravball")
		local eyeang = self.Owner:GetAimVector():Angle()
		local right = eyeang:Right()
		local up = eyeang:Up()
		proj:SetPos(self.Owner:GetShootPos()+right*2-up*2)
		proj:SetOwner(self:GetOwner())
		proj.BHG = self
		proj:Spawn()
		proj:SetCharge(charge)
		if tr.Entity == NULL then
			tr.Entity = game.GetWorld()
		end
		if not IsValid(self:GetwaypointNext()) then
			self:AddWaypoint(tr.Entity,tr.Entity:WorldToLocal(tr.HitPos))
		end
		local waypoint = self:GetwaypointNext()
		proj:SetWaypoint(waypoint)
		waypoint:SetwaypointPrevious(NULL)
		self:DetachFromWaypointPath() --cut ourselves off from the chain, it's independant now
		proj:GetPhysicsObject():SetVelocity(self.Owner:GetAimVector()*1300)
	end
	self:EmitSound("ambient/energy/ion_cannon_shot1.wav",100,255-(charge/1.2))
	self.ChargeTime = 0
	self.Charge = 0
	self.LastCharge = 0
	--self:SetNextFire(CurTime()+0.5)
end

local dragtrace = {}
dragtrace.mask = MASK_SHOT

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(),CurTime()+1))
	if (self.ChargeTime ~= 0) or CLIENT then
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
		self:Scavenge(ent)
	end
end

local screenresetondeploy

if SERVER then
	screenresetondeploy = function(ent)
		if IsValid(ent) then
			ent:CallOnClient("ResetScreen","")
		end
	end
end

function SWEP:Deploy()
	self:ViewmodelAnimation(ACT_VM_DEPLOY)
	if SERVER then
		if game.SinglePlayer() or self.FirstDeploy then
			timer.Simple(0.1, function() screenresetondeploy(self) end)
			self.FirstDeploy = false
		end
		self.SoundRattle = CreateSound(self.Owner,"ambient/machines/train_wheels_loop1.wav")
		self.SoundCharge = CreateSound(self.Owner,"ambient/levels/labs/teleport_active_loop1.wav")
	end
	if CLIENT then
		self.DeployedTime = CurTime()
	end
end

function SWEP:OnRemove()
	if SERVER then
		self:DestroyWaypoints()
		self.SoundRattle:Stop()
		self.SoundCharge:Stop()
	end
end

function SWEP:Holster()
	if self.Owner:KeyDown(IN_ATTACK) then
		return false
	end
	if SERVER then
		self.SoundRattle:Stop()
		self.SoundCharge:Stop()
	end
	return true
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
