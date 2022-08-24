--[[

LuaASM / TPScript loader

(You can swap out the Module variable to load tpscript instead.)

--]]

local Module = 'luaasm'
local Modules = {
  ['luaasm'] = {
    url = 'https://raw.githubusercontent.com/raymonable/LuaAsm/main/asm.lua',
    init = function(Loader, Script, Plugins) Loader.Interpret(Script)(Plugins or {}) end
  },
  ['tpscript'] = {
    url = 'https://raw.githubusercontent.com/headsmasher8557/tpscript/main/init.lua',  
    init = function(Loader, Script) Loader.loadstring(Script, false) end
  }
}
local Script = [[
  cmt Put your TPScript here.
]]
if Modules[Module] then
  local Success, Loader = pcall(function()
    return loadstring(game:GetService('HttpService'):GetAsync(Modules[Module].url))()
  end)
  if Success then 
    Modules[Module].init(Loader, Script, {
      -- Put any LuaASM plugins in here.
      --["Full Compatibility"] = "https://raw.githubusercontent.com/raymonable/LuaASM/main/plugins/full_compatiblity.plugin.lua"
    })
  else
    warn('Failed to start interpreter. Please try again!')
  end
end
