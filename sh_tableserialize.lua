function table.ToPlain(tbl, indent, out)
    local isend = not out
    out = out or "{\n"

    indent = indent or 1
    for k, v in pairs(tbl) do
        local tabs = string.rep("   ", indent)
        formatting = tabs .. k .." = ".. (type(v) == "table" and "{" or "")
        if type(v) == "table" then
            out = out .. formatting .."\n"
            out = out .. table.ToPlain(v, indent + 1, "")
            out = out .. tabs .."},\n"
        else
            out = out .. formatting .. (type(v) == "string" and string.format("%q", v) or tostring(v)) ..",\n"    
        end
    end
    if isend then out = out .."}\n" end

    return out
end

function table.Print(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("   ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            table.Print(v, indent + 1)
        else
            print(formatting .. tostring(v))      
        end
    end
end

function PrintTable(t)
    print(table.ToPlain(t))
end
