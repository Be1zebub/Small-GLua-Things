-- Example available on: https://glot.io/snippets/fqw1us9t1q
-- Converts lua table to raw text.
-- Made for printing tables to the console on other runtime environments than the glua.
-- It can be also used as json alt.

local strrepeat, pairs, type, format, tostring, print = string.rep, pairs, type, string.format, tostring, print

function table.ToPlain(tbl, indent, out)
    local isend = not out
    out = out or "{\n"

    indent = indent or 1
    for k, v in pairs(tbl) do
        local tabs = strrepeat("   ", indent)
        formatting = tabs .. k .." = "
        if type(v) == "table" then
            out = out .. formatting .."{\n"
            out = out .. table.ToPlain(v, indent + 1, "")
            out = out .. tabs .."},\n"
        else
            out = out .. formatting .. (type(v) == "string" and format("%q", v) or tostring(v)) ..",\n"    
        end
    end
    if isend then out = out .."}\n" end

    return out
end

function table.Print(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        formatting = strrepeat("   ", indent) .. k ..": "
        if type(v) == "table" then
            print(formatting)
            table.Print(v, indent + 1)
        else
            print(formatting .. tostring(v))      
        end
    end
end

if PrintTable then return end
function PrintTable(t) -- GLua like but on pure lua
    print(table.ToPlain(t))
end
