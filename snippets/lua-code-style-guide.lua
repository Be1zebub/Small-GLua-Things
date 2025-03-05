-- lua code style guide
-- describes a good practices and my personal preferences
-- if you are working with LLM, you can add this file to ai settings

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
	["brackets"] = "if possible",
	["use it only in cases"] = "when no brackets leads syntax errors",
	iMean = "reserved words as keys - like break, return. or it doesnt match ^[%a_][%w_]*$"
}

local mixedTables = {
	"sequential",
	"come",
	"first",
	["then"] = "we",
	put = "associative"
}

local stringsConcatenation = "i prefer".. toPut .." spaces only between variables, but dont put it near quotes. Its personal preference - but i recommend this, since it makes the code easier to read, requires fewer characters to type, and also makes the source of the concatenation more clear."

ifArgumentsTooLong(
	iPrefer("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
	"to split it",
	"like this",
	andEven(
		"like",
		"this"
	)
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

if ( butItsOkey and ifUpstream and requires and thisShittyStyle ) then end

if (
	splitTooLong and
	statements and
	likeThis
) then
	local something
elseif (
	(split and complex and logic) and
	(like and this) and
	(
		player:IsGoodPerson() and player:IsUseGoodCodeStylePractics()
	) and (-- statement of 1st object
		lorem:IpsumDolor() and sit:Amet()
	) -- statement of 2rd object
) then
	local something
end

function DontUseElseStatementIfPossible()
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

	andSplitYourCode("To small functions", "its a great habit.")
end

while ply:GetVelocity():Length() >= ply:GetRunSpeed() do

end
-- is better than
repeat

until ply:GetVelocity():Length() < ply:GetRunSpeed()
-- because while loop is much clean
-- repeat until adds nothing, but the non-obviousness of the code.
-- this shit exists only to flex - we're interested in writing a clean code, not fucking around, right?

function dontUse(gotoStatements)
	goto looksUgly

	modernProgrammingLangues("have a better features than spaghetti", "goto is rudiment of the ancient programming languages our grandfathers used", "its also unsupported in lua 5.1 & luajit - just give up this rudiment and your code will become more compatible.")

	::looksUgly::
end

DontMakeGlobalsIfPossible = "making globals for every shit is a bad practice! think about it - is it really necessary for this variable to be global? perhaps you just can make it local, or share variable with another file using require/include returns..." -- look at this code https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/hook.lua#L13-L21 - they could just replace it with hook.Hooks, but they didnt do it, because its a bad practice.

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
itsMuchBetterThan = "<avatarIcon><%!%[CDATA%[(.-)%]%]></avatarIcon>" -- huh?

-- This file is intended as a recommendation, after all, everyone has their own preferences.
-- But I strongly recommend using at least some of these practices.
