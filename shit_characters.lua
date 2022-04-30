local shit_characters = {}

for char, shit in pairs({
	a = {"à","â","ã","å"},
	e = {"è","é","ê","ê","ë"},
	i = {"ì", "í", "î", "ï"},
	o = {"ó","ò","ô","õ"},
	u = {"ù", "ú", "û", "ü"},
	c = {"ç"},
	n = {"ñ"}
}) do
	shit_characters[shit] = char
end

return function(str)
	return str:gsub("[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", shit_characters)
end
