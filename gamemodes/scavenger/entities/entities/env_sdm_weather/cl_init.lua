include("shared.lua")
ENT.OldSkyName = ""

local skysuffix = {"UP","DN","LF","RT","FT","BK"}


function ENT:SetSky(newsky)
	local skyname = GetConVarString("sv_skyname")
	for k,v in pairs(skysuffix) do
		local skymat = Material("skybox/"..skyname..v)
		local newskymat
		if self.dt.AbsSkyPath then
			newskymat = Material(newsky)
		else
			newskymat = Material("skybox/"..newsky..v)
		end
		local newskytex = newskymat:GetMaterialTexture("$basetexture")
		skymat:SetTexture("$basetexture",newskytex)
		local hdrtex = newskymat:GetMaterialTexture("$hdrcompressedtexture",newskytex)
		if not hdrtex then
			skymat:SetTexture("$hdrcompressedtexture",newskytex)
		else
			skymat:SetTexture("$hdrcompressedtexture",hdrtex)
		end
		local hdrtex = newskymat:GetMaterialTexture("$hdrbasetexture",newskytex)
		if not hdrtex then
			skymat:SetTexture("$hdrbasetexture",newskytex)
		else
			skymat:SetTexture("$hdrbasetexture",hdrtex)
		end
	end
	self.OldSkyName = newsky
	
end

function ENT:ResetSkybox()
	self:SetSky(GetConVarString("sv_skyname"))
end

hook.Add("ShutDown","SDMResetWeather",function()
	local weather = ents.FindByClass("env_sdm_weather")[1]
	if IsValid(weather) then
		weather:ResetSkybox()
	end
end)
