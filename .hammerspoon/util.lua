-- from https://stackoverflow.com/a/27028488 thank you
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

-- from https://stackoverflow.com/a/11671820, thank you!
function map(tbl, f)
    local t = {}
    for k,v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

-- from https://stackoverflow.com/a/641993, thank you!
function shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end


-- adapted from https://www.reddit.com/r/lua/comments/lccolr/comment/glzhd0u/, thank you!
local function any(t)
    for _, v in pairs(t) do
        if v then return true end
    end

    return false
end

-- from https://www.codegrepper.com/code-examples/lua/lua+split+string+by+space, thank you!
local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

