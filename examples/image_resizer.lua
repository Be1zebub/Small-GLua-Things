-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/example/image_resizer.lua

-- this script is a quick solution & demo of CEF power usage
-- i used this to scale-down 100+ images
-- one addon had a huge count of UI icons with an incredibly large size (512px+), while for rendering, it needed a 48x48px MAX.
-- so ive loaded them using asset:// & and exported resized versions in garrysmod/data for further replacement

local code = [[
<script>
	function resizeImage(img, w, h) {
		var canvas = document.createElement("canvas"),
		ctx = canvas.getContext("2d");

		canvas.width = w;
		canvas.height = h;

		ctx.drawImage(img, 0, 0, w, h);

		return canvas.toDataURL();
	}

	var img = new Image;
	img.onload = function() {
		gmod.onResized(resizeImage(this, %s, %s));
	};
	img.src = %q;
</script>
]]

local sub_len = #"data:image/png;base64," + 1

function util.ResizeImage(url, w, h, callback) -- you can use https:// or asset:// protocols
	local worker = vgui.Create("DHTML")
	worker:AddFunction("gmod", "onResized", function(img)
		callback(util.Base64Decode(img:sub(sub_len)))
		worker:Remove()
	end)
	worker:SetHTML(code:format(w, h, url))
end
