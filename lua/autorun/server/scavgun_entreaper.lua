-------------------------------------------
--Entity Reaper--
-------------------------------------------

--AUTHOR: Ghor

--[[===========================================================================================
	-- These functions were written to manage the lifetime of entities.
	-- Firing an entity's "kill" input works nicely in most cases, but you can't keep it from dying at that time if at some point you decide it should live.
	-- This system keeps an automatically generated priority list so it doesn't have to scan the whole list every time the cleanup is run!
==============================================================================================]]

if not EntReaper then --To ensure that the system isn't already loaded..

	EntReaper = {}
		
	EntReaper.period = 0.25
	EntReaper.dyingents = {}
	EntReaper.prioritydeaths = {}
	EntReaper.next_pri_refresh = 5 -- in how many seconds should the priority list be refreshed?
	EntReaper.last_pri_refresh = 0 -- the last time in seconds (relative to the server!) that the priority list was refreshed.
		
	function EntReaper.RunEntCleanup() -- The Entity Reaper. This is run on a regular interval to kill entites at a scheduled time.
		local deadents = {}
		for _,v in ipairs(EntReaper.dyingents) do
			if not IsValid(v) or v.deathtime < CurTime() then
				table.insert(deadents,v)
			end
		end
		for _,ent in ipairs(deadents) do
			EntReaper.RemoveDyingEnt(ent)
			if IsValid(ent) then
				ent:Remove()
			end
		end
	end

	function EntReaper.AddDyingEnt(ent, lifetime) -- Schedules an entity to be killed in a given number of seconds.
		if ent.deathtime or ent.deathtime2 then
			return
		end
		table.insert(EntReaper.dyingents, ent)
		ent.deathtime = CurTime() + lifetime
		if ent.deathtime < EntReaper.last_pri_refresh + EntReaper.next_pri_refresh then
			table.insert(EntReaper.prioritydeaths, ent)
		end
	end

	function EntReaper.RemoveDyingEnt(ent) -- This will remove an entity from the death check and return how many seconds the entity would have had left to live. Returns nil if the entity wasn't on the list.
		
		-- removes the entity from the priority list if it's on it
		
		local key = false
		for k,v in ipairs(EntReaper.prioritydeaths) do
			if v == ent then
				key = k
				break
			end
		end
		if key then
			table.remove(EntReaper.prioritydeaths, key)
		end
		
		-- removes the entity from the entire death schedule
		
		key = false
		for k,v in ipairs(EntReaper.dyingents) do
			if v == ent then
				key = k
				break
			end
		end
		if key then
			table.remove(EntReaper.dyingents, key)
			if IsValid(ent) then
				ent.deathtime = ent.deathtime - CurTime()
				return ent.deathtime
			end
		end
		
	end

	function EntReaper.ChangeEntLife(ent, lifetime) -- Changes how long the entity has left to live. Returns how long the entity had left to live before its lifetime was changed.
	
		if not ent.deathtime then
			return
		end
		
		local deathtime = ent.deathtime
		ent.deathtime = deathtime + lifetime
		if ent.deathtime < EntReaper.last_pri_refresh + EntReaper.next_pri_refresh then
			table.insert(EntReaper.prioritydeaths, ent)
		end
		
		return deathtime - CurTime()
		
	end
	
	function EntReaper.SetEntLife(ent, lifetime) -- Sets how long the entity has left to live. Returns how long the entity had left to live before its lifetime was changed.
	
		if not ent.deathtime then
			return
		end
		
		local deathtime = ent.deathtime
		ent.deathtime = CurTime() + lifetime
		if ent.deathtime < EntReaper.last_pri_refresh + EntReaper.next_pri_refresh then
			table.insert(EntReaper.prioritydeaths, ent)
		end
		
		return deathtime - CurTime()
		
	end
	
	function EntReaper.GetEntLife(ent) -- Returns how long the entity has left to live.
		if not ent.deathtime then
			return 0
		end
		return ent.deathtime - CurTime()
	end

	function EntReaper.RefreshPriorities() -- Regenerates the system's priority list.
		EntReaper.prioritydeaths = {}
		for k,v in ipairs(EntReaper.dyingents) do
			if IsValid(v) and (v.deathtime < CurTime() + EntReaper.next_pri_refresh) then
				table.insert(EntReaper.prioritydeaths, v)
			end
		end
		EntReaper.last_pri_refresh = CurTime()
	end

	function EntReaper.FreezeEntDeath(ent) -- Pauses an entity's death countdown.
		if not ent.deathtime then
			return
		end
		EntReaper.RemoveDyingEnt(ent)
		ent.deathtime2 = ent.deathtime
		ent.deathtime = nil
	end
	
	function EntReaper.UnfreezeEntDeath(ent) -- Resumes an entity's death countdown.
		if not ent.deathtime2 then
			return
		end
		local deathtime = ent.deathtime2
		ent.deathtime2 = nil
		EntReaper.AddDyingEnt(ent, deathtime)
	end
	
	function EntReaper.ChangeSchedule(cleanup, prioritize) --Use this function to change the system's schedule.
		EntReaper.period = cleanup
		EntReaper.next_pri_refresh = prioritize
		timer.Adjust("EntReaperCleanup", EntReaper.period, 0, EntReaper.RunEntCleanup)
		timer.Adjust("EntReaperPrioritize", EntReaper.next_pri_refresh, 0, EntReaper.RefreshPriorities)
	end
		
	timer.Create("EntReaperCleanup", EntReaper.period, 0, EntReaper.RunEntCleanup)  --Get the system started!
	timer.Create("EntReaperPrioritize", EntReaper.next_pri_refresh, 0, EntReaper.RefreshPriorities)

	print("The Reaper is on duty..")

end

