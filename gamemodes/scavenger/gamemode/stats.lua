--BIG thanks to Hank Hill for all the sweet SQL work

ScavStats = {}
ScavStats.Stats = {}
ScavStats.Awards = {}
ScavStats.Achievements = {}

local PLAYER = FindMetaTable("Player")
local _E = debug.getregistry()

local function RegisterStat(index,name,printname)
	if SERVER then
		sql.Query([[REPLACE INTO ScavStats (StatID,StatName) VALUES (]] .. index .. [[,"]]..name..[[");]])
	end
	ScavStats.Stats[index] = {
		["index"] = index,
		["name"] = name,
		["printname"] = printname
	}
end
local function RegisterAward(index,name,printname,icon)
	if SERVER then
		sql.Query([[REPLACE INTO ScavStats (AwardID,AwardName) VALUES (]] .. index .. [[,"]]..name..[[");]])
	end
	ScavStats.Awards[index] = {
		["index"] = index,
		["name"] = name,
		["printname"] = printname,
		["icon"] = icon
	}
end
local function RegisterAchievement(index,name,printname,icon,description,amttoachieve,secret,quiet)
	if SERVER then
		sql.Query([[REPLACE INTO ScavAchievements (AchievementID,AchievementTitle) VALUES (]]..index..[[,"]]..name..[[");]])
	end
	ScavStats.Achievements[index] = {
		["index"] = index,
		["name"] = name,
		["printname"] = printname,
		["icon"] = icon,
		["description"] = description,
		["amttoachieve"] = amttoachieve,
		["secret"] = secret,
		["quiet"] = queit
	}
end

if SERVER then
 
    -- Look for table, if doesn't exist...
        if !sql.TableExists("ScavStats") then
                sql.Begin()
                local success = sql.Query(
                        [[
                        CREATE TABLE "ScavPlayers" ("SteamID" TEXT PRIMARY KEY  NOT NULL , "PlayerName" TEXT);
                        CREATE TABLE "ScavAchievements" ("AchievementID" INTEGER PRIMARY KEY  NOT NULL , "AchievementName" TEXT NOT NULL );
						CREATE TABLE "ScavAwards" ("AwardID" INTEGER PRIMARY KEY  NOT NULL , "AwardName" TEXT NOT NULL );
                        CREATE TABLE "ScavStats" ("StatID" INTEGER PRIMARY KEY  NOT NULL , "StatName" TEXT NOT NULL );
						CREATE TABLE "ScavPlayerAchievements" ("SteamID" TEXT NOT NULL , "AchievementID" INTEGER NOT NULL , "Progress" INTEGER NOT NULL, FOREIGN KEY (SteamID) REFERENCES ScavPlayers(SteamID), FOREIGN KEY (AchievementID) REFERENCES ScavAchievements(AchievementID), PRIMARY KEY (SteamID,AchievementID));
						CREATE TABLE "ScavPlayerAwards" ("SteamID" TEXT NOT NULL, "AwardID" INTEGER NOT NULL ,"AwardAmount" INTEGER NOT NULL, FOREIGN KEY(SteamID) REFERENCES ScavPlayers(SteamID), FOREIGN KEY(AwardID) REFERENCES ScavAwards(AwardID), PRIMARY KEY (SteamID,AwardID) );
						CREATE TABLE "ScavPlayerStats" ("SteamID" TEXT NOT NULL ,"StatID" INTEGER NOT NULL,"Value" INTEGER NOT NULL, FOREIGN KEY (SteamID) REFERENCES ScavPlayers(SteamID),FOREIGN KEY (StatID) REFERENCES ScavStats(StatID), PRIMARY KEY (SteamID,StatID));
						CREATE INDEX "playerIndex" ON "ScavPlayers" ("SteamID" ASC);
						CREATE INDEX "playerStatIndex" ON "ScavPlayerStats" ("SteamID" DESC, "StatID" DESC);]])
                sql.Commit()
				if success == false then
					print("Scav DM Database initialization error!"..tostring(sql.LastError()))
				else
					print("Scav DM Database successfully initialized!")
				end
        end

	function PLAYER:AddScavStat(name,amt)
		self.ScavStats[name] = (self.ScavStats[name] or 0)+amt
	end

	function PLAYER:GetScavStat(name,amt)
		return self.ScavStats[name] or 0
	end
	
	function PLAYER:AddScavAward(name,amt)
		self.ScavAwards[name] = (self.ScavAwards[name] or 0)+amt
	end

	function PLAYER:GetScavAward(name,amt)
		return self.ScavAwards[name] or 0
	end

	function PLAYER:AddScavAchievement(name,amt)
		local amttoachieve = ScavStats.Achievements[name].amttoachieve
		local progress = self:GetScavAchievementProgress(name)
		if progress >= amttoachieve then
			return
		end
		if amt+progress >= amttoachieve then
			gamemode.Call("OnPlayerAchieved",self,name)
		end
		self.ScavAchievements[name] = math.min(amt+progress,amttoachieve)
	end
	
	function PLAYER:GetScavAchievementProgress(name)
		return self.ScavAchievements[name] or 0
	end
	
	function PLAYER:HasScavAchievement(name)
		local amttoachieve = ScavStats.Achievements[name].amttoachieve
		local progress = self:GetScavAchievementProgress(name)
		return (progress >= amttoachieve)
	end

	function PLAYER:LoadScavStats()
		self.ScavStatsID = sql.SQLStr(string.gsub(self:SteamID(),":","_")) --if you swap this out for the one below then you also have to swap out at the top of PLAYER:CommitScavStats()
		self.ScavStatsNick = sql.SQLStr(self:Nick())
		local id = self.ScavStatsID
		--local id = sql.SQLStr(self:SteamID())
		self.ScavStats = {}
		self.ScavAwards = {}
		self.ScavAchievements = {}
		--Darv's stuff
		--Let's populate those stats first.
		local result = sql.Query([[SELECT StatID, Value FROM ScavPlayerStats WHERE SteamID = "]] .. id .. [[";]])
		if result == false then
			Msg("ERROR LOADING SCAV STATS: "..tostring(sql.LastError()).."\n")
		end
		if result then
			for k,v in pairs(result) do
				local index = tonumber(v['StatID'])
				self.ScavStats[index] = 0
				self:AddScavStat(index,tonumber(v['Value']))
			end
		end
		--Now awards....
		local result = sql.Query([[SELECT AwardID, AwardAmount FROM ScavPlayerAwards WHERE SteamID = "]] .. id .. [[";]])
		if result == false then
			Msg("ERROR LOADING SCAV AWARDS: "..tostring(sql.LastError()).."\n")
		end
		if result then
			for k,v in pairs(result) do
				local index = tonumber(v['AwardID'])
				self.ScavAwards[index] = 0
				self:AddScavAward(index,tonumber(v['AwardAmount']))
			end
		end
		--...and achievements.
		result = sql.Query([[SELECT AchievementID, Progress FROM ScavPlayerAchievements WHERE SteamID = "]] .. id .. [[";]])
		if result == false then
			Msg("ERROR LOADING SCAV ACHIEVEMENTS: "..tostring(sql.LastError()).."\n")
		end
		if result then
			for k,v in pairs(result) do
				local index = tonumber(v['AchievementID'])
				self.ScavAchievements[index] = 0
				self:AddScavAchievement(index,tonumber(v['Progress']))
			end
		end
    end
	
	function PLAYER:CommitScavStats()
		local id = self.ScavStatsID
		local nick = self.ScavStatsNick
        --local id = sql.SQLStr(self:SteamID())
        sql.Begin()
        -- Let's force the bastard into the players table/update his nick while we're commiting.
        sql.Query([[REPLACE INTO ScavPlayers (SteamID,PlayerName) VALUES ("]] .. id .. [[","]] .. nick .. [[");]])
            for k,v in pairs(self.ScavStats) do
				sql.Query([[REPLACE INTO ScavPlayerStats (SteamID,StatID,Value) VALUES("]] .. id .. [[",]] .. k .. [[,]] .. v .. [[);]])
            end
            for k,v in pairs(self.ScavAwards) do
				sql.Query([[REPLACE INTO ScavPlayerAwards (SteamID,AwardID,AwardAmount) VALUES("]] .. id .. [[",]] .. k .. [[,]] .. v .. [[);]])     
            end
            for k,v in pairs(self.ScavAchievements) do
				sql.Query([[REPLACE INTO ScavPlayerAchievements (SteamID,AchievementID,Progress) VALUES("]] .. id .. [[",]] .. k .. [[,]] .. v .. [[);]])            
            end
        sql.Commit()
        
	end

	local function commitonremove(pl)
		print("committing scav stats for "..pl.ScavStatsNick.." "..pl.ScavStatsID.."...")
		pl:CommitScavStats()
		print("committed.")
	end
	
	hook.Add("PlayerInitialSpawn","ScavStats",function(pl)
		pl:LoadScavStats()
		pl:CallOnRemove("CommitScavStats",commitonremove,pl)
	end)
	
	--[[
	hook.Add("PlayerDisconnected","ScavStats",function(pl)
		pl:CommitScavStats()
	end)
	]]
	hook.Add("ShutDown","ScavStats",function()
		--print("Preparing to commit shutdown scav stats...")
		--print(tostring(Entity(1),#ents.GetAll(),#player.GetAll()))
		--for k,v in pairs(player.GetAll()) do
		--	print("committing scav stats for "..v:Nick().." "..v:SteamID())
		--	v:CommitScavStats()
		--end
	end)
	
	--[[
	hook.Add("EntityRemoved","ScavStats",function(ent)
		if ent:IsPlayer() then
			--print("Committing scav stats for "..ent:Nick().." "..ent:SteamID())
			print("Committing scav stats for "..tostring(ent))
			ent:CommitScavStats()
		end
	end)
	]]
	
	function GM:OnPlayerAchieved(pl,index)
		pl:EmitSound("weapons/fx/rics/ric2.wav")
		PrintMessage(HUD_PRINTTALK,pl:Nick().." has achieved "..ScavStats.Achievements[index].printname.."!")
	end
	
end


--DO NOT MESS WITH THESE ENUMS, THEY GO WITH THE DATABASE. IF YOU REMOVE OR CHANGE ANY OF THESE THINGS WILL GET FUCKED UP

_E.SCAVSTAT_PLAYTIME = 1
_E.SCAVSTAT_GAMESPLAYED = 2
_E.SCAVSTAT_WINS = 3
_E.SCAVSTAT_LOSSES = 4
_E.SCAVSTAT_DRAWS = 5
_E.SCAVSTAT_POINTS = 6
_E.SCAVSTAT_FRAGS = 7
_E.SCAVSTAT_DEATHS = 8
_E.SCAVSTAT_SUICIDES = 9
_E.SCAVSTAT_GIBS = 10
_E.SCAVSTAT_HEADSHOTS = 11
_E.SCAVSTAT_DAMAGE = 12
_E.SCAVSTAT_HEALING = 13
_E.SCAVSTAT_KILLSTREAK = 14
_E.SCAVSTAT_POINTSTREAK = 15

sql.Begin()
RegisterStat(SCAVSTAT_PLAYTIME,"PlayTime","Play Time")
RegisterStat(SCAVSTAT_GAMESPLAYED,"GamesPlayed","Games Played")
RegisterStat(SCAVSTAT_WINS,"Wins","Wins")
RegisterStat(SCAVSTAT_LOSSES,"Losses","Losses")
RegisterStat(SCAVSTAT_DRAWS,"Draws","Draws")
RegisterStat(SCAVSTAT_POINTS,"Points","Points")
RegisterStat(SCAVSTAT_FRAGS,"Frags","Frags")
RegisterStat(SCAVSTAT_DEATHS,"Deaths","Deaths")
RegisterStat(SCAVSTAT_SUICIDES,"Suicides","Suicides")
RegisterStat(SCAVSTAT_GIBS,"Gibs","Gibs")
RegisterStat(SCAVSTAT_HEADSHOTS,"Headshots","Headshots")
RegisterStat(SCAVSTAT_DAMAGE,"Damage","Damage")
RegisterStat(SCAVSTAT_HEALING,"Healing","Healing")
RegisterStat(SCAVSTAT_KILLSTREAK,"KillStreak","Longest Killing Spree")
RegisterStat(SCAVSTAT_POINTSTREAK,"PointStreak","Longest Point Streak")

_E.SCAVACHIEVEMENT_TRIPLEGIB = 1

RegisterAchievement(SCAVACHIEVEMENT_TRIPLEGIB,"TripleGib","Two Is Company, Three Is Chunks",icon,"Kill three players with one explosion.",1,false,false)

sql.Commit()
