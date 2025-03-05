-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/small/looking-like-chars.lua

-- force characters to be replaced by their ascii counterparts

local replacements = {}

for char, lookingLike in pairs({
	a = {"а", "à","â","ã","å"},
	e = {"е", "è","é","ê","ê","ë"},
	i = {"ì", "í", "î", "ï"},
	o = {"о", "ó","ò","ô","õ"},
	u = {"ù", "ú", "û", "ü"},
	c = {"с", "ç"},
	n = {"ñ"}
}) do
	for _, crap in ipairs(lookingLike) do
		replacements[crap] = char
	end
end

return function(str)
	return (
		str:gsub("[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", replacements)
	)
end
