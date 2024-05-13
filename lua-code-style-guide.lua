-- lua code style guide
-- describes a good practices and my personal preferences

local camelCase, forVariables

PascalCaseForLibs = {}

function PascalCaseForClasses:AndMethods(camelCase, forArguments)
	-- tabs, tab size 4
end

local doubleQuotes = "instead of single quotes"
local evenWhen = "you need to put \"double quotes\" in string, just escape it!"
local orAtLesat = [[Use "multiline" strings]]

local sequentialArrays = {
	"i",
	"prefer",
	"to",
	"not",
	"do",
	[6] = "this",
	"arrays should be defined without indexes"
}

local associativeObjects = {
	dont = "use",
	["brackets"] = "if possible"
}

local mixedTables = {
	"sequential",
	"come",
	"first",
	["then"] = "we",
	put = "associative"
}

local stringsConcatenation = "i prefer".. toPut .." spaces only between variables, but dont put it near quotes"

ifArgumentsTooLong(
	iPrefer("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
	"to split it",
	"like this"
)

butSingleLongArgument("I prefer to put it in single line. qwertyuiopasdfghjklzxcvbnm1234567890qwertyuiopasdfghjklzxcvbnm1234567890qwertyuiopasdfghjklzxcvbnm1234567890qwertyuiopasdfghjklzxcvbnm1234567890qwertyuiopasdfghjklzxcvbnm1234567890")

-- its good for things like:
PrintTable(
	database.user.getAvatar({
		userid = 1
	})
)

local avoid = "continue", "//", '/* */' -- and any other custom syntax

if dontUse and angleBrackets and ifPossible then end
if (onlyIf or reallyRequired) and dontWasteYourTime and onUseless and monkeyWork then end

if (
	splitTooLong and
	statements and
	likeThis
) then
	local something
elseif (
	(split and complex and logic) and
	(like and this) and
	(player:IsGoodPerson() and player:IsUseGoodCodeStylePractics()) and -- statement of 1st object
	(lorem:IpsumDolor() and sit:Amet()) -- statement of 2rd object
) then
	local something
end

function dontUseElseStatementIfPossible()
	if becauseThisReduces then
		return thePyramidsDepth
	end

	return "Yre not an Egyptian right?"
end

function Pyramids()
	if makeYour then
		if pyramidsDepth then
			if noMoreThan3Floors then

			end
		end
	end

	if (orBetter and doIt and likeThis) == false then return end

	andSplitYourCode("To small functions")
end

while player:GetVelocity():Length() >= player:GetRunSpeed() do

end
-- is better than
repeat

until player:GetVelocity():Length() < player:GetRunSpeed()
-- because while loop is much clean
-- repeat until adds nothing, but the non-obviousness of the code.

function dontUse(gotoStatements)
	goto looksUgly

	modernProgrammingLangues("have a better features than spaghetti", "goto is rudiment of the ancient programming languages our grandfathers used", "its also unsupported in 5.1 & jit")

	::looksUgly::
end

dontUseGlobalsIfPossible = "make globals is a bad practice! make your code modular, include modules with require - this will make your code more structured and clean."

-- require only needed functions
local hmac = require("openssl").hmac.hmac
hmac(...)
-- is better than
local openssl = require("openssl")
openssl.hmac.hmac(...)

local patterns = table.concat({ -- i prefer to write patterns this way, this makes them easy to read & modify.
	"<avatarIcon>",
		"<%!%[", "CDATA%[",
			"(.-)",
		"%]%]>",
	"</avatarIcon>"
})
looksBetterThan = "<avatarIcon><%!%[CDATA%[(.-)%]%]></avatarIcon>" -- huh?
