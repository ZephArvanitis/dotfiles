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
function any(t)
    for _, v in pairs(t) do
        if v then return true end
    end

    return false
end

-- from https://www.codegrepper.com/code-examples/lua/lua+split+string+by+space, thank you!
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- from https://stackoverflow.com/a/9080080, thanks!
function intoBinary(n)
    local binNum = ""
    if n ~= 0 then
        while n >= 1 do
            if n %2 == 0 then
                binNum = binNum .. "0"
                n = n / 2
            else
                binNum = binNum .. "1"
                n = (n-1)/2
            end
        end
    else
        binNum = "0"
    end
    return binNum
end

function fromLittleEndian(binaryTable)
    local result = 0
    for index, value in ipairs(binaryTable) do
        result = result + value * (2 ^ (index - 1))
    end
    return result
end

-- Decode a public job/cluster ID into an internal integer ID
function decode(externalID)
    local customAlphabet = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ'
    local obfuscateMapping = {26, 9, 1, 3, 19, 20, 24, 0, 7, 8, 28, 6, 22, 16, 15, 10, 21, 14, 11, 29, 5, 23, 30, 4, 17, 25, 31, 13, 27, 12, 2, 18, 52, 33, 39, 43, 55, 40, 50, 61, 35, 44, 48, 37, 51, 59, 63, 36, 45, 34, 49, 32, 53, 46, 58, 57, 38, 42, 54, 62, 47, 60, 41, 56}
    local n = #customAlphabet
    local mapped = 0
    for index = 1, #externalID do
        local i = index - 1  -- account for one-indexing in lua, vs zero in python
        local c = string.sub(externalID, index, index)
        local custom_index = string.find(customAlphabet, c) - 1 -- one-indexing
        mapped = mapped + custom_index * (n ^ i)
    end
    local mappedBinary = intoBinary(mapped)
    -- well it turns out lua uses floats for everything, which isn't a
    -- problem until you're dealing with ints larger than, say, 1e12. But
    -- here we are, so I'm about to re-hash this algorithm to handle things
    -- bit by bit rather than using fast math. :sadpanda:
    local decodedBinary = {}
    for i = 1, 64 do -- 64 is length of obfuscation mapping
        decodedBinary[i] = 0
    end
    for indexPlusOne, value in ipairs(obfuscateMapping) do
        -- check if the value'th least significant digit in the mapped
        -- binary encoding is a 1.
        local valueThBit = string.sub(mappedBinary, value + 1, value + 1)

        -- if so, make the index-th least significant digit in the decoded
        -- value 1
        if valueThBit == '1' then
            decodedBinary[indexPlusOne] = 1
        end
    end
    return fromLittleEndian(decodedBinary)
end

function isExternalID(inputString)
    -- it's an external ID if it consists only of digits
    return string.match(inputString, "%a*") == inputString
end

function isInternalID(inputString)
    -- it can be an internal ID if it consists only of upper/lowercase
    -- letters
    return string.match(inputString, "%d*") == inputString
end
