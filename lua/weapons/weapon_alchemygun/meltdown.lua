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
	if CLIENT and (self:GetOwner() == LocalPlayer()) then
		currentmelt = self
	end
	self:SetColor(Color(255,255,255,254))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"MassToComplete")
end

if SERVER then

	function ENT:SetWeapon(wep)
		self:SetOwner(wep:GetOwner())
		self.wep = wep
	end

	function ENT:SetProp(ent)
		self:SetParent(ent)
		self:SetModel(ent:GetModel())
		self:SetMassToComplete(ent:GetPhysicsObject():GetMass())
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
		if not IsValid(owner) then
			return
		end
		local tr = owner:GetEyeTraceNoCursor()
		if not owner:KeyDown(IN_ATTACK2) or not IsValid(owner:GetActiveWeapon()) or (owner:GetActiveWeapon():GetClass() ~= "weapon_alchemygun") or ((self:GetOwner():GetPos():Distance(self:GetPos()+self:OBBCenter()) > 250) and ((tr.Entity ~= self) or (tr.HitPos:Distance(tr.StartPos) > 250))) then
			self:Remove()
			return
		end
		if not IsValid(self:GetParent()) then
			return
		end
		if self.StartMeltTime+self:GetMassToComplete()/kgpersec < CurTime() then
			self:Finish()
		end
	end
end

function ENT:GetProgress()
	return math.Clamp(((self.StartMeltTime+self:GetMassToComplete()/kgpersec)-CurTime())/(self:GetMassToComplete()/kgpersec),0,1)
end



if CLIENT then
	local shinymat = Material("models/shiny")
	function ENT:Draw()
		if not IsValid(self:GetParent()) then
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
		if IsValid(currentmelt) and IsValid(currentmelt:GetParent()) then
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
