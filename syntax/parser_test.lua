--[[

this is a test for the new syntax in luaasm
the goal: get the output to look like:

1 set a 0
2 set b test
3

(note that the "test" is inside the testing code just to see if i can swap it out with a temp variable)
(also, it needs to start with the first furthest bracketed instruction)
(i might need to restart the [] detector)

--]]

function check(d)
    local a = d:split('\n')
    local b = {}
    for _, line in pairs(a) do
        local q = line:split('""')
        if (#q % 2) > 0 then
            -- Swap out with temp variable
            if #q > 1 then
                local Index = 2
                repeat
                    q[Index] = "__TEMP__" -- make sure this gets numbered and cached
                    Index = Index + 2
                until Index >= #q
            end
            table.insert(b, table.concat(q, " "))
        else
            -- Syntax error
            warn('Syntax error: Singular "". Strings should be wrapped with ""  ""')
            return
        end
    end
    -- This is the part that doesn't work properly. Please help
    for g = 1, #b do
        local z = b[g]:split('[')
        if #z > 1 then
            local i = #z
            repeat
                local fb = z[i]
                print(' ___'.. fb)
                local x = fb:split(']')
                if x[1] and #x > 1 then
                    print(x[1])
                    x[1] = "a"
                    x = table.concat(x, "]")
                    z[i] = x
                end
                i = i - 1
            until i <= 1
        end
        b[g] = table.concat(z, "[")
    end
    table.foreach(b, print)
end
check([[
set a 0
set b [sub [add $ret 1] 2]
]])
