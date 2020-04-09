local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 1

function ENT:OnInit()
	if SERVER then
		self.DangerPoint = self:CreateDangerSound()
		self.DangerHull = self:CreateDangerSound()
		self.NextSound = CurTime()+0.5
	else
		self.vishandle = util.GetPixelVisibleHandle()
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

if CLIENT then
	local beammat = Material("effects/bluelaser1")
	local halomat = CreateMaterial("scav_sniperhalo2","UnlitGeneric",
		{
			["$basetexture"] = "sprites/light_glow03",
			["$additive"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1,
			["$ignorez"] = 1
		}
	)

	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		local ang = angpos.Ang
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
	end
	
	local lasercol = Color(0,100,255,255)
	
	function ENT:Draw2()
		//cam.Start3D(EyePos(),EyeAngles())
		local angpos = self:GetMuzzlePosAng()
		local trace
		if self.Killed && self.ViewMode then
			trace = self:GetModelTrace(10000)
		else
			trace = self:GetTrace(10000)
		end
		local ang = angpos.Ang
		local pos1 = angpos.Pos
		local pos2 = trace.HitPos
		render.SetMaterial(beammat)
		render.DrawBeam(pos1,pos2,1,0,1,lasercol)
		render.SetMaterial(halomat)
		local radius = util.PixelVisible(pos2,4,self.vishandle)*4
		render.DrawSprite(pos2,radius,radius,lasercol)
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
else
	function ENT:CreateDangerSound()
		local DangerSound = ents.Create("ai_sound")
		DangerSound:SetParent(self)
		DangerSound:SetKeyValue("soundtype",bit.bor(1048576,8)) //sniper, turn to face, and danger
		DangerSound:SetKeyValue("duration",0.5)
		DangerSound:SetKeyValue("volume",200)
		return DangerSound
	end

	local hullmins = Vector(-20,-20,-20)
	local hullmaxs = Vector(20,20,20)
	
	function ENT:OnThink()
		if self.NextSound < CurTime() then --staggering the sound emission to give the appearance of reaction times in the NPCs
			self.DangerPoint:SetPos(self:GetTrace(10000).HitPos)
			self.DangerPoint:Fire("EmitAISound",nil,0)
			self.DangerHull:SetPos(self:GetTrace(10000,nil,hullmins,hullmaxs,MASK_SHOT-CONTENTS_SOLID).HitPos)
			self.DangerHull:Fire("EmitAISound",nil,0)
			self.NextSound = CurTime()+0.5
			//debugoverlay.Sphere(self.DangerSound:GetPos(),100,0.5,color_red,false)
		end
	end
end

scripted_ents.Register(ENT,"scav_stream_sniper",true)