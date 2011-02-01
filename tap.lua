local os = require("os")
module(..., package.seeall)

local counter = 1
local failed  = false

function ok(assert_true, desc)
   local msg = ( assert_true and "ok " or "not ok " ) .. counter
   if ( not assert_true ) then
      failed = true
   end
   if ( desc ) then
      msg = msg .. " - " .. desc
   end
   print(msg)
   counter = counter + 1
end

function is_deeply(got, expect, msg, context)
    if ( type(expect) ~= "table" ) then
        print("# Expected [" .. context .. "] to be a table")
        ok(false, msg)
        return false
    end
    for k, v in pairs(expect) do
        local ctx
        if ( nil == context ) then
            ctx = k
        else
            ctx = context .. "." .. k
        end
        if type(expect[k]) == "table" then
            if ( not is_deeply(got[k], expect[k], msg, ctx) ) then
                return false
            end
        else
            if ( got[k] ~= expect[k] ) then
                print("# Expected [" .. ctx .. "] to be '"
                      .. tostring(expect[k]) .. "', but got '"
                      .. tostring(got[k])
                      .. "'")
                ok(false, msg)
                return false
            end
        end
    end
    if ( nil == context ) then
        ok(true, msg);
    end
    return true
end

function exit()
   os.exit(failed and 1 or 0)
end