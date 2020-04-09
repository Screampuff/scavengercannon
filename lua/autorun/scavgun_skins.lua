AddCSLuaFile()

if not CLIENT then return end

local SKIN = {}

CreateClientConVar("scav_skin_plain","0",true,false)

local l = surface.GetTextureID("vgui/sgskin/l")
local r = surface.GetTextureID("vgui/sgskin/r")
local t = surface.GetTextureID("vgui/sgskin/t")
local b = surface.GetTextureID("vgui/sgskin/b")

local tl = surface.GetTextureID("vgui/sgskin/tl")
local tr = surface.GetTextureID("vgui/sgskin/tr")
local bl = surface.GetTextureID("vgui/sgskin/bl")
local br = surface.GetTextureID("vgui/sgskin/br")

local l_holo = surface.GetTextureID("vgui/sgskin/l_holo")
local r_holo = surface.GetTextureID("vgui/sgskin/r_holo")
local t_holo = surface.GetTextureID("vgui/sgskin/t_holo")
local b_holo = surface.GetTextureID("vgui/sgskin/b_holo")
local c_holo = surface.GetTextureID("vgui/sgskin/c_holo")

local tl_holo = surface.GetTextureID("vgui/sgskin/tl_holo")
local tr_holo = surface.GetTextureID("vgui/sgskin/tr_holo")
local bl_holo = surface.GetTextureID("vgui/sgskin/bl_holo")
local br_holo = surface.GetTextureID("vgui/sgskin/br_holo")

local board = surface.GetTextureID("vgui/sgskin/c_holo")
local boardmat = Material("vgui/sgskin/c_holo")

local function getscavmenucolor()
	if IsValid(LocalPlayer()) then
		local col = Color(LocalPlayer():GetPlayerColor().x * 255, LocalPlayer():GetPlayerColor().y * 255, LocalPlayer():GetPlayerColor().z * 255, 255) or Color(255,255,255,255)
		if col then
			return col.r,col.g,col.b,col.a
		else
			return 255,255,255,255
		end
		return 255,255,255,255
	else
		return 0,255,0,math.sin(CurTime())*20+210
	end
end

local FrameVertex = function()
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

function SKIN:DrawGenericBackgroundPlain( x, y, w, h, color )
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
	if color then
		cr,cg,cb,ca = color.r,color.g,color.b,color.a
	else
		cr,cg,cb,ca = getscavmenucolor()
	end
	--holo
		surface.SetDrawColor(cr,cg,cb,ca)
		surface.SetTexture(tl_holo)
		surface.DrawTexturedRect(x1,y1,x2-x1,y2-y1)
		surface.SetTexture(tr_holo)
		surface.DrawTexturedRect(x3,y1,x4-x3,y2-y1)
		surface.SetTexture(bl_holo)
		surface.DrawTexturedRect(x1,y3,x2-x1,y4-y3)
		surface.SetTexture(br_holo)
		surface.DrawTexturedRect(x3,y3,x4-x3,y4-y3)
		
		surface.SetTexture(t_holo)
		surface.DrawTexturedRect(x2,y1,x3-x2,y2-y1)
		surface.SetTexture(r_holo)
		surface.DrawTexturedRect(x3,y2,x4-x3,y3-y2)
		surface.SetTexture(b_holo)
		surface.DrawTexturedRect(x2,y3,x3-x2,y4-y3)
		surface.SetTexture(l_holo)
		surface.DrawTexturedRect(x1,y2,x2-x1,y3-y2)
		
		surface.SetTexture(c_holo)
		surface.DrawTexturedRect(x2,y2,x3-x2,y3-y2)
	
	--border
		surface.SetDrawColor(255,255,255,255)
		
		surface.SetTexture(tl)
		surface.DrawTexturedRect(x,y,cw,ch)
		surface.SetTexture(tr)
		surface.DrawTexturedRect(x+w-cw,y,cw,ch)
		surface.SetTexture(bl)
		surface.DrawTexturedRect(x,y+h-ch,cw,ch)
		surface.SetTexture(br)
		surface.DrawTexturedRect(x+w-cw,y+h-ch,cw,ch)
		
		surface.SetTexture(t)
		surface.DrawTexturedRect(x+cw,y,w-cw*2,ch)
		surface.SetTexture(r)
		surface.DrawTexturedRect(x+w-cw,y+ch,cw,h-ch*2)
		surface.SetTexture(b)
		surface.DrawTexturedRect(x+cw,y+h-ch,w-cw*2,ch)
		surface.SetTexture(l)
		surface.DrawTexturedRect(x,y+cw,ch,h-ch*2)

end

function SKIN:DrawGenericBackground( x, y, w, h, color )
	if GetConVarNumber("scav_skin_plain") != 0 then
		self:DrawGenericBackgroundPlain(x,y,w,h,color)
		return
	end
	--local cw = math.min(16,w/2)
	--local ch = math.min(16,h/2)
	local cw = math.min(16,w/2,h/2)
	local ch = cw
	local cr,cg,cb,ca
	if color then
		cr,cg,cb,ca = color.r,color.g,color.b,color.a
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
		
		surface.SetTexture(board)
		colvec.r = cr/255
		colvec.g = cg/255
		colvec.b = cb/255

		surface.DrawPoly(framevertices)
		render.SetStencilReferenceValue(1.0)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			surface.SetTexture(board)
			surface.DrawTexturedRect(x,y,ScrW(),ScrH())
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_GREATER)
		render.SetStencilEnable(false)
		boardmat:SetVector("$color",vector_white)

	--border
		surface.SetDrawColor(255,255,255,255)
		
		surface.SetTexture(tl)
		surface.DrawTexturedRect(x,y,cw,ch)
		surface.SetTexture(tr)
		surface.DrawTexturedRect(x+w-cw,y,cw,ch)
		surface.SetTexture(bl)
		surface.DrawTexturedRect(x,y+h-ch,cw,ch)
		surface.SetTexture(br)
		surface.DrawTexturedRect(x+w-cw,y+h-ch,cw,ch)
		
		surface.SetTexture(t)
		surface.DrawTexturedRect(x+cw,y,w-cw*2,ch)
		surface.SetTexture(r)
		surface.DrawTexturedRect(x+w-cw,y+ch,cw,h-ch*2)
		surface.SetTexture(b)
		surface.DrawTexturedRect(x+cw,y+h-ch,w-cw*2,ch)
		surface.SetTexture(l)
		surface.DrawTexturedRect(x,y+cw,ch,h-ch*2)

end

function SKIN:PaintTab( panel )
	local w = panel:GetWide()
	local h = panel:GetTall()
	local cw = math.min(16,w/2,h/2)
	local ch = cw
	local cr,cg,cb,ca
	if !panel.mb_bgColor then
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
		surface.SetTexture(tl_holo)
		surface.DrawTexturedRect(0,0,cw,ch)
		surface.SetTexture(tr_holo)
		surface.DrawTexturedRect(w-cw,0,cw,ch)
		surface.SetTexture(t_holo)
		surface.DrawTexturedRect(cw,0,w-cw*2,ch)
		surface.SetTexture(l_holo)
		surface.DrawTexturedRect(0,ch,cw,ch)
		surface.SetTexture(r_holo)
		surface.DrawTexturedRect(w-cw,ch,cw,ch)
		surface.SetTexture(c_holo)
		surface.DrawTexturedRect(cw,ch,w-cw*2,h-ch)
	surface.SetDrawColor(255,255,255,255)
		surface.SetTexture(tl)
		surface.DrawTexturedRect(0,0,cw,ch)
		surface.SetTexture(tr)
		surface.DrawTexturedRect(w-cw,0,cw,ch)
		surface.SetTexture(t)
		surface.DrawTexturedRect(cw,0,w-cw*2,ch)
		surface.SetTexture(l)
		surface.DrawTexturedRect(0,ch,cw,ch)
		surface.SetTexture(r)
		surface.DrawTexturedRect(w-cw,ch,cw,ch)
end

function SKIN:PaintFrame( panel )
	local w = panel:GetWide()
	local h = panel:GetTall()
	if (GetConVarNumber("scav_skin_plain") == 1) then
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
		if (GetConVarNumber("scav_skin_plain") == 1) then
			self:DrawGenericBackgroundPlain(0,0,w,h,panel.m_bgColor)
		else
			self:DrawGenericBackground(0,0,w,h,panel.m_bgColor)
		end
	end	
end

	--draw.RoundedBox( 4, 0, 0, panel:GetWide(), panel:GetTall(), self.frame_border )
	--draw.RoundedBox( 4, 1, 1, panel:GetWide()-2, panel:GetTall()-2, self.frame_title )
	--draw.RoundedBoxEx( 4, 2, 21, panel:GetWide()-4, panel:GetTall()-23, self.bg_color, false, false, true, true )

derma.DefineSkin("sg_menu","Scavenger Cannon Menu",SKIN)