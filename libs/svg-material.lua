-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/svg-material.lua

-- render svg to source engine material using webview
-- SvgMaterial(path, width, height, function(succ, resp) ... end, materialFlags)
-- path is GAME gamePath

local svgBridge = {
	ttl = 60 * 60 * 24,
	pnl = nil,
	queue = {},
	code = [[<html>
	<head>
		<script>
			window.SvgBridge = (uid, b64, width, height) => {
				const svg = atob(b64)
				const svgBlob = new Blob([svg], {type: "image/svg+xml"})
				const svgUrl = URL.createObjectURL(svgBlob)

				const img = new Image()
				const canvas = document.querySelector("canvas")
				const ctx = canvas.getContext("2d")

				img.onload = () => {
					try {
						canvas.width = width
						canvas.height = height

						ctx.drawImage(img, 0, 0, width, height)

						canvas.toBlob((blob) => {
							URL.revokeObjectURL(svgUrl)

							if (blob) {
								const dataURL = canvas.toDataURL("image/png")
								const base64 = dataURL.split(",")[1]

								gmod.OnSuccess(uid, base64)
							} else {
								gmod.OnFailed(uid, "No blob")
							}
						}, "image/png")
					} catch (err) {
						URL.revokeObjectURL(svgUrl)
						gmod.OnFailed(uid, err)
					}
				}

				img.onerror = (err) => {
					URL.revokeObjectURL(svgUrl)
					gmod.OnFailed(uid, err)
				}

				img.src = svgUrl
			}
		</script>
	</head>
	<body>
		<canvas></canvas>
	</body>
	</html>]]
}

do -- cleanup
	local files = file.Find("svg-material/*.png", "DATA")

	for _, fileName in ipairs(files) do
		local filePath = string.format("svg-material/%s", fileName)

		if file.Time(filePath, "DATA") + svgBridge.ttl < os.time() then
			file.Delete(filePath, "DATA")
		end
	end
end

function SvgMaterial(path, width, height, cback, flags)
	if file.Exists(path, "GAME") == false then
		cback(false, "File not found")
		return
	end

	local fileName = path:match("([^/]+)$")
	local uid = string.format("%s-%s-%sx%s", util.CRC(path), fileName, width, height)
	local outPath = string.format("svg-material/%s.png", uid)

	if file.Exists(outPath, "DATA") and file.Time(outPath, "DATA") + svgBridge.ttl > os.time() then
		cback(true, Material("data/" .. outPath, flags))
		return
	end

	if IsValid(svgBridge.pnl) == false then
		svgBridge.pnl = vgui.Create("DHTML")
		svgBridge.pnl:SetHTML(svgBridge.code)
		svgBridge.pnl:SetAlpha(0)
		svgBridge.pnl:SetKeyboardInputEnabled(false)
		svgBridge.pnl:SetMouseInputEnabled(false)
		svgBridge.pnl:AddFunction("gmod", "OnSuccess", function(uid2, b64)
			local resp = svgBridge.queue[uid2]

			if resp then
				local blob = util.Base64Decode(b64)

				file.CreateDir("svg-material")
				file.Write(resp.path, blob)

				resp.cback(true, Material("data/" .. resp.path, resp.flags))
				svgBridge.queue[uid2] = nil
			end
		end)
		svgBridge.pnl:AddFunction("gmod", "OnFailed", function(uid2, err)
			local resp = svgBridge.queue[uid2]

			if resp then
				resp.cback(false, err)
				svgBridge.queue[uid2] = nil
			end
		end)
	end

	timer.Create("SvgToMaterial/gc-bridge", 10, 0, function()
		if IsValid(svgBridge.pnl) then
			svgBridge.pnl:Remove()
			svgBridge.pnl = nil
			svgBridge.queue = {}
		end
	end)

	local raw = file.Read(path, "GAME")
	local b64 = util.Base64Encode(raw)
	local js = string.format("window.SvgBridge(%q, %q, %s, %s)", uid, b64, width, height)

	svgBridge.queue[uid] = {
		cback = cback,
		flags = flags,
		path = outPath
	}
	svgBridge.pnl:QueueJavascript(js)
end

--[[
concommand.Add("svg-test", function(_, _, args)
	local size = tonumber(args[1]) or 128

	SvgMaterial(args[2] or "materials/svg-test/smiling_face_hearts.svg", size, size, function(succ, resp)
		if succ == false then
			print("Failed to load svg material!")
			if istable(resp) then
				PrintTable(resp)
			else
				print(resp)
			end

			hook.Remove("HUDPaint", "svg-material")
			return
		end

		hook.Add("HUDPaint", "svg-material", function()
			surface.SetMaterial(resp)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, size, size)
		end)
	end)
end)
]]--

