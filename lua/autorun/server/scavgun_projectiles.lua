s_proj 				= {}
s_proj.Version 		= 1.1
s_proj.proj 		= {}
s_proj.callbacks 	= {} -- we'll keep callbacks here for convenience
wspawn 				= ents.FindByClass("worldspawn")[1]

local lastplayer = NULL
local CurTimeOld = CurTime
local function CurTimeBacktrack()
	return tonumber(lastplayer:GetInfo("~l2")) or CurTimeOld()
end

CreateConVar("sv_gprojectile_lagcompensation", 0, FCVAR_ARCHIVE) -- this is experimental, feel free to try playing with this on but there are a few bugs

function ProjectileLagCompensation(pl)

	if (pl ~= NULL) and type(pl) ~= "Player" then
		error("bad argument #1 to 'LagCompensation' (expected Player, got "..type(pl)..")", 2)
	end
	
	lastplayer = pl
	
	if pl ~= NULL and GetConVar("sv_gprojectile_lagcompensation"):GetBool() then
		CurTime = CurTimeBacktrack
	else
		CurTime = CurTimeOld
	end
	
end

local Projectile = {}

function Projectile:Constructor()

	local proj = {}
	table.Inherit(proj,self)
	
	proj.Owner 				= NULL
	proj.Inflictor 			= NULL
	proj.pos 				= vector_origin * 1
	proj.velocity 			= vector_origin * 1
	proj.pierce 			= false
	proj.gravity 			= vector_origin * 1
	proj.mins 				= vector_origin * 1
	proj.maxs 				= vector_origin * 1
	proj.mask 				= MASK_SHOT
	proj.LagCompensated 	= true
	proj.MaxRange 			= 0
	proj.filter				= {}
	
	--INTERNAL VALUES-- 
	proj.DistanceTraveled 	= 0
	proj.speed 				= 0
	proj.valid 				= true
	proj.Active 			= false
	
	return proj
	
end

function GProjectile() -- This global function will create a new instance of the Projectile object
	return Projectile:Constructor()
end

function Projectile:SetCallback(callback) -- You can do whatever you want in a callback, the first argument is the projectile object and the second argument is the traceres. Returning true allows the projectile to continue living, returning false kills it (which is usually what you want to do when it hits something).
	if type(callback) ~= "function" then
		error("bad argument #1 to 'SetCallback' (expected function, got "..type(callback)..")", 2)
	end
	self.callback = callback
	return self:IsPiercing()
end

function Projectile:SetOwner(ent)	
	if ent == NULL then
		error("Tried to use a NULL entity!")
	elseif not IsEntity(ent) then
		error("bad argument #1 to 'SetOwner' (expected Entity, got "..type(ent)..")", 2)
	end
	self.Owner = ent
end

function Projectile:GetOwner()
	return self.Owner
end

function Projectile:SetInflictor(ent)
	if ent == NULL then
		error("Tried to use a NULL entity!",2)
	elseif not IsEntity(ent) then
		error("bad argument #1 to 'SetInflictor' (expected Entity, got "..type(ent)..")", 2)
	end
	self.Inflictor = ent
	self.InflictorName = ent:GetClass()
end

function Projectile:GetInflictor()
	return self.Inflictor
end

function Projectile:SetPos(pos)
	if type(pos) ~= "Vector" then
		error("bad argument #1 to 'SetPos' (expected Vector, got "..type(pos)..")", 2)
	end
	self.pos = pos
end

function Projectile:GetPos()
	return self.pos
end

function Projectile:SetVelocity(vel)
	if type(vel) ~= "Vector" then
		error("bad argument #1 to 'SetVelocity' (expected Vector, got "..type(vel)..")", 2)
	end
	self.velocity = vel
	self.speed = vel:Length()
end

function Projectile:GetVelocity()
	return self.velocity
end

function Projectile:SetPiercing(piercing)
	if type(piercing) ~= "boolean" then
		error("bad argument #1 to 'SetPiercing' (expected Boolean, got "..type(piercing)..")", 2)
	end
	self.pierce = piercing
end

function Projectile:IsPiercing()
	return self.pierce
end

function Projectile:SetGravity(grav)
	if type(grav) ~= "Vector" then
		error("bad argument #1 to 'SetGravity' (expected Vector, got "..type(grav)..")", 2)
	end
	self.gravity = grav
end

function Projectile:GetGravity()
	return self.gravity
end

function Projectile:SetFilter(filter) -- Takes an entity or a table containing entities. You'll usually want to include the entity from which the projectile originates in the filter so it doesn't shoot itself.
	if type(filter) ~= "table" and not IsEntity(filter) then
		error("bad argument #1 to 'SetFilter' (expected Table or Entity, got "..type(filter)..")", 2)
	end
	if filter == NULL then
		error("Tried to use a NULL entity!")
	end
	if type(filter) ~= "table" then
		table.insert(self.filter,filter)
	else
		table.Add(self.filter,filter)
	end
end

function Projectile:GetFilter()
	return self.filter
end

function Projectile:SetMask(mask)
	if type(mask) ~= "number" then
		error("bad argument #1 to 'SetMask' (expected Number, got "..type(mask)..")", 2)
	end
	self.mask = mask
end

function Projectile:GetMask()
	return self.mask
end

function Projectile:IsActive()
	return self.Active
end

function Projectile:SetLifetime(duration)
	if type(duration) ~= "number" then
		error("bad argument #1 to 'SetLifetime' (expected Number, got "..type(duration)..")", 2)
	end
	self.lifetime = duration
end

function Projectile:GetLifetime()
	return self.lifetime
end

function Projectile:GetDeathTime()
	return self.deathtime or 0
end

function Projectile:SetBBox(mins,maxs)
	if type(mins) ~= "Vector" then
		error("bad argument #1 to 'SetBBox' (expected Vector, got "..type(mins)..")", 2)
	end
	if type(maxs) ~= "Vector" then
		error("bad argument #2 to 'SetBBox' (expected Vector, got "..type(maxs)..")", 2)
	end
	self.mins = mins
	self.maxs = maxs
end

function Projectile:SetMaxRange(range)
	if type(range) ~= "number" then
		error("bad argument #1 to 'SetMaxRange' (expected number, got "..type(range)..")", 2)
	end
	self.MaxRange = range
end

function Projectile:Fire()
	s_proj.AddProjectile(self)
end

function s_proj.AddProjectile(projectile)

	local projtab = table.Copy(projectile) -- don't modify the original, it should be used only as a template
	
	projtab.lasttrace = CurTime()
	projtab.started = CurTime()
	projtab.Active = true
	
	if projtab.lifetime and projtab.lifetime ~= 0 then
		projtab.deathtime = CurTime() + projtab.lifetime
	else
		projtab.deathtime = 0
	end
	
	local projectile = table.insert(s_proj.proj, projtab)
	return projtab
	
end

local EMERGENCY_HIT_CUTOFF = 100

s_proj.rem 		= {} -- just use the same table instead of creating local ones every tick,  remember that garbage collection will kick your ass for doing that.
s_proj.tracep 	= {}

-- s_proj.CurrentProjectile references the current projectile being processed. This is so you can reference the table of the projectile doing damage from within EntityTakeDamage or other hooks.

function s_proj.RunTraces()

	-- see about a convar that determines how many ticks between projectile traces, may reduce load and increase chances of hitting (longer traces)
	
	local hits = 0
	local tracep = s_proj.tracep
	local rem = s_proj.rem
	
	for k,v in ipairs(s_proj.proj) do
	
		s_proj.CurrentProjectile = v
		
		if v.Owner:IsPlayer() and v.LagCompensated then
			lastplayer = v.Owner
		end
		
		local tr = {}
		local delta = math.max(CurTime() - v.lasttrace,0) -- don't allow the projectile to travel backwards if CurTime() produces unexpected results
		
		if v.MaxRange ~= 0 then -- if the projectile has a maximum range it's allowed to travel, check to see if it will overtravel this frame and if it will then lower the delta so it fits in the range
		
			local newdist = v.DistanceTraveled + v.speed * delta
			
			if newdist > v.MaxRange then
				local remainder = v.MaxRange - v.DistanceTraveled
				delta = remainder / v.speed
				v.DistanceTraveled = v.MaxRange
			else
				v.DistanceTraveled = newdist
			end
			
		end
		
		v:SetVelocity(v.velocity + v.gravity * delta)
		
		local vel = v.velocity * delta
		
		tracep.start = v.pos
		tracep.filter = v.filter
		tracep.endpos = v.pos + vel
		tracep.mask = v.mask
		
		if v.mins then
			tracep.mins = v.mins
			tracep.maxs = v.maxs
			tr = util.TraceHull(tracep)
		else
			tr = util.TraceLine(tracep)
		end
		
		if v.deathtime == 0 or CurTime() < v.deathtime then
			if v.pierce then
				--MOVEMENT CODE
				tr = {}
				tr.Hit = true
				tracep = {}
				tracep.start = v:GetPos()
				tracep.filter = v.filter
				tracep.endpos = v:GetPos()+vel
				tracep.mask = MASK_SHOT-CONTENTS_SOLID --TODO: make this work with v:GetMask() Currently, that would lock up GMod either on initial fire, or when projectile breaks something.
				if v.mins then
					tracep.mins = v.mins
					tracep.maxs = v.maxs
				end
				while (tr.Hit) do
					if v.mins then
						tr = util.TraceHull(tracep)
					else
						tr = util.TraceLine(tracep)
					end
					if tr.Hit then
						if IsValid(tr.Entity) then
							table.insert(tracep.filter,tr.Entity)
						end

						v:callback(tr)
						if (tr.Entity:GetClass() == "npc_strider") then
							break
						end
					else
						v:SetPos(v:GetPos()+vel)
					end
				end
				v.lasttrace = CurTime()
			else
				if tr.Hit then
					if v.callback and not v:callback(tr) then
						hits = hits + 1
						table.insert(rem, k)
						v.valid = false
					else
						table.insert(rem, k)
						v.valid = false
					end
				end
			end
		else
			table.insert(rem, k)
			v.valid = false
		end

		v.lasttrace = CurTime()
		v.pos = v.pos + vel
		lastplayer = NULL
		
		if hits >= EMERGENCY_HIT_CUTOFF then
			break
		end
		
	end
	
	for i=1,#rem do
		if not s_proj.proj.pierce then
			table.remove(s_proj.proj, rem[1])
			table.remove(rem, 1)
		end
	end
	
	s_proj.CurrentProjectile = nil
	
end

hook.Add("Tick", "s_proj_traces", s_proj.RunTraces) -- this is more like it