--AUTHOR: Ghor
--VERSION: 1.0
--This is the module for "GNWVars" (Game Network Vars).
--They are networked immediately upon change to all players through usermessages, and are sent to clients upon spawn.
--These should be used only for vars that are too critical to wait for, like game rules.

GNWVars = {}

local TYPE_BOOL		= 0
local TYPE_CHAR		= 1
local TYPE_ENT		= 2
local TYPE_FLOAT	= 3
local TYPE_LONG		= 4
local TYPE_SHORT	= 5
local TYPE_STRING	= 6
local TYPE_VECTOR	= 7

local TYPE_TRANSLATE = {
	["boolean"]		= TYPE_BOOL,
	["Entity"]		= TYPE_ENT,
	["NPC"]			= TYPE_ENT,
	["Player"]		= TYPE_ENT,
	["string"]		= TYPE_STRING,
	["Vector"]		= TYPE_VECTOR
	}

local function GNWType(var)
	local vartype = type(var)
	if vartype == "number" then
		if (var-math.floor(var) ~= 0) then --is it a decimal?
			return TYPE_FLOAT
		elseif ((var <= 127) and (var >= -128)) then --can it be a character?
			return TYPE_CHAR
		elseif ((var <= 32767) and (var >= -32768)) then --can it be a short?
			return TYPE_SHORT
		else --it must be sent as a long
			return TYPE_LONG
		end
	else
		return TYPE_TRANSLATE[vartype] --look up the var's type in the translate table
	end
end
	
--SET FUNCTIONS

	function GM:SetGNWBool(key,value)
		self:SetGNWVar(key,value,TYPE_BOOL)
	end

	function GM:SetGNWChar(key,value)
		self:SetGNWVar(key,value,TYPE_CHAR)
	end

	function GM:SetGNWEnt(key,value)
		self:SetGNWVar(key,value,TYPE_ENT)
	end

	function GM:SetGNWFloat(key,value)
		self:SetGNWVar(key,value,TYPE_FLOAT)
	end

	function GM:SetGNWLong(key,value)
		self:SetGNWVar(key,value,TYPE_LONG)
	end

	function GM:SetGNWShort(key,value)
		self:SetGNWVar(key,value,TYPE_SHORT)
	end

	function GM:SetGNWString(key,value)
		self:SetGNWVar(key,value,TYPE_STRING)
	end

	function GM:SetGNWVector(key,value)
		self:SetGNWVar(key,value,TYPE_VECTOR)
	end
	
	local typetoumsg 
	if SERVER then
		typetoumsg = {
		[TYPE_BOOL]		= umsg.Bool,
		[TYPE_CHAR]		= umsg.Char,
		[TYPE_ENT]		= umsg.Entity,
		[TYPE_FLOAT]	= umsg.Float,
		[TYPE_LONG]		= umsg.Long,
		[TYPE_SHORT]	= umsg.Short,
		[TYPE_STRING]	= umsg.String,
		[TYPE_VECTOR]	= umsg.Vector
		}
	end
	
	function GM:SetGNWVar(key,value,vartype)
		vartype = vartype or GNWType(value) --look up the type if it isn't provided
		local tab = GNWVars[key]
		if not tab then
			GNWVars[key] = {
				["type"] = vartype,
				["value"] = value
				}
		else
			tab.type = vartype
			tab.value = value
		end
			
		if SERVER then
			umsg.Start("sdm_gnwv")
				umsg.Char(vartype)
				umsg.String(key)
				local func = typetoumsg[vartype]
				func(value)
			umsg.End()
		end
	end


	
	if SERVER then
		local meta = FindMetaTable("Player")
		function meta:SendGNWVars() --WARNING: This function will send all GNWVars to the player and is very expensive! Only call this when it is absolutely necessary, it is normally only used automatically when a player spawns for the first time!
			for k,v in pairs(GNWVars) do
				umsg.Start("sdm_gnwv",self)
					umsg.Char(v.type)
					umsg.String(k)
					local func = typetoumsg[v.type]
					func(v.value)
				umsg.End()
			end
			umsg.Start("sdm_gnwv_end",self)
			umsg.End()
		end
	end
	
--GET FUNCTIONS

	function GM:GetGNWVar(key,hideerror) --hideerror is only meant for internal use by the GetGNW* functions, since they return a default value!
		local tab = GNWVars[key]
		if not tab and hideerror then
			print("WARNING! Access error: GNWVar \""..tostring(key).."\" is uninitialized!")
		elseif tab then
			return tab.value
		end
	end
--[[
	function GM:GetGNWBool(key)
		local tab = GNWVars[key]
		if not tab then
			self:SetGNWBool(key,false)
			tab = GNWVars[key]
		end
		if tab.type ~= TYPE_BOOL then
			print("Error! Attempting to retrieve GNWVar \""..key.."\", which is not a boolean value!")
		end
		return tab.value
	end
	]]
	function GM:GetGNWBool(key) return self:GetGNWVar(key,true) or false end
	function GM:GetGNWChar(key) return self:GetGNWVar(key,true) or 0 end
	function GM:GetGNWEnt(key) return self:GetGNWVar(key,true) or NULL end
	function GM:GetGNWFloat(key) return self:GetGNWVar(key,true) or 0 end
	function GM:GetGNWLong(key) return self:GetGNWVar(key,true) or 0 end
	function GM:GetGNWShort(key) return self:GetGNWVar(key,true) or 0 end
	function GM:GetGNWString(key) return self:GetGNWVar(key,true) or "" end
	function GM:GetGNWVector(key) return self:GetGNWVar(key,true) or Vector() end

--HOOKS

	if SERVER then
		hook.Add("PlayerInitialSpawn","GNWVarSend",function(pl)
			pl:SendGNWVars()
		end)
	else
		local meta = FindMetaTable("bf_read")
		local typetomethod = {
			[TYPE_BOOL]		= meta.ReadBool,
			[TYPE_CHAR]		= meta.ReadChar,
			[TYPE_ENT]		= meta.ReadEntity,
			[TYPE_FLOAT]	= meta.ReadFloat,
			[TYPE_LONG]		= meta.ReadLong,
			[TYPE_SHORT]	= meta.ReadShort,
			[TYPE_STRING]	= meta.ReadString,
			[TYPE_VECTOR]	= meta.ReadVector,
			}
		usermessage.Hook("sdm_gnwv",function(um)
			local vartype	= um:ReadChar()
			local key		= um:ReadString()
			local method	= typetomethod[vartype]
			local value		= method(um)
			GAMEMODE:SetGNWVar(key,value,vartype)
		end)
		function GM:OnGNWVarsReceived()
		end
		usermessage.Hook("sdm_gnwv_end",function(um)
			gamemode.Call("OnGNWVarsReceived")
		end)
	end
