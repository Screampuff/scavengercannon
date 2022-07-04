local blacklist = {}
if file.Exists("gloader_blacklist.txt","DATA") then
	blacklist = util.KeyValuesToTable(file.Read("gloader_blacklist.txt","DATA"))
end

local oneof = {}
oneof["env_fog_controller"] = true

local function CleanUpNulls(tab)
	local nulls = {}
	for k,v in pairs(tab) do
		if v == NULL then
			table.insert(nulls,k)
		end
	end
	local numnulls = #nulls
	for i=0,numnulls do
		table.remove(tab,nulls[numnulls-i])
	end
end

local meta = {}
meta.__index = meta --????????????

function NewGLoader(path)
	local gloader = {}
	setmetatable(gloader,meta)
	gloader.ents = {}
	gloader:LoadFile(path)
	return gloader
end

function meta:LoadFile(path)
	self.filepath = path
	local read = file.Read(path,"DATA")
	local tab = {}
	if read then
		tab = util.JSONToTable(read)
	end
	self.data = tab
	self.templates = tab.entities
	--PrintTable(self.templates)
end

function meta:ParseGameVars()
	local gamevars = self.data.gamevars
	if gamevars then
		for k,v in pairs(gamevars) do
			local result = hook.Call("GameVar",GAMEMODE,k,v)
			if result ~= nil then
				gamevars[k] = result --You can override gamevars from GM:GameVar by returning non-nil. Mainly useful for enforcing a data type.
			end
		end
	end
end

function meta:Spawn(filter) --accepts TemplateID filter, TemplateID member is assigned to all entities upon spawn to refer back to.
	filter = filter or {}
	CleanUpNulls(self.ents)
	local spawnedents = {}
	if self.templates then
		for k,template in pairs(self.templates) do
			local classname = string.lower(template.KeyValues.classname or template.ClassName)

			if table.HasValue(filter,k) then
				--do nothing
			elseif not table.HasValue(blacklist,classname) then
				local override = template.KeyValues.override
				if oneof[classname] and override then
					local otherent = ents.FindByClass(classname)[1]
					if IsValid(otherent) then
						otherent:Remove()
					end
				end
				if override then
					local ent = ents.FindByClass(classname)[1]
					if not ent.WrittenTo then
						for key,value in pairs(template.KeyValues) do
							ent:SetKeyValue(key,value)
						end
						for outputindex,outputinfo in pairs(template.Outputs) do
							local values = string.Explode(",",outputinfo)
							ent:AddEntOutput(values[1],values[2],values[3],values[4],values[5],values[6])
						end
					end
				else
					local ent = ents.Create(classname)
					if ent:IsValid() then
						ent.TemplateID = k
						ent:SetPos(template.pos)
						ent:SetAngles(template.ang)
						ent:SetMaterial(template.material)
						for key,value in pairs(template.KeyValues) do
							key = string.lower(key)
							ent:SetKeyValue(key,value)
							if key == "team" then
								ent.team = ScavData.ColorNameToTeam(value)
							elseif key == "parentname" then
								ent.parentname = value
							elseif key == "modelname" then
								ent:SetKeyValue("model",value)
							end
						end
						for outputindex,outputinfo in pairs(template.Outputs) do
							local values = string.Explode(",",outputinfo)
							ent:AddEntOutput(values[1],values[2],values[3],values[4],values[5],values[6])
						end
						ent.NoScav = tobool(template.KeyValues.noscav)
						ent:Spawn()
						if ent:GetPhysicsObject():IsValid() and tobool(template.KeyValues.physfrozen) then
							ent:GetPhysicsObject():EnableMotion(false)
						end
						table.insert(spawnedents,ent)
					end
				end
			else
				MsgAll("GLOADER WARNING!!! ATTEMPTED TO SPAWN BLACKLISTED ENTITY CLASS: \""..string.upper(classname).."\" FROM FILE \""..string.upper(self.filepath).."\"")
			end
		end
	end
	for k,v in pairs(spawnedents) do
		if v.parentname then
			local parent = ents.FindByName(v.parentname)[1]
			if parent then
				v:SetParent(parent)
			end
		end
	end
	table.Merge(self.ents,spawnedents)
	gamemode.Call("OnGLoaderSpawn")
	return spawnedents
end

function meta:Cleanup(filter) --takes entity filter
	filter = filter or {}
	for k,ent in pairs(self.ents) do
		if not table.HasValue(filter,ent) then
			ent:Remove()
		end
	end
	CleanUpNulls(self.ents)
end

function meta:GetEntityTemplates()
	return self.templates
end

function meta:FindEntTemplatesByClass(classname,exact)
	classname = string.lower(classname)
	local tab = {}
	for k,template in pairs(self.templates) do
		local cname = string.lower(template.KeyValues.classname)
		if (exact and (classname == cname)) or (not exact and string.find(cname,classname)) then
			table.insert(tab,template)
		end
	end
	return tab
end

local GM = GM or GAMEMODE
function GM:OnGLoaderSpawn()
end
