--[[

This adds wrappers for some functions so that TPScript scripts work on LuaASM without any changes.
(Note that this cannot fix jumps if I ever remove those. So, sorry.)

Also, running this plugin inside LuaASM is easy;
  just uncomment the plugin stuff inside the init.lua file.

--]]

return {
  Wrappers = { -- Adds back the discontinued funcs
    ["add"] = function(Arguments)
        return string.format('opr %s $add %s', Arguments[1], Arguments[2])
    end,
    ["sub"] = function(Arguments)
        return string.format('opr %s $sub %s', Arguments[1], Arguments[2])
    end,
    ["mul"] = function(Arguments)
        return string.format('opr %s $mul %s', Arguments[1], Arguments[2])
    end,
    ["div"] = function(Arguments)
        return string.format('opr %s $div %s', Arguments[1], Arguments[2])
    end
  }
}
