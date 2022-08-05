-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/colorcube.lua

-- https://incredible-gmod.ru/assets/logo.png > image/png
-- path/to/file.html > text/html

local mime = {
   ["hqx"]		= "application/mac-binhex40",
   ["doc"]		= "application/msword",
   ["pdf"]		= "application/pdf",
   ["ps"]		= "application/postscript",
   ["eps"]		= "application/postscript",
   ["ai"]		= "application/postscript",
   ["rtf"]		= "application/rtf",
   ["xls"]		= "application/vnd.ms-excel",
   ["ppt"]		= "application/vnd.ms-powerpoint",
   ["wmlc"]		= "application/vnd.wap.wmlc",
   ["kml"]		= "application/vnd.google-earth.kml+xml",
   ["htm"]		= "text/html",
   ["kmz"]		= "application/vnd.google-earth.kmz",
   ["css"]		= "text/css",
   ["xml"]		= "text/xml",
   ["jardiff"]		= "application/x-java-archive-diff",
   ["jpeg"]		= "image/jpeg",
   ["jpg"]		= "image/jpeg",
   ["js"]		= "application/x-javascript",
   ["pm"]		= "application/x-perl",
   ["atom"]		= "application/atom+xml",
   ["prc"]		= "application/x-pilot",
   ["pdb"]		= "application/x-pilot",
   ["mml"]		= "text/mathml",
   ["rar"]		= "application/x-rar-compressed",
   ["jad"]		= "text/vnd.sun.j2me.app-descriptor",
   ["sea"]		= "application/x-sea",
   ["swf"]		= "application/x-shockwave-flash",
   ["sit"]		= "application/x-stuffit",
   ["tcl"]		= "application/x-tcl",
   ["tk"]		= "application/x-tcl",
   ["der"]		= "application/x-x509-ca-cert",
   ["pem"]		= "application/x-x509-ca-cert",
   ["crt"]		= "application/x-x509-ca-cert",
   ["jng"]		= "image/x-jng",
   ["bmp"]		= "image/x-ms-bmp",
   ["svg"]		= "image/svg+xml",
   ["svgz"]		= "image/svg+xml",
   ["webp"]		= "image/webp",
   ["jar"]		= "application/java-archive",
   ["war"]		= "application/java-archive",
   ["ear"]		= "application/java-archive",
   ["msi"]		= "application/octet-stream",
   ["msp"]		= "application/octet-stream",
   ["msm"]		= "application/octet-stream",
   ["mid"]		= "audio/midi",
   ["midi"]		= "audio/midi",
   ["kar"]		= "audio/midi",
   ["mp3"]		= "audio/mpeg",
   ["ogg"]		= "audio/ogg",
   ["zip"]		= "application/zip",
   ["m4a"]		= "audio/x-m4a",
   ["xhtml"]		= "application/xhtml+xml",
   ["ra"]		= "audio/x-realaudio",
   ["xpi"]		= "application/x-xpinstall",
   ["3gpp"]		= "video/3gpp",
   ["3gp"]		= "video/3gpp",
   ["rpm"]		= "application/x-redhat-package-manager",
   ["mp4"]		= "video/mp4",
   ["wml"]		= "text/vnd.wap.wml",
   ["mpeg"]		= "video/mpeg",
   ["mpg"]		= "video/mpeg",
   ["pl"]		= "application/x-perl",
   ["mov"]		= "video/quicktime",
   ["htc"]		= "text/x-component",
   ["webm"]		= "video/webm",
   ["jnlp"]		= "application/x-java-jnlp-file",
   ["flv"]		= "video/x-flv",
   ["png"]		= "image/png",
   ["m4v"]		= "video/x-m4v",
   ["wbmp"]		= "image/vnd.wap.wbmp",
   ["mng"]		= "video/x-mng",
   ["tiff"]		= "image/tiff",
   ["asx"]		= "video/x-ms-asf",
   ["run"]		= "application/x-makeself",
   ["tif"]		= "image/tiff",
   ["wmv"]		= "video/x-ms-wmv",
   ["7z"]		= "application/x-7z-compressed",
   ["avi"]		= "video/x-msvideo",
   ["asf"]		= "video/x-ms-asf",
   ["shtml"]		= "text/html",
   ["html"]		= "text/html",
   ["cco"]		= "application/x-cocoa",
   ["txt"]		= "text/plain",
   ["rss"]		= "application/rss+xml",
   ["ico"]		= "image/x-icon",
   ["gif"]		= "image/gif"
}

local function getMime(path)
	return mime[path:match("([^\\%.]+)$")]
end