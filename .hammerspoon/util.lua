-- A collection of utility functions. Properly speaking these should form a
-- module, but for now I'm okay with declaring global things at top level

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

-- from https://stackoverflow.com/a/641993, thank you!
function shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

-- adapted from https://www.reddit.com/r/lua/comments/lccolr/comment/glzhd0u/, thank you!
function any(t)
    for _, v in pairs(t) do
        if v then return true end
    end

    return false
end
