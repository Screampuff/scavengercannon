local ENT = {}
ENT.StartMeltTime = 0
ENT.wep = NULL
ENT.Type = "anim"
ENT.Base = "base_anim"

local kgpersec = 15
local currentmelt

PrecacheParticleSystem("alch_melt")

function ENT:Initialize()
	self:AddEffects(EF_NOSHADOW)
	self.StartMeltTime = CurTime()
	if CLIENT && (self:GetOwner() == LocalPlayer()) then
		currentmelt = self
	end
	self:SetColor(Color(255,255,255,254))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:SetupDataTables()
	self:DTVar("Float",0,"MassToComplete")
end

if SERVER then

	function ENT:SetWeapon(wep)
		self:SetOwner(wep:GetOwner())
		self.wep = wep
	end

	function ENT:SetProp(ent)
		self:SetParent(ent)
		self:SetModel(ent:GetModel())
		self.dt.MassToComplete = ent:GetPhysicsObject():GetMass()
	end

	function ENT:Finish()
		local parent = self:GetParent()
		self:SetParent()
		self.wep:Scavenge(parent)
		self:SetSolid(SOLID_NONE)
		ParticleEffectAttach("alch_melt",PATTACH_ABSORIGIN_FOLLOW,self,0)
		self:Fire("Kill",nil,0.3)
	end

end

function ENT:Think()
	if SERVER then
		local owner = self:GetOwner()
		if !IsValid(owner) then
			return
		end
		local tr = owner:GetEyeTraceNoCursor()
		if !owner:KeyDown(IN_ATTACK2) || !IsValid(owner:GetActiveWeapon()) || (owner:GetActiveWeapon():GetClass() != "weapon_alchemygun") || ((self:GetOwner():GetPos():Distance(self:GetPos()+self:OBBCenter()) > 250) && ((tr.Entity != self) || (tr.HitPos:Distance(tr.StartPos) > 250))) then
			self:Remove()
			return
		end
		if !IsValid(self:GetParent()) then
			return
		end
		if self.StartMeltTime+self.dt.MassToComplete/kgpersec < CurTime() then
			self:Finish()
		end
	end
end

function ENT:GetProgress()
	return math.Clamp(((self.StartMeltTime+self.dt.MassToComplete/kgpersec)-CurTime())/(self.dt.MassToComplete/kgpersec),0,1)
end



if CLIENT then
	local shinymat = Material("models/shiny")
	function ENT:Draw()
		if !IsValid(self:GetParent()) then
			return
		end
		render.MaterialOverride(shinymat)
		render.SetBlend(1-self:GetProgress())
		render.SetColorModulation(0.67,0,0.94)
		render.SuppressEngineLighting(true)
			self:GetParent():DrawModel()
		render.SuppressEngineLighting(false)
		render.SetColorModulation(1,1,1)
		render.SetBlend(1)
		render.MaterialOverride()
	end

	hook.Add("HUDPaint","AlchMeltProgress",function()
		if IsValid(currentmelt) && IsValid(currentmelt:GetParent()) then
			local xmid = ScrW()/2
			local ymid = ScrH()/2+32
			local progress = currentmelt:GetProgress()
			surface.SetDrawColor(200,50,255,255)
			surface.DrawRect(xmid-40,ymid-progress*32,4,progress*32)
			surface.DrawRect(xmid+36,ymid-progress*32,4,progress*32)
			surface.SetFont("Scav_ConsoleText")
			local text
			local mod = (CurTime()-currentmelt.StartMeltTime)%3
			if (mod < 1) then
				text = "Melting."
			elseif (mod < 2) then
				text = "Melting.."
			else
				text = "Melting..."
			end
			local w,h = surface.GetTextSize(text)
			surface.SetTextPos(xmid-w/2,ymid-h/2-8)
			surface.SetTextColor(255,255,255,255)
			surface.DrawText(text)
		end
	end)

end

scripted_ents.Register(ENT,"scav_alchmelt",true)