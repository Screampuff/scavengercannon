AddCSLuaFile()

if not CLIENT then return end

local SKIN = {}

CreateClientConVar("scav_skin_plain","0",true,false)

local l = Material("vgui/sgskin/l")
local r = Material("vgui/sgskin/r")
local t = Material("vgui/sgskin/t")
local b = Material("vgui/sgskin/b")

local tl = Material("vgui/sgskin/tl")
local tr = Material("vgui/sgskin/tr")
local bl = Material("vgui/sgskin/bl")
local br = Material("vgui/sgskin/br")

local l_holo = Material("vgui/sgskin/l_holo")
local r_holo = Material("vgui/sgskin/r_holo")
local t_holo = Material("vgui/sgskin/t_holo")
local b_holo = Material("vgui/sgskin/b_holo")
local c_holo = Material("vgui/sgskin/c_holo")

local tl_holo = Material("vgui/sgskin/tl_holo")
local tr_holo = Material("vgui/sgskin/tr_holo")
local bl_holo = Material("vgui/sgskin/bl_holo")
local br_holo = Material("vgui/sgskin/br_holo")

local board = Material("vgui/sgskin/c_holo")
local boardmat = Material("vgui/sgskin/c_holo")

local function getscavmenucolor()
	if IsValid(LocalPlayer()) then
		local col = LocalPlayer():GetWeaponColor()
		if col then
			return col.r,col.g,col.b,col.a
		else
			return 255,255,255,255
		end
	else
		return 0,255,0,math.sin(CurTime())*20+210
	end
end

local function FrameVertex()
	return {x=0,y=0,u=0,v=0}
end

local VERTEX_L_TOP = 1
local VERTEX_T_LEFT = 2
local VERTEX_T_RIGHT = 3
local VERTEX_R_TOP = 4
local VERTEX_R_BOTTOM = 5
local VERTEX_B_RIGHT = 6
local VERTEX_B_LEFT = 7
local VERTEX_L_BOTTOM = 8

local framevertices = {FrameVertex(),FrameVertex(),FrameVertex(),FrameVertex(),FrameVertex(),FrameVertex(),FrameVertex(),FrameVertex()}

local colvec = Vector()
local vector_white = Vector(1,1,1)

function SKIN:DrawGenericBackgroundPlain( x, y, w, h, col )
	--local cw = math.min(16,w/2)
	--local ch = math.min(16,h/2)
	local cw = math.min(16,w/2,h/2)
	local ch = cw
	local x1 = math.floor(x)
	local x2 = x1+math.floor(cw)
	local x3 = x1+math.floor(w-cw)
	local x4 = x1+math.floor(w)
	local y1 = math.floor(y)
	local y2 = y1+math.floor(ch)
	local y3 = y1+math.floor(h-ch)
	local y4 = y1+math.floor(h)
	
	local cr,cg,cb,ca
	if col then
		cr,cg,cb,ca = col.r,col.g,col.b,col.a
	else
		cr,cg,cb,ca = getscavmenucolor()
	end
	--holo
		surface.SetDrawColor(cr,cg,cb,ca)
		surface.SetMaterial(tl_holo)
		surface.DrawTexturedRect(x1,y1,x2-x1,y2-y1)
		surface.SetMaterial(tr_holo)
		surface.DrawTexturedRect(x3,y1,x4-x3,y2-y1)
		surface.SetMaterial(bl_holo)
		surface.DrawTexturedRect(x1,y3,x2-x1,y4-y3)
		surface.SetMaterial(br_holo)
		surface.DrawTexturedRect(x3,y3,x4-x3,y4-y3)
		
		surface.SetMaterial(t_holo)
		surface.DrawTexturedRect(x2,y1,x3-x2,y2-y1)
		surface.SetMaterial(r_holo)
		surface.DrawTexturedRect(x3,y2,x4-x3,y3-y2)
		surface.SetMaterial(b_holo)
		surface.DrawTexturedRect(x2,y3,x3-x2,y4-y3)
		surface.SetMaterial(l_holo)
		surface.DrawTexturedRect(x1,y2,x2-x1,y3-y2)
		
		surface.SetMaterial(c_holo)
		surface.DrawTexturedRect(x2,y2,x3-x2,y3-y2)
	
	--border
		surface.SetDrawColor(255,255,255,255)
		
		surface.SetMaterial(tl)
		surface.DrawTexturedRect(x,y,cw,ch)
		surface.SetMaterial(tr)
		surface.DrawTexturedRect(x+w-cw,y,cw,ch)
		surface.SetMaterial(bl)
		surface.DrawTexturedRect(x,y+h-ch,cw,ch)
		surface.SetMaterial(br)
		surface.DrawTexturedRect(x+w-cw,y+h-ch,cw,ch)
		
		surface.SetMaterial(t)
		surface.DrawTexturedRect(x+cw,y,w-cw*2,ch)
		surface.SetMaterial(r)
		surface.DrawTexturedRect(x+w-cw,y+ch,cw,h-ch*2)
		surface.SetMaterial(b)
		surface.DrawTexturedRect(x+cw,y+h-ch,w-cw*2,ch)
		surface.SetMaterial(l)
		surface.DrawTexturedRect(x,y+cw,ch,h-ch*2)

end

function SKIN:DrawGenericBackground( x, y, w, h, col )
	if GetConVar("scav_skin_plain"):GetBool() then
		self:DrawGenericBackgroundPlain(x,y,w,h,col)
		return
	end
	--local cw = math.min(16,w/2)
	--local ch = math.min(16,h/2)
	local cw = math.min(16,w/2,h/2)
	local ch = cw
	local cr,cg,cb,ca
	if col then
		cr,cg,cb,ca = col.r,col.g,col.b,col.a
	else
		cr,cg,cb,ca = getscavmenucolor()
	end
	--surface.SetDrawColor(255,255,255,255)
	surface.SetDrawColor(cr,cg,cb,ca)
	local cwscale = cw/16
	local chscale = ch/16
	local texrpt = 10
	local texscale = 1
	
	--render.SetViewPort(-x,-y,ScrW(),ScrH())
	
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilReferenceValue(1.0)
	
	--Let's do the easy ones first, then...
		framevertices[VERTEX_L_TOP].x,framevertices[VERTEX_L_BOTTOM].x = x+2,x+2
		framevertices[VERTEX_R_TOP].x,framevertices[VERTEX_R_BOTTOM].x = x+w-2,x+w-2
		framevertices[VERTEX_T_LEFT].y,framevertices[VERTEX_T_RIGHT].y = y+2,y+2
		framevertices[VERTEX_B_LEFT].y,framevertices[VERTEX_B_RIGHT].y = y+h-2,y+h-2
	--FUCK EVERYTHING
		framevertices[VERTEX_L_TOP].y = y+ch-11*chscale
		framevertices[VERTEX_L_BOTTOM].y = y+h-ch+6*chscale
		framevertices[VERTEX_R_TOP].y = y+ch-3*chscale
		framevertices[VERTEX_R_BOTTOM].y = y+h-ch+9*chscale
		
		framevertices[VERTEX_T_LEFT].x = x+cw-11*cwscale
		framevertices[VERTEX_T_RIGHT].x = x+w-cw+3*cwscale
		framevertices[VERTEX_B_LEFT].x = x+cw-7*cwscale
		framevertices[VERTEX_B_RIGHT].x = x+w-cw+10*cwscale
		
	--calculate the UVs
		framevertices[VERTEX_T_LEFT].u = (framevertices[VERTEX_T_LEFT].x-x)/w
		framevertices[VERTEX_B_LEFT].u = (framevertices[VERTEX_B_LEFT].x-x)/w
		framevertices[VERTEX_T_RIGHT].u = (1-(x+w-framevertices[VERTEX_T_RIGHT].x)/w)*texrpt
		framevertices[VERTEX_B_RIGHT].u = (1-(x+w-framevertices[VERTEX_B_RIGHT].x)/w)*texrpt
		
		framevertices[VERTEX_L_TOP].v = (framevertices[VERTEX_L_TOP].y-y)/h
		framevertices[VERTEX_R_TOP].v = (framevertices[VERTEX_R_TOP].y-y)/h
		framevertices[VERTEX_L_BOTTOM].v = (1-(y+h-framevertices[VERTEX_L_BOTTOM].y)/h)*texrpt
		framevertices[VERTEX_R_BOTTOM].v = (1-(y+h-framevertices[VERTEX_R_BOTTOM].y)/h)*texrpt

		framevertices[VERTEX_T_LEFT].v = 0
		framevertices[VERTEX_T_RIGHT].v = 0
		framevertices[VERTEX_B_LEFT].v = 1
		framevertices[VERTEX_B_RIGHT].v = 1
		
		framevertices[VERTEX_L_TOP].u = 0
		framevertices[VERTEX_L_BOTTOM].u = 0
		framevertices[VERTEX_R_TOP].u = 1
		framevertices[VERTEX_R_BOTTOM].u = 1
		
		surface.SetMaterial(board)
		colvec.r = cr/255
		colvec.g = cg/255
		colvec.b = cb/255

		surface.DrawPoly(framevertices)
		render.SetStencilReferenceValue(1.0)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			surface.SetMaterial(board)
			surface.DrawTexturedRect(x,y,ScrW(),ScrH())
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_GREATER)
		render.SetStencilEnable(false)
		boardmat:SetVector("$color",vector_white)

	--border
		surface.SetDrawColor(255,255,255,255)
		
		surface.SetMaterial(tl)
		surface.DrawTexturedRect(x,y,cw,ch)
		surface.SetMaterial(tr)
		surface.DrawTexturedRect(x+w-cw,y,cw,ch)
		surface.SetMaterial(bl)
		surface.DrawTexturedRect(x,y+h-ch,cw,ch)
		surface.SetMaterial(br)
		surface.DrawTexturedRect(x+w-cw,y+h-ch,cw,ch)
		
		surface.SetMaterial(t)
		surface.DrawTexturedRect(x+cw,y,w-cw*2,ch)
		surface.SetMaterial(r)
		surface.DrawTexturedRect(x+w-cw,y+ch,cw,h-ch*2)
		surface.SetMaterial(b)
		surface.DrawTexturedRect(x+cw,y+h-ch,w-cw*2,ch)
		surface.SetMaterial(l)
		surface.DrawTexturedRect(x,y+cw,ch,h-ch*2)

end

function SKIN:PaintTab( panel )
	local w = panel:GetWide()
	local h = panel:GetTall()
	local cw = math.min(16,w/2,h/2)
	local ch = cw
	local cr,cg,cb,ca
	if not panel.mb_bgColor then
		cr,cg,cb,ca = getscavmenucolor()
	else
		cr,cg,cb,ca = panel.mb_bgColor.r,panel.mb_bgColor.g,panel.mb_bgColor.b,panel.mb_bgColor.a
	end
	--local cw = math.min(16,w/2)
	--local ch = math.min(16,h/2)
	
	if ( panel:GetPropertySheet():GetActiveTab() == panel ) then
		a = 255
		cr = math.min(255,cr+100)
		cg = math.min(255,cg+100)
		cb = math.min(255,cb+100)
	end
		surface.SetDrawColor(cr,cg,cb,ca)
		surface.SetMaterial(tl_holo)
		surface.DrawTexturedRect(0,0,cw,ch)
		surface.SetMaterial(tr_holo)
		surface.DrawTexturedRect(w-cw,0,cw,ch)
		surface.SetMaterial(t_holo)
		surface.DrawTexturedRect(cw,0,w-cw*2,ch)
		surface.SetMaterial(l_holo)
		surface.DrawTexturedRect(0,ch,cw,ch)
		surface.SetMaterial(r_holo)
		surface.DrawTexturedRect(w-cw,ch,cw,ch)
		surface.SetMaterial(c_holo)
		surface.DrawTexturedRect(cw,ch,w-cw*2,h-ch)
	surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(tl)
		surface.DrawTexturedRect(0,0,cw,ch)
		surface.SetMaterial(tr)
		surface.DrawTexturedRect(w-cw,0,cw,ch)
		surface.SetMaterial(t)
		surface.DrawTexturedRect(cw,0,w-cw*2,ch)
		surface.SetMaterial(l)
		surface.DrawTexturedRect(0,ch,cw,ch)
		surface.SetMaterial(r)
		surface.DrawTexturedRect(w-cw,ch,cw,ch)
end

function SKIN:PaintFrame( panel )
	local w = panel:GetWide()
	local h = panel:GetTall()
	if (GetConVar("scav_skin_plain"):GetBool()) then
		self:DrawGenericBackgroundPlain(0, 28, panel:GetWide(), panel:GetTall()-28, panel.m_bgColor)
		self:DrawGenericBackgroundPlain(0, 0, panel:GetWide(), 28, panel.m_bgColor)
	 else
		self:DrawGenericBackground(0, 28, panel:GetWide(), panel:GetTall()-28, panel.m_bgColor)
		self:DrawGenericBackground(0, 0, panel:GetWide(), 28, panel.m_bgColor)
	end
	
end

function SKIN:LayoutFrame( panel )
	panel.lblTitle:SetFont("Scav_MenuLarge")
	panel.btnClose:SetPos(panel:GetWide()-32,4)
	panel.btnClose:SetSize(18,18)
	panel.lblTitle:SetPos(8,2)
	panel.lblTitle:SetSize(panel:GetWide()-25,20)
end

function SKIN:PaintPanel( panel )
	if (panel.m_bPaintBackground) then
		local w, h = panel:GetSize()
		if (GetConVar("scav_skin_plain"):GetBool()) then
			self:DrawGenericBackgroundPlain(0,0,w,h,panel.m_bgColor)
		else
			self:DrawGenericBackground(0,0,w,h,panel.m_bgColor)
		end
	end	
end

derma.DefineSkin("sg_menu","Scavenger Cannon Menu",SKIN)
