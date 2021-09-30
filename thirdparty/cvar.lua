-- https://github.com/SuperiorServers/dash/blob/a0d4347371503b1577d72bed5f6df46d48909f56/lua/dash/libraries/cvar.lua

require 'aes'

cvar = setmetatable({
	GetTable = setmetatable({}, {
		__call = function(self)
			return self
		end
	})
}, {
	__call = function(self, ...)
		return self.Register(...)
	end
})

if SERVER then
	util.AddNetworkString 'cvar.RequestEncryptionKey'

	net('cvar.RequestEncryptionKey', function(len, pl)
		local name = net.ReadString()

		net.Start('cvar.RequestEncryptionKey')
			net.WriteString(name)
			net.WriteString(hook.Call('cvar.RequestEncryptionKey', nil, pl, name) or (name .. pl:SteamID() .. 'super secret unique per player key'))
		net.Send(pl)
	end)

	return
end

require 'hash'
require 'pon'

local CVAR 	= {}
CVAR.__index = CVAR

debug.getregistry().Cvar = CVAR

local data_directory 			= 'cvar'
local data_directory_encrypted 	= 'cvar/encrypted'
local staged_cvars 				= {}
local staged_encrypted_cvars	= {}
local cvars_ordered 			= {}

if (not file.IsDir(data_directory, 'DATA')) then
	file.CreateDir(data_directory)
end

if (not file.IsDir(data_directory_encrypted, 'DATA')) then
	file.CreateDir(data_directory_encrypted)
end

local function decodeVar(fileDir)
	return pcall(pon.decode, util.Decompress(file.Read(fileDir, 'DATA')))
end

local function decodeEncryptedVar(key, fileDir)
	local succ, data = pcall(aes.Decrypt, key, file.Read(fileDir, 'DATA'))

	if succ then
		return pcall(pon.decode, util.Decompress(data))
	end
end

local function encodeVar(data)
	return util.Compress(pon.encode(data))
end

local function encodeEncryptedVar(key, data)
	return aes.Encrypt(key, util.Compress(pon.encode(data)))
end

local function load()
	local files, _ = file.Find(data_directory .. '/*.dat', 'DATA')
	for k, v in ipairs(files) do
		local fileDir = data_directory .. '/' .. v
		local success, var = decodeVar(fileDir)

		if success and istable(var) and isstring(var.Name) and (tostring(var.ID) == v:sub(0, -5)) and istable(var.Metadata) then
			staged_cvars[var.Name] = setmetatable(var, CVAR)
		else
			file.Delete(fileDir)
		end
	end
end

function cvar.Register(name)
	if (not cvar.GetTable[name]) then
		local obj = staged_cvars[name] or setmetatable({
			Name = name,
			ID = hash.MD5(name),
			Metadata = {}
		}, CVAR)

		obj.File = data_directory .. '/' .. obj.ID .. '.dat'

		cvar.GetTable[name] = obj
		table.insert(cvars_ordered, obj)
		staged_cvars[name] = nil
	end

	return cvar.GetTable[name]
end

function cvar.GetOrderedTable()
	return cvars_ordered
end

function cvar.Get(name)
	if (not cvar.GetTable[name]) or (staged_cvars[name]) then
		cvar.Register(name)
	end
	return cvar.GetTable[name]
end

function cvar.SetValue(name, value)
	cvar.Get(name):SetValue(value)
end

function cvar.GetValue(name)
	return (cvar.GetTable[name] ~= nil) and cvar.GetTable[name]:GetValue()
end


function CVAR:ConCommand(func)
	concommand.Add(self.Name, function(p, c, a) func(self, p, a) end)
	return self
end

function CVAR:SetDefault(value, enforce)
	self.DefaultValue = value
	if (self.Value == nil) then
		self.Value = value
	end
	if enforce then
		self:SetType(TypeID(value))
	end
	return self
end

function CVAR:SetValue(value)
	if self:Validate(value) then
		hook.Call('cvar.' .. self.Name, nil, self.Value, value)
		self.Value = value
		self:Save()
	end
	return self
end

function CVAR:AddMetadata(key, value)
	self.Metadata[key] = value
	return self
end

function CVAR:AddCallback(callback)
	hook.Add('cvar.' .. self.Name, callback)
	return self
end

function CVAR:AddInitCallback(callback) -- for encrypted vars
	hook.Add('cvar.Init.' .. self.Name, callback)
	return self
end


function CVAR:Validate(value)
	return true
end

function CVAR:SetType(typeid)
	self.Validate = isfunction(typeid) and typeid or function(self, value)
		return (TypeID(value) == typeid)
	end
	if (not self:Validate(self.Value)) then
		self:Reset()
	end
	return self
end

-- prevent other servers from messing with important cvars, could just store a hash or last modified time serverside but that's less cool and dynamic
-- encrypted vars won't be availible right away
function CVAR:SetEncrypted()
	if self.Encrypted then return self end -- lua refresh

	self.Encrypted = true

	self.File = string.Replace(self.File, data_directory, data_directory_encrypted)

	cvar.GetTable[self.Name] = nil
	staged_cvars[self.Name] = nil

	for k, v in ipairs(cvars_ordered) do
		if (v.ID == self.ID) then
			table.remove(cvars_ordered, k)
			break
		end
	end

	staged_encrypted_cvars[self.Name] = self

	hook('InitPostEntity', 'cvar.' .. self.Name, function()
		net.Start('cvar.RequestEncryptionKey')
			net.WriteString(self.Name)
		net.SendToServer()
	end)

	return self
end

function CVAR:Reset()
	self:SetValue(self.DefaultValue)
end

function CVAR:Save()
	local toSave = {
		Name = self.Name,
		ID = self.ID,
		File = self.File,
		Value = self.Value,
		Metadata = self.Metadata,
		Encrypted = self.Encrypted
	}

	file.Write(self.File, self.Encrypted and encodeEncryptedVar(self.Key, toSave) or encodeVar(toSave))
	return self
end

function CVAR:GetName()
	return self.Name
end

function CVAR:GetValue()
	return self.Value
end

function CVAR:GetMetadata(key)
	return self.Metadata[key]
end

net('cvar.RequestEncryptionKey', function()
	local name, key = net.ReadString(), net.ReadString()

	local obj = staged_encrypted_cvars[name]

	if obj then
		staged_encrypted_cvars[obj.Name] = nil

		if file.Exists(obj.File, 'DATA') then
			local succ, data = decodeEncryptedVar(key, obj.File)

			if succ and data then
				obj = setmetatable(data, CVAR)
			else
				file.Delete(obj.File)
			end
		end

		obj.Key = key

		table.insert(cvars_ordered, obj)
		cvar.GetTable[obj.Name] = obj

		hook.Call('cvar.Init.' .. obj.Name, nil, obj)
	end
end)

load()
