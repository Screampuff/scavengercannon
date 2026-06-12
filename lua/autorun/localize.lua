AddCSLuaFile()

--Localize a Scav string, replacing any instances of %#% with the second, etc. arguments
ScavLocalize = function(...)
	local arg = {...}
	local substr = tostring(table.remove(arg, 1))
	local strang = CLIENT and language.GetPhrase(substr) or substr
	for i, v in ipairs(arg) do
		strang = string.Replace(strang, "%" .. i .. "%", CLIENT and language.GetPhrase(tostring(v)) or tostring(v))
	end
	return strang
end