AddCSLuaFile()

EFFECT.mat_prebeam = Material("effects/blueblacklargebeam")
EFFECT.mat_darkflare = Material("effects/strider_dark_flare.vtf")
EFFECT.mat_muzzle = Material("effects/blueblackflash")
EFFECT.mat_warp = Material("effects/strider_pinch_dudv.vmt")
EFFECT.mat_shockwave = Material("effects/strider_bulge_dudv.vmt")
EFFECT.WarpSize = 48

function EFFECT:Init(data)
	self.Created = CurTime()
	self.Weapon = data:GetEntity()
	if not self.Weapon:IsValid() then
		return false
	end
	self.Owner = self.Weapon:GetOwner()
	if not self.Owner:GetActiveWeapon() or not self.Owner:GetActiveWeapon():IsValid() or (self.Owner:GetActiveWeapon():GetClass() ~= "scav_gun") then
		return false
	end
	local tracep = {}
	tracep.start = self.Owner:GetShootPos()
	tracep.endpos = self.Owner:GetShootPos()+(self.Owner:GetAimVector()*10000)
	tracep.filter = self.Owner
	local trace = {}
	trace = util.TraceLine(tracep)
	--util.Decal("fadingscorch",trace.HitPos+trace.HitNormal,trace.HitPos-trace.HitNormal)
	self.endpos = trace.HitPos
	self:SetRenderBoundsWS(self:GetPos(),self.endpos)
	if self.Owner == GetViewEntity() then
		self.WarpSize = 24
	end
	self.BeamStart = self:GetPos()
end

function EFFECT:Think()
	if not self.Owner:GetActiveWeapon() or not self.Owner:GetActiveWeapon():IsValid() or (self.Owner:GetActiveWeapon():GetClass() ~= "scav_gun") then
		return false
	end
	if self.Created+4.5 < CurTime() then
		return false
	end
	return true
end

local DURATION_WARP = 1.3
local DURATION_UNWARP = 0.25
local DURATION_WARPTOTAL = DURATION_WARP+DURATION_UNWARP
local DURATION_BEAMTRAVEL = 0.2
local DURATION_LIFETIME = 4.5
local DURATION_IMPACTFADE = 0.5

local beampos = Vector(0,0,0)
	local tracep = {}
	tracep.mins = Vector(-4,-4,-4)
	tracep.maxs = Vector(4,4,4)
	
local rmins = Vector(0,0,0)
local rmaxs = Vector(0,0,0)
	
function EFFECT:Render()

	local ctime = CurTime()
	local age = ctime-self.Created
	
	if self.Owner == GetViewEntity() then
		self:SetPos(self.Owner:GetViewModel():GetAttachment(self.Owner:GetViewModel():LookupAttachment("muzzle")).Pos)
	else
		self:SetPos(self.Owner:GetActiveWeapon():GetAttachment(self.Owner:GetActiveWeapon():LookupAttachment("muzzle")).Pos)
	end
	local pos = self:GetPos()

	if age < DURATION_WARP then
		self.BeamStart.x = pos.x
		self.BeamStart.y = pos.y
		self.BeamStart.z = pos.z
		tracep.start = self.Owner:GetShootPos()
		tracep.endpos = self.Owner:GetShootPos()+(self.Owner:GetAimVector()*10000)
		tracep.filter = self.Owner
		local trace = util.TraceHull(tracep)
		self.endpos = trace.HitPos
	end
	local BeamStart = self.BeamStart
	rmins.x = math.min(pos.x,self.BeamStart.x,self.endpos.x)
	rmins.y = math.min(pos.y,self.BeamStart.y,self.endpos.y)
	rmins.z = math.min(pos.z,self.BeamStart.z,self.endpos.z)
	rmaxs.x = math.max(pos.x,self.BeamStart.x,self.endpos.x)
	rmaxs.y = math.max(pos.y,self.BeamStart.y,self.endpos.y)
	rmaxs.z = math.max(pos.z,self.BeamStart.z,self.endpos.z)
	self:SetRenderBoundsWS(rmins,rmaxs)
	
	local beamfraction
	local beamalpha
	if age < DURATION_WARP then
		beamfraction = 1
		beamalpha = age/DURATION_WARP
	else
		beamfraction = math.Clamp((DURATION_BEAMTRAVEL-(age-DURATION_WARP))/DURATION_BEAMTRAVEL,0,1)
		beamalpha = 1
	end
	
	beampos.x = (BeamStart.x-self.endpos.x)*beamfraction+self.endpos.x
	beampos.y = (BeamStart.y-self.endpos.y)*beamfraction+self.endpos.y
	beampos.z = (BeamStart.z-self.endpos.z)*beamfraction+self.endpos.z
	
	if age < DURATION_WARP then --blue flare
		local rscale = age/DURATION_WARP
		render.SetMaterial(self.mat_muzzle)
		self.mat_muzzle:SetFloat("$alpha",rscale)
		render.DrawSprite(pos,16+16*math.pow(rscale,2),16+16*math.pow(rscale,2),color_white)
		self.mat_muzzle:SetFloat("$alpha",1)
	else
		local rscale = (age-DURATION_WARP)/(DURATION_LIFETIME-DURATION_WARP)
		render.SetMaterial(self.mat_muzzle)
		self.mat_muzzle:SetFloat("$alpha",1-rscale)
		render.DrawSprite(pos,32*(1-math.pow(rscale,2)),32*(1-math.pow(rscale,2)),color_white)
		self.mat_muzzle:SetFloat("$alpha",1)
	end
	
	render.UpdateRefractTexture()
	if ctime < self.Created+DURATION_WARP then --pinch
		self.mat_warp:SetFloat("$refractamount",age/DURATION_WARP/3)
		render.SetMaterial(self.mat_warp)
		render.DrawSprite(pos,self.WarpSize,self.WarpSize,color_white)
	elseif ctime < self.Created+DURATION_WARPTOTAL then --unpinch
		self.mat_warp:SetFloat("$refractamount",(DURATION_UNWARP-(age-DURATION_WARP))/DURATION_UNWARP/3)
		render.SetMaterial(self.mat_warp)
		render.DrawSprite(pos,self.WarpSize,self.WarpSize,color_white)
	end
	

	
	if age < DURATION_WARP+DURATION_BEAMTRAVEL then --beam
		local rscale = math.sin(age/(DURATION_WARP+DURATION_BEAMTRAVEL)*3.14)
		render.SetMaterial(self.mat_prebeam)
		self.mat_prebeam:SetFloat("$alpha",rscale)
		render.DrawBeam(BeamStart,self.endpos,1,0,1,color_white)
		self.mat_prebeam:SetFloat("$alpha",1)
	end
	

	if (age > DURATION_WARP) and (age < DURATION_WARP+DURATION_BEAMTRAVEL) then --shockwave, beam
		render.SetMaterial(self.mat_prebeam)
		self.mat_prebeam:SetFloat("$alpha",beamalpha)
		render.DrawBeam(beampos,self.endpos,1+(1-beamfraction)*63,0,1,color_white)
		self.mat_prebeam:SetFloat("$alpha",1)
		render.UpdateRefractTexture()
		self.mat_shockwave:SetFloat("$refractamount",0.9)
		render.SetMaterial(self.mat_shockwave)
		render.DrawSprite(beampos,32+48*(1-beamfraction),32+48*(1-beamfraction),color_white)
	end
	
	if (age > DURATION_WARP+DURATION_BEAMTRAVEL) and (age < DURATION_WARP+DURATION_BEAMTRAVEL+DURATION_IMPACTFADE) then --shockwave impact
		render.UpdateRefractTexture()
		self.mat_shockwave:SetFloat("$refractamount",math.pow((DURATION_IMPACTFADE+DURATION_WARP+DURATION_BEAMTRAVEL-age)/(DURATION_IMPACTFADE),2))
		render.SetMaterial(self.mat_shockwave)
		render.DrawSprite(beampos,128,128,color_white)
	end

end
