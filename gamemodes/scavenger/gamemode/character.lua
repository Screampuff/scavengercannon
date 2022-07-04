AddCSLuaFile("character.lua")

characters = {}
characters.charactertables = {}
characters.entswithsoundqueue = {}

function characters.CreateSentence(...)
	local args = {...}
	local tab = {}
	for k,v in pairs(args) do
		table.insert(tab,{["sound"]=v})
	end
	return tab
end

function characters.GetByName(name)
	for k,v in pairs(characters.charactertables) do
		if v.Name == name then
			return v
		end
	end
end

do --define entity methods
	local ENTITY = FindMetaTable("Entity")

	function ENTITY:GetCharacter()
		if not self.Character then
			self.Character = characters.charactertables[self:GetModel()]
		end
		if not self.Character then
			return characters.GetBaseCharacter()
		end
		return self.Character
	end
	
	function ENTITY:SetCharacter(name)
		self.Character = characters.charactertables[name]
	end
	
	function ENTITY:SetCharacterFromModel()
		local model = string.lower(self:GetModel())
		self.Character = characters.charactertables[model]
		if SERVER then
			umsg.Start("EntSetCharacter")
				umsg.Entity(self)
				umsg.String(model)
			umsg.End()
		end
	end
	
	function ENTITY:SetupCharacterSound()
		self.NextSpeak = 0
		self.SoundQueue = {}
		if self:IsPlayer() then
			self.lastpaintime = 0
		end
	end
	
	function ENTITY:InterruptCharacterSound()
		for k,v in pairs(self.SoundQueue) do
			self.SoundQueue[k] = nil
		end
		self.NextSpeak = 0
	end
	
	local pooledsounds = {}
	
	function ENTITY:EmitCharacterSound(sndtab,predicting,interrupt,silent,nonverbal)
		--predicting prevents emitting the sound to the originating player
		--interrupt will halt all sentences and force the sound to play
		--silent prevents the sound from playing but still manages the duration data
		--nonverbal means the sound can be played when the character is already speaking and won't cause the character to be considered speaking
		if not sndtab or (self:IsCharacterSpeaking() and not interrupt and not nonverbal) then
			return
		end
		if type(interrupt) == "table" then
			interrupt = (interrupt==self.LastCharacterSoundTable)
		end
		if interrupt then
			self:InterruptCharacterSound()
		end
		if sndtab.OnPlay then
			sndtab.OnPlay(pl,sndtab)
		end
		if not nonverbal then
			local soundduration = sndtab.Delay
			if not soundduration then
				soundduration = SoundDuration(sndtab.sound)/100*(sndtab.Pitch or 100)
				if soundduration == 0 then
					--BROKEN 10/17/2011:
					--soundduration = SoundDuration("../../hl2/sound/"..sndtab.sound)/100*(sndtab.Pitch or 100)
				end
			end
			self.NextSpeak = CurTime()+soundduration
		end
		if not silent then
			if predicting and SERVER then
				if SERVER then
					local rf = RecipientFilter()
					rf:AddAllPlayers()
					rf:RemovePlayer(self)
					if not table.HasValue(pooledsounds,sndtab.sound) then
						umsg.PoolString(sndtab.sound)
						table.insert(pooledsounds,sndtab.sound)
					end
					umsg.Start("CharacterSound",rf)
						umsg.Entity(self)
						umsg.String(sndtab.sound)
						umsg.Float(sndtab.vol or 100)
						umsg.Float(sndtab.pitch or 100)
					umsg.End()
				else
					predicting = false
				end
			else
				self:EmitSound(sndtab.sound,sndtab.vol,sndtab.pitch)
			end
			self.LastCharacterSoundTable = sndtab
		end
	end

	function ENTITY:EmitCharacterSentence(sentencename,interrupt)
		local char = self:GetCharacter()
		local tabsentence = char.Sentences[sentencename]
		if not tabsentence or (self:IsCharacterSpeaking() and not interrupt) then
			return
		end
		if interrupt then
			self:InterruptCharacterSound()
		end
		
		for k,sndtab in pairs(tabsentence) do
			self:AddCharacterSoundToQueue(sndtab)
		end
		if SERVER then
			umsg.Start("CharSnd_Sent")
				umsg.Entity(self)
				umsg.String(sentencename)
				umsg.Bool(interrupt)
			umsg.End()
		end
	end

	function ENTITY:IsCharacterSpeaking()
		return self.NextSpeak >= CurTime()
	end

	function ENTITY:AddCharacterSoundToQueue(sndtab)
		characters.entswithsoundqueue[self] = true
		table.insert(self.SoundQueue,sndtab)
	end
	
	if CLIENT then
		hook.Add("OnEntityCreated","SetupCharacterSounds",function(ent)
			if ent:IsPlayer() then
				ent:SetupCharacterSound()
			end
		end)
	else
		hook.Add("PlayerInitialSpawn","SetupCharacterSounds",function(ent)
			ent:SetupCharacterSound()
		end)
	end
	
	hook.Add("Think","ProcessCharacterSounds",function()
		for ent,_ in pairs(characters.entswithsoundqueue) do
			if not IsValid(ent) then
				characters.entswithsoundqueue[ent] = nil
			elseif not ent:IsCharacterSpeaking() and ent.SoundQueue[1] then
				local sndtab = table.remove(ent.SoundQueue,1)
				ent:EmitCharacterSound(sndtab,nil,nil,SERVER)
				if not ent.SoundQueue[1] then
					characters.entswithsoundqueue[ent] = nil
				end
			end
		end
	end)
	
	if CLIENT then
		usermessage.Hook("CharSnd_Sent",function(um)
			local ent = um:ReadEntity()
			local sent = um:ReadString()
			local interrupt = um:ReadBool()
			ent:EmitCharacterSentence(sent,interrupt)
		end)
		
		usermessage.Hook("EntSetCharacter",function(um)
			local ent = um:ReadEntity()
			local model = um:ReadString()
			ent:SetCharacter(model)
		end)
		
		usermessage.Hook("CharacterSound",function(um)
			local ent = um:ReadEntity()
			local sound = um:ReadString()
			local vol = um:ReadFloat()
			local pitch = um:ReadFloat()
			ent:EmitSound(sound,vol,pitch)
		end)
	end
end



local BASECHAR = {}
	BASECHAR.__index = BASECHAR
	BASECHAR.Sentences = {}

	BASECHAR.PainSounds = {}
	function BASECHAR:HandlePain(pl,dmginfo) --HandlePain takes a player and the damageinfo the player was hurt with. The default behavior is to select a sound based on the severity of the damage, with the least painful sounds being the lowest-indexed in the CHAR.PainSounds table and the most painful being the highest-indexed in the CHAR.PainSounds table.
		if dmginfo:GetDamageType() == DMG_DROWN then
			return
		end
		local amt = dmginfo:GetDamage()
		local inflictor = dmginfo:GetInflictor()
		local attacker = dmginfo:GetAttacker()
		if #self.PainSounds > 0 then
			if inflictor:IsValid() and (inflictor:GetClass() == "entityflame") and (pl.lastpaintime < CurTime()-0.7) then
				local painsound = self.PainSounds[math.Clamp(#self.PainSounds+math.random(-1,0),1,#self.PainSounds)]
				pl:EmitCharacterSound(painsound,nil,true)
				pl.lastpaintime = CurTime()
			elseif (pl.lastpaintime < CurTime()-1.5) and (amt < pl:Health()) and (forceplay or (amt-math.random(1,49) > 0)) then
				local painsound = self.PainSounds[math.Clamp(math.floor(amt/5)+math.random(-1,1),1,#self.PainSounds)]
				pl:EmitCharacterSound(painsound,nil,true)
				pl.lastpaintime = CurTime()
			end
		end
		return
	end

	BASECHAR.LeftFootsteps = {}
	BASECHAR.RightFootsteps = {}
	function BASECHAR:HandleFootstep(pl,pos,foot,sound,volume,rf)
		volume = math.Clamp(volume*2,0,1)
		local volbonus = volume or 100-100
		if CLIENT and (pl == LocalPlayer()) then
			volbonus = volbonus+10
		else
			volbonus = volbonus+20
		end
		local sndtab
		if (foot == 0) then
			if #self.LeftFootsteps ~= 0 then
				sndtab = table.Random(self.LeftFootsteps)
			end
		else
			if #self.RightFootsteps ~= 0 then
				sndtab = table.Random(self.RightFootsteps)
			end
		end
		if not sndtab then
			return true
		end
		if SERVER or (pl==LocalPlayer()) then
			local vol = sndtab.vol or 100
			sndtab.vol = vol+volbonus
			pl:EmitCharacterSound(sndtab,true,false,false,true)
			sndtab.vol = vol
			--pl:EmitSound(snd.sound,snd.vol*volume+volbonus,snd.pitch)
		end
		return true
	end

	BASECHAR.DeathSounds = {}
	function BASECHAR:HandleDeath(pl,attacker,dmginfo)
		if #self.DeathSounds > 0 then
			pl:EmitCharacterSound(table.Random(self.DeathSounds),false,true)
		end
	end
	
	BASECHAR.TauntSounds = {}
	BASECHAR.TauntRarity = 4
	BASECHAR.KillingSpreeSounds = {}
	
	function BASECHAR:HandleTaunt(attacker,victim,attackersfragsthislife)
		if (#self.KillingSpreeSounds > 0) and (attackersfragsthislife%5 == 0) then
			attacker:EmitCharacterSound(table.Random(self.KillingSpreeSounds))
		elseif (#self.TauntSounds > 0) and (math.random(1,self.TauntRarity) == self.TauntRarity) then
			attacker:EmitCharacterSound(table.Random(self.TauntSounds))
		end
	end

	BASECHAR.JumpSounds = {}
	function BASECHAR:HandleJump(pl)
		if #self.JumpSounds ~= 0 then
			local snd = table.Random(self.JumpSounds)
			--pl:EmitSound(snd.sound,snd.vol,snd.pitch)
			pl:EmitCharacterSound(snd,true,snd,false,false)
		end
	end
	
	function characters.Register(name,tab)
		characters.charactertables[name] = tab
		setmetatable(tab,BASECHAR)
		tab.BaseClass = BASECHAR
	end
	
	function characters.GetBaseCharacter()
		return BASECHAR
	end

do
	local CHAR = {}
	CHAR.Name = "GenericMale"
	CHAR.Type = "Human"
	CHAR.PainSounds = {
					{["sound"]="vo/npc/male01/pain01.wav"},
					{["sound"]="vo/npc/male01/pain02.wav"},
					{["sound"]="vo/npc/male01/pain03.wav"},
					{["sound"]="vo/npc/male01/pain04.wav"},
					{["sound"]="vo/npc/male01/pain05.wav"},
					{["sound"]="vo/npc/male01/pain06.wav"},
					{["sound"]="vo/npc/male01/pain07.wav"},
					{["sound"]="vo/npc/male01/pain08.wav"},
					{["sound"]="vo/npc/male01/pain09.wav"}
				}
	CHAR.DeathSounds = {
					{["sound"]="vo/npc/male01/pain07.wav"},
					{["sound"]="vo/npc/male01/pain08.wav"},
					{["sound"]="vo/npc/male01/pain09.wav"}
				}
	CHAR.TauntSounds = {
					{["sound"]="vo/coast/odessa/male/cheer01"},
					{["sound"]="vo/coast/odessa/male/cheer02"},
					{["sound"]="vo/coast/odessa/male/cheer03"},
					{["sound"]="vo/coast/odessa/male/cheer04"},
					{["sound"]="vo/npc/male/fantastic02"},
					}
	CHAR.JumpSounds = {
					{["sound"]="vo/npc/male01/pain04.wav"}
				}
	
	characters.Register("models/player/group01/male_01.mdl",CHAR)
	characters.Register("models/player/group01/male_02.mdl",CHAR)
	characters.Register("models/player/group01/male_03.mdl",CHAR)
	characters.Register("models/player/group01/male_04.mdl",CHAR)
	characters.Register("models/player/group01/male_05.mdl",CHAR)
	characters.Register("models/player/group01/male_06.mdl",CHAR)
	characters.Register("models/player/group01/male_07.mdl",CHAR)
	characters.Register("models/player/group01/male_08.mdl",CHAR)
	characters.Register("models/player/group01/male_09.mdl",CHAR)
	characters.Register("models/player/group02/male_01.mdl",CHAR)
	characters.Register("models/player/group02/male_02.mdl",CHAR)
	characters.Register("models/player/group02/male_03.mdl",CHAR)
	characters.Register("models/player/group02/male_04.mdl",CHAR)
	characters.Register("models/player/group02/male_05.mdl",CHAR)
	characters.Register("models/player/group02/male_06.mdl",CHAR)
	characters.Register("models/player/group02/male_07.mdl",CHAR)
	characters.Register("models/player/group02/male_08.mdl",CHAR)
	characters.Register("models/player/group02/male_09.mdl",CHAR)
	characters.Register("models/player/group03/male_01.mdl",CHAR)
	characters.Register("models/player/group03/male_02.mdl",CHAR)
	characters.Register("models/player/group03/male_03.mdl",CHAR)
	characters.Register("models/player/group03/male_04.mdl",CHAR)
	characters.Register("models/player/group03/male_05.mdl",CHAR)
	characters.Register("models/player/group03/male_06.mdl",CHAR)
	characters.Register("models/player/group03/male_07.mdl",CHAR)
	characters.Register("models/player/group03/male_08.mdl",CHAR)
	characters.Register("models/player/group03/male_09.mdl",CHAR)
	characters.Register("models/player/group03m/male_01.mdl",CHAR)
	characters.Register("models/player/group03m/male_02.mdl",CHAR)
	characters.Register("models/player/group03m/male_03.mdl",CHAR)
	characters.Register("models/player/group03m/male_04.mdl",CHAR)
	characters.Register("models/player/group03m/male_05.mdl",CHAR)
	characters.Register("models/player/group03m/male_06.mdl",CHAR)
	characters.Register("models/player/group03m/male_07.mdl",CHAR)
	characters.Register("models/player/group03m/male_08.mdl",CHAR)
	characters.Register("models/player/group03m/male_09.mdl",CHAR)
	characters.Register("models/player/breen.mdl",CHAR)
	characters.Register("models/player/eli.mdl",CHAR)
	characters.Register("models/player/kleiner.mdl",CHAR)
	characters.Register("models/player/magnusson.mdl",CHAR)
	characters.Register("models/player/odessa.mdl",CHAR)
	characters.Register("models/player/gman_high.mdl",CHAR)
	characters.Register("models/player/hostage/hostage_01.mdl",CHAR)
	characters.Register("models/player/hostage/hostage_02.mdl",CHAR)
	characters.Register("models/player/hostage/hostage_03.mdl",CHAR)
	characters.Register("models/player/hostage/hostage_04.mdl",CHAR)
	characters.Register("models/player/tf2/sniper_red.mdl",CHAR)
	characters.Register("models/player/tf2/sniper_blue.mdl",CHAR)
	characters.Register("models/player/tf2/spy_red.mdl",CHAR)
	characters.Register("models/player/tf2/spy_blue.mdl",CHAR)
	characters.Register("models/player/solid_snake.mdl",CHAR)
	
	--characters.Register("models/player/group03/male_09.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "Barney"
	CHAR.Type = "Human"
	CHAR.PainSounds = {
				{["sound"]="vo/npc/Barney/ba_pain01.wav"},
				{["sound"]="vo/npc/Barney/ba_pain02.wav"},
				{["sound"]="vo/npc/Barney/ba_pain04.wav"},
				{["sound"]="vo/npc/Barney/ba_pain05.wav"},
				{["sound"]="vo/npc/Barney/ba_pain06.wav"},
				{["sound"]="vo/npc/Barney/ba_pain07.wav"},
				{["sound"]="vo/npc/Barney/ba_pain08wav"},
				{["sound"]="vo/npc/Barney/ba_pain09.wav"},
				{["sound"]="vo/npc/Barney/ba_pain10.wav"},
				{["sound"]="vo/npc/Barney/ba_ohshit03.wav"}
				}
	CHAR.DeathSounds = {
				{["sound"]="vo/npc/Barney/ba_pain03.wav"},
				{["sound"]="vo/npc/Barney/ba_no01.wav"},
				}
	CHAR.KillingSpreeSounds = {
		{["sound"]="vo/npc/Barney/ba_laugh01.wav"},
		{["sound"]="vo/npc/Barney/ba_laugh02.wav"},
		{["sound"]="vo/npc/Barney/ba_laugh03.wav"},
		{["sound"]="vo/npc/Barney/ba_laugh04.wav"},
		{["sound"]="vo/npc/Barney/ba_losttouch.wav"},
		}
	CHAR.TauntSounds = {
		{["sound"]="vo/npc/Barney/ba_bringiton.wav"},
		{["sound"]="vo/npc/Barney/ba_downyougo.wav"},
		{["sound"]="vo/npc/Barney/ba_gotone.wav"},
		{["sound"]="vo/npc/Barney/ba_ohyeah.wav"},
		{["sound"]="vo/npc/Barney/ba_yell.wav"},
		
	}
	CHAR.JumpSounds = {
					{["sound"]="vo/npc/Barney/ba_pain02.wav"},
					{["sound"]="vo/npc/Barney/ba_pain07.wav"}
				}
	CHAR.LeftFootsteps = {
		{["sound"]="npc/metropolice/gear1.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear2.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear3.wav",["vol"]=30},
	}
	CHAR.RightFootsteps = {
		{["sound"]="npc/metropolice/gear4.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear5.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear6.wav",["vol"]=30},
	}
	characters.Register("models/player/barney.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "Alyx"
	CHAR.Type = "Human"
	CHAR.PainSounds = {
				{["sound"]="vo/npc/Alyx/hurt04.wav"},
				{["sound"]="vo/npc/Alyx/gasp03.wav"},
				{["sound"]="vo/npc/Alyx/hurt08.wav"},		
				{["sound"]="vo/npc/Alyx/hurt06.wav"},
				{["sound"]="vo/npc/Alyx/uggh01.wav"},
				{["sound"]="vo/npc/Alyx/uggh02.wav"},
				{["sound"]="vo/npc/Alyx/hurt05.wav"},
				{["sound"]="vo/npc/Alyx/gasp02.wav"}
				}
	CHAR.DeathSounds = {
				{["sound"]="vo/npc/Alyx/hurt05.wav"},
				{["sound"]="vo/NovaProspekt/al_gasp01.wav"},
				{["sound"]="vo/npc/Alyx/gasp02.wav"}
				}
	CHAR.TauntSounds = {
		{["sound"]="vo/npc/Alyx/brutal02.wav"},
		{["sound"]="vo/eli_lab/al_awesome.wav"},
		{["sound"]="vo/eli_lab/al_laugh01.wav"},
		{["sound"]="vo/eli_lab/al_laugh02.wav"},
		{["sound"]="vo/eli_lab/al_sweet.wav"}
	}
	CHAR.JumpSounds = {
					{["sound"]="vo/Citadel/al_struggle07.wav"},
					{["sound"]="vo/Citadel/al_struggle08.wav"}
				}
	characters.Register("models/player/alyx.mdl",CHAR)
	characters.Register("models/smashbros/samlyx.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "CSSGuy"
	CHAR.Type = "Human"
	CHAR.PainSounds = {
				{["sound"]="player/damage1.wav"},
				{["sound"]="player/damage2.wav"},
				{["sound"]="player/damage3.wav"}
				}
	CHAR.DeathSounds = {
				{["sound"]="player/death1.wav"},
				{["sound"]="player/death2.wav"},
				{["sound"]="player/death3.wav"},
				{["sound"]="player/death4.wav"},
				{["sound"]="player/death5.wav"},
				{["sound"]="player/death6.wav"}
				}
	CHAR.JumpSounds = {
				}
	CHAR.TauntRarity = 2
	CHAR.TauntSounds = {
		{["sound"]="radio/enemydown.wav"}
	}
	characters.Register("models/player/urban.mdl",CHAR)
	characters.Register("models/player/swat.mdl",CHAR)
	characters.Register("models/player/gasmask.mdl",CHAR)
	characters.Register("models/player/riot.mdl",CHAR)
	characters.Register("models/player/leet.mdl",CHAR)
	characters.Register("models/player/guerilla.mdl",CHAR)
	characters.Register("models/player/phoenix.mdl",CHAR)
	characters.Register("models/player/arctic.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "Monk"
	CHAR.Type = "Human"
	CHAR.PainSounds = {
				{["sound"]="vo/ravenholm/monk_pain01.wav"},
				{["sound"]="vo/ravenholm/monk_pain02.wav"},
				{["sound"]="vo/ravenholm/monk_pain05.wav"},
				{["sound"]="vo/ravenholm/monk_pain03.wav"},
				{["sound"]="vo/ravenholm/monk_pain06.wav"},
				{["sound"]="vo/ravenholm/monk_pain04.wav"}
				}
	CHAR.DeathSounds = {
				{["sound"]="vo/ravenholm/monk_pain12.wav"},
				{["sound"]="vo/ravenholm/monk_pain07.wav"},
				}
	CHAR.TauntSounds = {
		{["sound"]="vo/ravenholm/monk_kill01.wav"},
		{["sound"]="vo/ravenholm/monk_kill02.wav"},
		{["sound"]="vo/ravenholm/monk_kill03.wav"},
		{["sound"]="vo/ravenholm/monk_kill04.wav"},
		{["sound"]="vo/ravenholm/monk_kill05.wav"},
	}
	CHAR.KillingSpreeSounds = {
		{["sound"]="vo/ravenholm/madlaugh03.wav"}
	}
	CHAR.JumpSounds = {
					{["sound"]="vo/ravenholm/monk_pain02.wav"},
					{["sound"]="vo/ravenholm/monk_pain03.wav"}
				}
	characters.Register("models/player/monk.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "GenericFemale"
	CHAR.Type = "Human"
	CHAR.PainSounds = {
					{["sound"]="vo/npc/female01/pain01.wav"},
					{["sound"]="vo/npc/female01/pain02.wav"},
					{["sound"]="vo/npc/female01/pain03.wav"},
					{["sound"]="vo/npc/female01/pain04.wav"},
					{["sound"]="vo/npc/female01/pain05.wav"},
					{["sound"]="vo/npc/female01/pain06.wav"},
					{["sound"]="vo/npc/female01/pain07.wav"},
					{["sound"]="vo/npc/female01/pain08.wav"},
					{["sound"]="vo/npc/female01/pain09.wav"}
				}
	CHAR.DeathSounds = {
					{["sound"]="vo/npc/female01/pain07.wav"},
					{["sound"]="vo/npc/female01/pain08.wav"},
					{["sound"]="vo/npc/female01/pain09.wav"}
				}
	CHAR.TauntSounds = {
					{["sound"]="vo/coast/odessa/female/cheer01"},
					{["sound"]="vo/coast/odessa/female/cheer02"},
					{["sound"]="vo/npc/female/gotone01"},
					{["sound"]="vo/npc/female/gotone02"},
					}
	CHAR.JumpSounds = {
					{["sound"]="vo/npc/female01/pain02.wav"},
					{["sound"]="vo/npc/female01/pain05.wav"}
				}

	characters.Register("models/player/group01/female_01.mdl",CHAR)
	characters.Register("models/player/group01/female_02.mdl",CHAR)
	characters.Register("models/player/group01/female_03.mdl",CHAR)
	characters.Register("models/player/group01/female_04.mdl",CHAR)
	characters.Register("models/player/group01/female_06.mdl",CHAR)
	characters.Register("models/player/group01/female_07.mdl",CHAR)
	characters.Register("models/player/group02/female_01.mdl",CHAR)
	characters.Register("models/player/group02/female_02.mdl",CHAR)
	characters.Register("models/player/group02/female_03.mdl",CHAR)
	characters.Register("models/player/group02/female_04.mdl",CHAR)
	characters.Register("models/player/group02/female_06.mdl",CHAR)
	characters.Register("models/player/group02/female_07.mdl",CHAR)
	characters.Register("models/player/group03/female_01.mdl",CHAR)
	characters.Register("models/player/group03/female_02.mdl",CHAR)
	characters.Register("models/player/group03/female_03.mdl",CHAR)
	characters.Register("models/player/group03/female_04.mdl",CHAR)
	characters.Register("models/player/group03/female_06.mdl",CHAR)
	characters.Register("models/player/group03/female_07.mdl",CHAR)
	characters.Register("models/player/group03m/female_01.mdl",CHAR)
	characters.Register("models/player/group03m/female_02.mdl",CHAR)
	characters.Register("models/player/group03m/female_03.mdl",CHAR)
	characters.Register("models/player/group03m/female_04.mdl",CHAR)
	characters.Register("models/player/group03m/female_06.mdl",CHAR)
	characters.Register("models/player/group03m/female_07.mdl",CHAR)
	characters.Register("models/player/mossman.mdl",CHAR)
	characters.Register("models/zelda.mdl",CHAR)
	characters.Register("models/player/danboard.mdl",CHAR)
end


do --combine
	local CHAR = {}
	CHAR.Name = "CombineSoldier"
	CHAR.Type = "Combine"
	CHAR.PainSounds = {
				{["sound"]="npc/combine_soldier/pain1.wav",},
				{["sound"]="npc/combine_soldier/pain2.wav"},
				{["sound"]="npc/combine_soldier/pain3.wav"},
				{["sound"]="npc/metropolice/pain1.wav"},
				{["sound"]="npc/metropolice/pain2.wav"},
				{["sound"]="npc/metropolice/pain3.wav"},
				{["sound"]="npc/metropolice/pain4.wav"},
				}
	CHAR.DeathSounds = {
				{["sound"]="npc/combine_soldier/die1.wav"},
				{["sound"]="npc/combine_soldier/die2.wav"},
				{["sound"]="npc/combine_soldier/die3.wav"}
				}
	CHAR.JumpSounds = {
					{["sound"]="npc/combine_soldier/pain1.wav"},
					{["sound"]="npc/combine_soldier/pain2.wav"}
				}
	CHAR.LeftFootsteps = {
		{["sound"]="npc/combine_soldier/gear1.wav",["vol"]=37},
		{["sound"]="npc/combine_soldier/gear2.wav",["vol"]=37},
		{["sound"]="npc/combine_soldier/gear3.wav",["vol"]=37},
	}
	CHAR.RightFootsteps = {
		{["sound"]="npc/combine_soldier/gear4.wav",["vol"]=37},
		{["sound"]="npc/combine_soldier/gear5.wav",["vol"]=37},
		{["sound"]="npc/combine_soldier/gear6.wav",["vol"]=37},
	}
	local tauntsentences = {"Taunt01","Taunt02","Taunt03","Taunt04"}
	function CHAR:HandleTaunt(attacker,victim,attackersfragsthislife)
		if (math.random(1,self.TauntRarity) == self.TauntRarity) then
			attacker:EmitCharacterSentence(table.Random(tauntsentences))
		end
	end
	CHAR.Sentences = {}
	CHAR.Sentences["Taunt01"] = characters.CreateSentence("npc/combine_soldier/vo/on2.wav","npc/metropolice/vo/finalverdictadministered.wav","npc/combine_soldier/vo/off2.wav")
	CHAR.Sentences["Taunt02"] = characters.CreateSentence("npc/combine_soldier/vo/on2.wav","npc/metropolice/vo/sentencedelivered.wav","npc/combine_soldier/vo/off1.wav")
	CHAR.Sentences["Taunt03"] = characters.CreateSentence("npc/combine_soldier/vo/chuckle.wav")
	CHAR.Sentences["Taunt04"] = characters.CreateSentence("npc/combine_soldier/vo/on2.wav","npc/metropolice/vo/getoutofhere.wav","npc/combine_soldier/vo/off2.wav")
	characters.Register("models/player/soldier_stripped.mdl",CHAR)
	characters.Register("models/player/combine_soldier_prisonguard.mdl",CHAR)
	characters.Register("models/player/combine_soldier.mdl",CHAR)
	characters.Register("models/player/combine_super_soldier.mdl",CHAR)
	local CHAR = table.Copy(CHAR)
	CHAR.Name = "MetroPolice"
	CHAR.Type = "Combine"
	CHAR.DeathSounds = {
			{["sound"]="npc/metropolice/die1.wav"},
			{["sound"]="npc/metropolice/die2.wav"},
			{["sound"]="npc/metropolice/die3.wav"},
			{["sound"]="npc/metropolice/die4.wav"}
			}
	CHAR.LeftFootsteps = {
		{["sound"]="npc/metropolice/gear1.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear2.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear3.wav",["vol"]=30},
	}
	CHAR.RightFootsteps = {
		{["sound"]="npc/metropolice/gear4.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear5.wav",["vol"]=30},
		{["sound"]="npc/metropolice/gear6.wav",["vol"]=30},
	}
	CHAR.Sentences = {}
	CHAR.Sentences["Taunt01"] = characters.CreateSentence("npc/metropolice/vo/on2.wav","npc/metropolice/vo/finalverdictadministered.wav","npc/metropolice/vo/off2.wav")
	CHAR.Sentences["Taunt02"] = characters.CreateSentence("npc/metropolice/vo/on2.wav","npc/metropolice/vo/sentencedelivered.wav","npc/metropolice/vo/off2.wav")
	CHAR.Sentences["Taunt03"] = characters.CreateSentence("npc/metropolice/vo/chuckle.wav")
	CHAR.Sentences["Taunt04"] = characters.CreateSentence("npc/metropolice/vo/on2.wav","npc/metropolice/vo/getoutofhere.wav","npc/metropolice/vo/off2.wav")
	characters.Register("models/police.mdl",CHAR)
	characters.Register("models/player/police.mdl",CHAR)
end

do --Zombie
	local CHAR = {}
	CHAR.Name = "Zombie"
	CHAR.Type = "Zombie"
	CHAR.PainSounds = {
					{["sound"]="npc/zombie/zombie_pain1.wav"},
					{["sound"]="npc/zombie/zombie_pain2.wav"},
					{["sound"]="npc/zombie/zombie_pain3.wav"},
					{["sound"]="npc/zombie/zombie_pain4.wav"},
					{["sound"]="npc/zombie/zombie_pain5.wav"},
					{["sound"]="npc/zombie/zombie_pain6.wav"},
					{["sound"]="npc/fast_zombie/fz_frenzy1.wav"},
					{["sound"]="npc/zombie_poison/pz_pain1.wav"},
					{["sound"]="npc/zombie_poison/pz_pain2.wav"},
					{["sound"]="npc/zombie_poison/pz_pain3.wav"}	
				}
	CHAR.LeftFootsteps = {
		{["sound"]="npc/zombie/foot1.wav",["vol"]=50},
		{["sound"]="npc/zombie/foot2.wav",["vol"]=50},
		{["sound"]="npc/zombie/foot3.wav",["vol"]=50}
	}
	CHAR.RightFootsteps = CHAR.LeftFootsteps
	function CHAR:HandleFootstep(pl,pos,foot,sound,volume,rf)
		self.BaseClass.HandleFootstep(self,pl,pos,foot,sound,volume,rf)
		util.Decal("Blood",pos+vector_up,pos-vector_up)
		return true
	end
	CHAR.DeathSounds = {
					{["sound"]="npc/zombie/zombie_die1.wav"},
					{["sound"]="npc/zombie/zombie_die1.wav"},
					{["sound"]="npc/zombie/zombie_die1.wav"},
					{["sound"]="npc/zombie_poison/pz_call1.wav"},
					{["sound"]="npc/zombie_poison/pz_die1.wav"},
					{["sound"]="npc/zombie_poison/pz_die1.wav"}
				}
	CHAR.JumpSounds = {
					{["sound"]="npc/zombie/zombie_pain3.wav"},
					{["sound"]="npc/zombie/zombie_pain4.wav"}
				}
	characters.Register("models/player/corpse1.mdl",CHAR)
	characters.Register("models/player/charple01.mdl",CHAR)
	characters.Register("models/player/zombiefast.mdl",CHAR)
	characters.Register("models/player/classic.mdl",CHAR)
	characters.Register("models/player/hunter.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "Zombine"
	CHAR.Type = "Zombie"
	CHAR.LeftFootsteps = {
		{["sound"]="npc/zombine/gear1.wav",["vol"]=36},
		{["sound"]="npc/zombine/gear2.wav",["vol"]=36},
		{["sound"]="npc/zombine/gear3.wav",["vol"]=36}
	}
	CHAR.PainSounds = {
				{["sound"]="npc/zombine/zombine_pain2.wav"},
				{["sound"]="npc/zombine/zombine_pain4.wav"},
				{["sound"]="npc/zombine/zombine_pain1.wav"},
				{["sound"]="npc/zombine/zombine_pain3.wav"},
				{["sound"]="npc/zombine/zombine_charge2.wav"}
			}
	CHAR.JumpSounds = {
		{["sound"]="npc/zombine/zombine_pain3.wav",["vol"]=50}
	}
	CHAR.DeathSounds = {
		{["sound"]="npc/zombine/zombine_die1.wav"},
		{["sound"]="npc/zombine/zombine_die2.wav"},
	}
	CHAR.RightFootsteps = CHAR.LeftFootsteps
	
	characters.Register("models/player/zombie_soldier.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "Headcrab"
	CHAR.Type = "Alien"
	CHAR.LeftFootsteps = {
		{["sound"]="npc/zombie/foot1.wav",["vol"]=50},
		{["sound"]="npc/zombie/foot2.wav",["vol"]=50},
		{["sound"]="npc/zombie/foot3.wav",["vol"]=50}
	}
	CHAR.RightFootsteps = CHAR.LeftFootsteps
	CHAR.PainSounds = {
				{["sound"]="npc/headcrab/pain1.wav",["pitch"]=70},
				{["sound"]="npc/headcrab/pain2.wav",["pitch"]=70},
				{["sound"]="npc/headcrab/pain3.wav",["pitch"]=70}
			}
	CHAR.JumpSounds = {
		{["sound"]="npc/headcrab/attack1.wav",["vol"]=50}
	}
	CHAR.DeathSounds = {
		{["sound"]="npc/headcrab/die1.wav",["pitch"]=160},
		{["sound"]="npc/headcrab/die2.wav",["pitch"]=160}
	}
	CHAR.RightFootsteps = CHAR.LeftFootsteps
	
	characters.Register("models/player/headcrab.mdl",CHAR)
end

do
	local CHAR = {}
	CHAR.Name = "Stalker"
	CHAR.Type = "Zombie"
	CHAR.LeftFootsteps = {
		{["sound"]="npc/stalker/stalker_footstep_left1.wav",["vol"]=30},
		{["sound"]="npc/stalker/stalker_footstep_left2.wav",["vol"]=30}
	}
	CHAR.RightFootsteps = {
		{["sound"]="npc/stalker/stalker_footstep_right1.wav",["vol"]=30},
		{["sound"]="npc/stalker/stalker_footstep_right2.wav",["vol"]=30}
	}
	CHAR.PainSounds = {
				{["sound"]="npc/stalker/stalker_pain3.wav"},
				{["sound"]="npc/stalker/stalker_pain1.wav"},
				{["sound"]="npc/stalker/stalker_pain2.wav"}
			}
	CHAR.JumpSounds = {
		{["sound"]="npc/stalker/stalker_pain3.wav",["vol"]=30}
	}
	CHAR.DeathSounds = {
		{["sound"]="npc/stalker/stalker_die1.wav"},
		{["sound"]="npc/stalker/stalker_die2.wav"}
	}
	CHAR.KillingSpreeSounds = {
		{["sound"]="npc/stalker/go_alert2a.wav"}
	}

	characters.Register("models/player/stalker.mdl",CHAR)
end

if IsMounted("left4dead") or IsMounted("left4dead2") then
	local zombie = characters.GetByName("Zombie")
	local CHAR = {}
	CHAR.Name = "Hunter"
	CHAR.Type = "Zombie"
	CHAR.LeftFootsteps = zombie.LeftFootsteps
	CHAR.RightFootsteps = zombie.RightFootsteps
	CHAR.PainSounds = {
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_02.wav"},
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_01.wav"},
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_09.wav"},
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_04.wav"},
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_05.wav"},
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_07.wav"},
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_08.wav"},
				{["sound"]="player/hunter/voice/miss/hunter_pouncemiss_03.wav"},
			}
	CHAR.JumpSounds = {
		{["sound"]="player/hunter/voice/attack/hunter_shred_03.wav"},
		{["sound"]="player/hunter/voice/attack/hunter_shred_04.wav"},
		{["sound"]="player/hunter/voice/attack/hunter_shred_05.wav"},
	}
	CHAR.DeathSounds = {
		{["sound"]="player/hunter/voice/death/death02.wav"},
		{["sound"]="player/hunter/voice/death/death04.wav"},
		{["sound"]="player/hunter/voice/death/death06.wav"},
		{["sound"]="player/hunter/voice/death/death07.wav"},
		{["sound"]="player/hunter/voice/death/death08.wav"},
	}
	CHAR.TauntSounds = {
		{["sound"]="player/hunter/voice/idle/hunter_stalk_01.wav"},
		{["sound"]="player/hunter/voice/idle/hunter_stalk_04.wav"},
		{["sound"]="player/hunter/voice/idle/hunter_stalk_05.wav"},
		{["sound"]="player/hunter/voice/idle/hunter_stalk_06.wav"},
		{["sound"]="player/hunter/voice/idle/hunter_stalk_07.wav"},
		{["sound"]="player/hunter/voice/idle/hunter_stalk_08.wav"},
		{["sound"]="player/hunter/voice/idle/hunter_stalk_09.wav"},
	}
	CHAR.KillingSpreeSounds = {
		{["sound"]="player/hunter/voice/attack/hunter_attackmix_01.wav"},
		{["sound"]="player/hunter/voice/attack/hunter_attackmix_02.wav"},
		{["sound"]="player/hunter/voice/attack/hunter_attackmix_03.wav"},
	}

	characters.Register("models/player/hunter.mdl",CHAR)
end
