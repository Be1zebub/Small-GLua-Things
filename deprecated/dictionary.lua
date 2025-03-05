-- deprecated
-- use https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/lang.lua

local dictionary = {
	_DESCRIPTION = "Translations lib. Loads translations from github, has sync & async api, has id system (useful for saving network resources, you can just send a UInt over the network instead of a giant string.)",
	_VERSION = 1.0,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/deprecated/dictionary.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2022 gmod.one
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]],
	_EXAMPLE = [[
		AddCSLuaFile("libs/dictionary.lua")
		local dictionary = include("libs/dictionary.lua")

		local dict = dictionary("Be1zebub", "Gmodstore-Gestures-Configuration-files", "main", "langs")

		coroutine.wrap(function() -- sync
			dict:SetLanguage("ru", true) -- set lang & fetch it from github
			local phrase = dict:GetPhrase(1) -- get 1st phrase
			print("phrase:\t", phrase)
			print("id:\t", dict:GetID(phrase)) -- get id from phrase
			print("translation:\t", dict(phrase)) -- translate
		end)()

		dict:DownloadLang("en", function() -- async
			dict:GetPhrase(1, function(phrase)
				print("phrase:\t", phrase)
				dict:GetID(phrase, function(id)
					print("id:\t", id)
				end)
				dict(phrase, function(translation)
					print("translation:\t", translation)
				end)
			end)
		end)
	]]
}

dictionary.__index = dictionary

local api, api_dir = "https://api.github.com/repos/%s/%s/contents", "https://api.github.com/repos/%s/%s/contents/%s"

function dictionary:ListDir(dir, cback)
	local endpoint = dir and api_dir:format(self.repoOwner, self.repoName, self.dir) or api:format(self.repoOwner, self.repoName)
	if self.repoBranch then
		endpoint = endpoint .."?ref=".. self.repoBranch
	end

	local co = coroutine.running()

	http.Fetch(endpoint, function(files)
		files = util.JSONToTable(files)
		cback(files)
		if co then
			coroutine.resume(co, files)
		end
	end)

	if co then
		return coroutine.yield()
	end
end

local is_file = {file = true}

function dictionary:DownloadAll(cback)
	self:ListDir(self.dir, function(files)
		for i, file in ipairs(files) do
			if is_file[file.type] then
				self:DownloadLang(file.name:match("(.+)%..+"))
			end
		end
	end)
end

function dictionary:DownloadLang(lang, cback, onerr)
	local co = coroutine.running()

	http.Fetch(self.raw .."/".. lang ..".lua", function(phrases)
		local map, list = {}, {}

		for phrase, translation in pairs(util.JSONToTable(phrases)) do
			map[phrase] = {
				phrase = phrase,
				translation = translation,
				id = #list + 1
			}
			list[#list + 1] = map[phrase]
		end

		self.cache.map[lang] = map
		self.cache.list[lang] = list

		if cback then
			cback(map, list)
		end

		if co then
			coroutine.resume(co, map, list)
		end
	end, onerr)

	if co then
		return coroutine.yield()
	end
end

function dictionary:SetLanguage(lang, fetch, onfinish)
	self.language = lang

	if fetch and self.cache.map[lang] == nil then
		return self:DownloadLang(lang, onfinish)
	end
end

local function Cache(dict, map, lang, payload, lookup, no_what)
	if coroutine.running() then
		lang = cback or self.Language
	else
		lang = lang or self.Language
	end

	if lang == nil then
		error("Whoops, you need to spicefy a languague to this function.")
	end

	local from = map and dict.cache.map or dict.cache.list

	if coroutine.running() then -- sync
		if from[lang] then
			if from[lang][payload] == nil then
				return error("Ewwww, there is no ".. no_what)
			end
			return from[lang][payload][lookup]
		end

		local co = coroutine.running()

		dict:DownloadLang(lang, function(language)
			coroutine.resume(co, language[payload][lookup])
		end)

		return coroutine.yield()
	elseif cback then -- async
		if from[lang] then
			if from[lang][payload] == nil then
				return error("Ewwww, there is no ".. no_what)
			end
			return cback(from[lang][payload][lookup])
		end

		dict:DownloadLang(lang, function(language)
			cback(language[payload][lookup])
		end)
	else
		error("Wrap this function call in a coroutine to use it sync or pass the callback to the second argument to use it as async!")
	end
end

function dictionary:Get(phrase, cback, lang)
	return Cache(self, true, lang, phrase, "translation", "translation with given phrase!")
end

dictionary.__call = dictionary.Get

function dictionary:GetID(phrase, cback, lang)
	return Cache(self, true, lang, phrase, "id", "id with given phrase!")
end

function dictionary:GetPhrase(id, cback, lang)
	return Cache(self, false, lang, id, "phrase", "phrase with given id!")
end

return function(repoOwner, repoName, repoBranch, dir, preDownloadAll)
	local instance = setmetatable({
		dir = dir,
		cache = {
			map = {},
			list = {}
		},
		repoName = repoName,
		repoOwner = repoOwner,
		repoBranch = repoBranch,
		url = "https://github.com/".. repoOwner .."/".. repoName,
		raw = "https://raw.githubusercontent.com/".. repoOwner .."/".. repoName .."/".. (repoBranch or "main")
	}, dictionary)

	if dir then
		instance.raw = instance.raw .."/".. dir
	end

	if repoBranch then
		instance.url = instance.url .. "/tree/".. repoBranch

		if dir then
			instance.url = instance.url .. "/".. dir
		end
	elseif dir then
		instance.url = instance.url .. "/tree/main/".. dir
	end

	if preDownloadAll then
		instance:DownloadAll()
	end

	return instance
end
