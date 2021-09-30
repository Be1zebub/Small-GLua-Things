-- https://github.com/SuperiorServers/dash/blob/a0d4347371503b1577d72bed5f6df46d48909f56/lua/dash/libraries/netstream.lua

local txnid = 0

local BLOCK_SIZE = 2^16-2^10
local BLODK_SIZE_m1 = BLOCK_SIZE - 1

if SERVER then
	util.AddNetworkString('net.Stream')
end

function net.WriteStream(data, targs)
	-- generate a unique id for this txn
	txnid = (txnid + 1) % 0xFFFF

	-- iterate over the data to send
	local count = 0
	local iter = function()
		local seg = data:sub(count, count + BLODK_SIZE_m1)
		count = count + BLOCK_SIZE

		return seg
	end

	-- send a chunk of data
	local function send()
		local block = iter()

		-- compression
		block = util.Compress(block)

		if block and (block ~= '') then
			local size = block:len()
			net.Start('net.Stream')
				net.WriteUInt(txnid, 16)
				net.WriteUInt(size, 16)
				net.WriteData(block, size)
			if SERVER then
				net.Send(targs)
			else
				net.SendToServer()
			end

			timer.Simple(0.1, send)
		end

	end

	-- write txnid and chunks to be expected
	net.WriteUInt(txnid, 16)
	net.WriteUInt(math.ceil(data:len() / BLOCK_SIZE), 16)

	timer.Simple(0.1, send)
end

local buckets = {}
if SERVER then
	function net.ReadStream(src, callback)
		if not src then
			error('stream source must be provided to receive a stream from a player')
		end
		if not callback then
			error('callback must be provided for stream read completion')
		end
		if not buckets[src] then buckets[src] = {} end
		buckets[src][net.ReadUInt(16)] = {len=net.ReadUInt(16), callback=callback}
	end

	net.Receive('net.Stream', function(_,pl)
		local txnid = net.ReadUInt(16)
		if not buckets[pl] or not buckets[pl][txnid] then
			error('could not receive stream from client. player bucket does not exist or txnid invalid')
		end

		local bucket = buckets[pl][txnid]

		local size = net.ReadUInt(16)
		local data = net.ReadData(size)

		-- decompression
		data = util.Decompress(data)

		bucket[#bucket+1] = data

		if #bucket == bucket.len then
			buckets[pl][txnid] = nil
			bucket.callback(table.concat(bucket))
		end
	end)
else
	function net.ReadStream(callback)
		if not callback then
			error('callback must be provided for stream read completion')
		end
		buckets[net.ReadUInt(16)] = {len=net.ReadUInt(16), callback=callback}
	end

	net.Receive('net.Stream', function(_)
		local txnid = net.ReadUInt(16)
		if not buckets[txnid] then
			error('could not receive stream from server. txnid invalid.')
		end

		local bucket = buckets[txnid]

		local size = net.ReadUInt(16)
		local data = net.ReadData(size)

		-- decompression
		data = util.Decompress(data)

		bucket[#bucket+1] = data

		if #bucket == bucket.len then
			buckets[txnid] = nil
			bucket.callback(table.concat(bucket))
		end
	end)
end
