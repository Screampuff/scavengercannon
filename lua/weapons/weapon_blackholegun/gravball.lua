local ENT = {}
ENT.Type = "anim"
ENT.Base = "base_anim"
local cbmin = Vector(-12,-12,-12)
local cbmax = Vector(12,12,12)
local color_red = Color(255,0,0,255)

function ENT:Initialize()
	self:AddEffects(EF_NOSHADOW)
	if SERVER then
		self.WayPoints = self.WayPoints||{}
		self:PhysicsInitSphere(1)
		self:SetSolid(SOLID_NONE)
		self:StartMotionController()
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:GetPhysicsObject():EnableGravity(false)
		self:GetPhysicsObject():SetDragCoefficient(12000)
		self:GetPhysicsObject():SetDamping(10000,0)
		self:GetPhysicsObject():Wake()
		self.SoundLoop = CreateSound(self,"ambient/levels/citadel/zapper_ambient_loop1.wav")
		self.SoundLoop:Play()
		self:SetCollisionBounds(cbmin,cbmax)
		self:SetTrigger(true)
	else
		if CLIENT then
			ParticleEffectAttach("scav_bhg_charge",PATTACH_ABSORIGIN_FOLLOW,self,0)
		end
	end
end

function ENT:SetupDataTables()
	self:DTVar("Float",0,"Charge")
end

function ENT:Think()
	if SERVER then
		//local dest = self:GetCurrentDestination()
		//if dest:Distance() < 400 then
		if !IsValid(self.WayPoint) && !self.Killed then
			self:Kill()
		end
		self:GetPhysicsObject():Wake()
	else
		//self:PerformPull() --this is somewhat too performance intensive.. maybe a convar
	end
end

function ENT:PerformPull()
	local speed
	if SERVER && self.Killed then
		speed = math.max(1200)
	else
		speed = math.max(200,self:GetVelocity():Length()*1.4)
	end
	local velmultiplier = speed*FrameTime()
	local ctime = CurTime()
	local pos = self:GetPos()
	for k,v in pairs(ents.FindInSphere(pos,300)) do
		if IsValid(v) && (v:GetMoveType() == MOVETYPE_VPHYSICS) && v:GetPhysicsObject():IsValid() && (v:GetClass() != "scav_gravball") then
			for i=0,v:GetPhysicsObjectCount()-1 do
				v:GetPhysicsObjectNum(i):SetVelocity((pos-v:GetPos()-v:OBBCenter())*velmultiplier)
			end
			if SERVER then
				if !v.GravBall || (v.GravBall.ball == self) then --this is for kill data
					v.GravBall = {
						["ball"]=self,
						["gun"]=self.BHG,
						["owner"]=self:GetOwner(),
					}
				end
				v.GravBall.PullTime = ctime
				v:SetPhysicsAttacker(self:GetOwner())
			end
		end
	end
end

if CLIENT then
	local chargemat = Material("effects/scav_shine_HR")
	local glowcol = Color(255,64,64,255)

	function ENT:GetChargeglowScale()
		if self.Killed then
			return 0
		end
		local ctime = CurTime()
		local refvar = self.Created
		local scale = math.max(0,math.Round(self.dt.Charge/150*15*(math.abs(math.sin(ctime*64))+1)))
		return scale
	end
	
	function ENT:Draw()
		local pos = self:GetPos()
		render.SetMaterial(chargemat)
		local scale = self:GetChargeglowScale()
		render.DrawSprite(pos,scale,scale,glowcol)
	end

else

	function ENT:SetCharge(charge)
		self.dt.Charge = charge
		self:Fire("Kill",nil,charge/25)
		util.SpriteTrail(self,0,color_red,false,22,0,6*charge/250,1/11,"trails/laser.vmt")
	end
	
	hook.Add("EntityTakeDamage","BHGCredit",function(victim,dmginfo)
		local inflictor = dmginfo:GetInflictor()
		local attacker = dmginfo:GetAttacker()
		local amount = dmginfo:GetDamage()
		if (inflictor.GravBall) then
			local gb=inflictor.GravBall
			if gb.owner != inflictor:GetPhysicsAttacker() then --If the attacker wasn't us, caused by something moving the object after the gravball has, we're no longer interested.
				return
			end
			if IsValid(gb.gun) then
				dmginfo:SetInflictor(gb.gun)
			elseif IsValid(gb.ball) then
				dmginfo:SetInflictor(gb.ball)
			end
			if IsValid(gb.owner) then
				dmginfo:SetAttacker(gb.owner)
			end
		end
	end)

	function ENT:OnRemove()
		self.SoundLoop:Stop()
		if SERVER && IsValid(self.WayPoint) then
			self.WayPoint:DestroyPath()
		end
	end

	function ENT:Kill()
		if self.Killed then
			return
		end
		self.Killed = true
		//self:GetPhysicsObject():SetVelocity(Vector(0,0,0))
	end

	function ENT:Touch(hitent)
		if self.WayPoints[1] && (self.WayPoints[1] == hitent) then
			self:AdvanceWaypoint()
		end
	end
	
	function ENT:SetWaypoint(waypoint)
		if IsValid(self.WayPoint) then
			self.WayPoint.GravBall = nil
		end
		self.WayPoint = waypoint
		waypoint.GravBall = self
	end
	
	function ENT:AdvanceWaypoint()
		if !IsValid(self.WayPoint) then
			self:Kill()
		elseif IsValid(self.WayPoint.dt.waypointNext) then
			local nextwaypoint = self.WayPoint.dt.waypointNext
			self.WayPoint.GravBall = nil
			SafeRemoveEntityDelayed(self.WayPoint,0)
			self.WayPoint = nextwaypoint
			self.WayPoint.GravBall = self
		end
	end
	
	function ENT:GetCurrentDestination()
		local wp = self.WayPoint
		if !IsValid(wp) then
			return self:GetPos()
		end
		return wp:GetPos()
	end
	
	function ENT:PhysicsUpdate()
	end

	function ENT:PhysicsSimulate(phys,deltatime)
		local linearforce
		local dest = self:GetCurrentDestination()
		local dir = dest-self:GetPos()
		local length = dir:Length()
		//local acc = math.max(1000,10000/length)
		acc = 200000
		dir = dir:GetNormalized()
		
		if length < 50 then
			self:AdvanceWaypoint()
			self:SetPos(dest)
		else
			linearforce = dir*acc*deltatime
		end
		local decellerationforce = (phys:GetVelocity()*phys:GetMass())
		return Vector(0,0,0), (linearforce||Vector(0,0,0))-(decellerationforce/deltatime*0.025), SIM_GLOBAL_ACCELERATION
	end
	
	hook.Add("Tick","BHGPull",function() for k,v in pairs(ents.FindByClass("scav_gravball")) do v:PerformPull() end end)
end

scripted_ents.Register(ENT,"scav_gravball",true)