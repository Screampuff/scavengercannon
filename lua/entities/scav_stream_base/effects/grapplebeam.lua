local ENT = {}
ENT.Type = "anim"
ENT.Base = "scav_stream_base"
ENT.KillDelay = 0

function ENT:OnInit()	
	if CLIENT then
		self.em = ParticleEmitter(self:GetPos())
	else
		self:EmitSound("ambient/energy/spark4.wav")
		self.sound = CreateSound(self,"ambient/energy/electric_loop.wav")
		self.sound:PlayEx(100,85)
	end
end

function ENT:OnKill()
	if self.sound then
		self.sound:Stop()
	end
end

function ENT:OnSetupDataTables()
	self:NetworkVar("Vector",0,"endpos")
	self:NetworkVar("Entity",0,"endent")
	self:NetworkVar("Bool",0,"useendent")
end

function ENT:SetEndPoint(pos)
	self:Setendpos(pos)
end

function ENT:SetEndEnt(ent)
	self:Setendent(ent)
	self:Setuseendent(true)
end

if CLIENT then
	local beammat = Material("sprites/scav_tr_phys")
	local beamglowmat1 = Material("sprites/blueglow1")
	local beamglowmat2 = Material("sprites/blueglow2")
	local mins = Vector(-2,-2,-2)
	local maxs = Vector(2,2,2)
	local partgrav = Vector(0,0,96)
	
	function ENT:OnThink()
		local angpos = self:GetMuzzlePosAng()
		local pos = angpos.Pos
		local ang = angpos.Ang
		self:SetPos(angpos.Pos)
		self:SetAngles(angpos.Ang)
		self:UpdateDLight()
	end
	
	function ENT:BuildDLight()
		self.dlight = DynamicLight(0)
		self.dlight.Pos = self:GetPos()
		self.dlight.r = 100
		self.dlight.g = 100
		self.dlight.b = 200
		self.dlight.Brightness = 2
		self.dlight.Size = 200
		self.dlight.Decay = 500
		self.dlight.DieTime = CurTime() + 1
	end

	function ENT:UpdateDLight()
		if self.dlight then
			self.dlight.Pos = self:GetPos()
			self.dlight.Brightness = 2
			self.dlight.Size = 200
			self.dlight.DieTime = CurTime() + 1
		else
			self:BuildDLight()
		end
	end

	local col = Color(255,255,255,255)
	local colbluevec = Vector(0.45,0.45,0.7)
	local colwhitevec = Vector(1,1,1)
	--local endpos = Vector(0,0,0)

	
	function ENT:Draw2()
		local endpos
		if self:Getuseendent() then
			if IsValid(self:Getendent()) then
				endpos = self:Getendent():LocalToWorld(self:Getendpos())
			else
				return
			end
		else
			endpos = self:Getendpos()
		end
		
		local angpos = self:GetMuzzlePosAng()
		local trace = self:GetTrace(10000,nil,mins,maxs)
		local ang = angpos.Ang
		local pos = angpos.Pos
		local pos2 = self:Getendpos()
		local epscale = math.Clamp((CurTime()-self.Created)*4,0,1)
		endpos = pos+(endpos-pos)*epscale
		--endpos.x = (pos2.x-pos.x)*epscale+pos.x
		--endpos.y = (pos2.y-pos.y)*epscale+pos.y
		--endpos.z = (pos2.z-pos.z)*epscale+pos.z
		local offset = (CurTime()*2)%1
		beammat:SetVector("$color",colbluevec)
		render.SetMaterial(beammat)
		render.DrawBeam(pos,endpos,math.random(10,20),offset,offset%1+epscale,col)
		render.DrawBeam(pos,endpos,math.random(10,20),-offset,-offset%1+epscale,col)
		beammat:SetVector("$color",colwhitevec)
		render.SetMaterial(beamglowmat2)
		render.DrawSprite(pos,math.random(20,30),math.random(20,30),col)
		render.DrawSprite(endpos+(pos-endpos):GetNormalized()*8,math.random(20,30),math.random(20,30),col)
		
	end

	function ENT:OnViewMode()
	end

	function ENT:OnWorldMode()
	end
end

scripted_ents.Register(ENT,"scav_stream_grapplebeam",true)
