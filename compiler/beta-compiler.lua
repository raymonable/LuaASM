--[[
    # asmJIT [TPScript => Lua 5.1]
      - it's sort of manually obfuscated but not really intentionally

    This does NOT work.
    There are issues with TPScript that cause this compiler to not work in certain syntax situations.
    This is also more inefficient than interpreting it directly as it's compiled into Lua 5.1 bytecode and interpreted inside of Lua.

    Basically, it uses a Lua VM inside of a Lua VM which is worse than interpretation.
    Also, "asmjit" was going to be the new name for LuaASM but I never got to it.
--]]

print('Importing Lua 5.1 Compiler.. This WILL take a moment.')

local asmJIT;
local ___________ = {
	["assert"] = true;["collectgarbage"] = true;["error"] = true;["getfenv"] = true;
	["getmetatable"] = true;["ipairs"] = true;["loadstring"] = true;["newproxy"] = true;
	["next"] = true;["pairs"] = true;["pcall"] = true;["print"] = true;["rawequal"] = true;
	["rawget"] = true;["rawset"] = true;["select"] = true;["setfenv"] = true;["setmetatable"] = true;
	["tonumber"] = true;["tostring"] = true;["type"] = true;["unpack"] = true;["xpcall"] = true;
	["bit32"] = true;["coroutine"] = true;["debug"] = true;
	["math"] = true;["os"] = true;["string"] = true;
	["table"] = true;["utf8"] = true;
	["delay"] = true;["elapsedTime"] = true;["gcinfo"] = true;["require"] = true;
	["settings"] = true;["spawn"] = true;["tick"] = true;["time"] = true;["typeof"] = true;
	["UserSettings"] = true;["wait"] = true;["warn"] = true;["ypcall"] = true;
	["Enum"] = true;["game"] = true;["shared"] = true;["script"] = true;
	["workspace"] = true;["owner"] = true;
	["Axes"] = true;["BrickColor"] = true;["CellId"] = true;["CFrame"] = true;["Color3"] = true;
	["ColorSequence"] = true;["ColorSequenceKeypoint"] = true;["DateTime"] = true;
	["DockWidgetPluginGuiInfo"] = true;["Faces"] = true;["Instance"] = true;["NumberRange"] = true;
	["NumberSequence"] = true;["NumberSequenceKeypoint"] = true;["PathWaypoint"] = true;
	["PhysicalProperties"] = true;["PluginDrag"] = true;["Random"] = true;["Ray"] = true;["Rect"] = true;
	["Region3"] = true;["Region3int16"] = true;["TweenInfo"] = true;["UDim"] = true;["UDim2"] = true;
	["Vector2"] = true;["Vector2int16"] = true;["Vector3"] = true;["Vector3int16"] = true;
}
local _______
local _____ = {}
local ______
local _ = {
	_ = string.format,
	__ = table.concat,
	___ = table.unpack,
	____ = function(__, RemoveFirst) local ___ = __ for i = 1, RemoveFirst do table.remove(___, 1) end return ___ end,
	_____ = function(__) local ___ = _____[__]; _____[__] = true; return (not ___ and string.match(__, "%a+")) and "\"" .. __ .. "\"" or __ end,
	______ = function(__) _____[__] = true end,
	_______ = function(__)
		local ________ = {}
		for ___, ____ in pairs(__) do
			if (not string.find(____, '%.')
				and not string.find(____, "\"")
				and not string.find(____, "'")
				and not _____[____]
				and not ___________[____]
				and not asmJIT.Environment[____])
				or string.find(____, ':')
			then
				if string.match(____, "%a+") ~= nil then
					________[#________ + 1] = "\"" .. ____ .. "\""
				else
					________[#________ + 1] = ____
				end 
			else
				________[#________ + 1] = ____
			end
		end
		return ________
	end,
}
local __________ = {
	--_ = (loadstring(game:GetService('HttpService'):GetAsync('https://raw.githubusercontent.com/raymonable/tpscriptcompiler/main/yueliang.lua'))()), -- comp
	--__ = (loadstring(game:GetService('HttpService'):GetAsync('https://raw.githubusercontent.com/raymonable/tpscriptcompiler/main/fione.lua'))()) -- exec
}
local ______ = {
	_ = {
		-- chk
		["$equ"] = function(...) return _._('%s = (%s == %s and true or false)', ({...})[1], ({...})[3], _._____(({...})[4])) end,
		["$grt"] = function(...) return _._('%s = (%s > %s and true or false)', ({...})[1], ({...})[3], ({...})[4]) end,
		["$lss"] = function(...) return _._('%s = (%s < %s and true or false)', ({...})[1], ({...})[3], ({...})[4]) end,
		["$egrt"] = function(...) return _._('%s = (%s >= %s and true or false)', ({...})[1], ({...})[3], ({...})[4]) end,
		["$elss"] = function(...) return _._('%s = (%s <= %s and true or false)', ({...})[1], ({...})[3], ({...})[4]) end
	},
	__ = {
		-- opr
		["$add"] = function(...) return _._('%s = %s + %s', ({...})[1], ({...})[1], ({...})[3]) end,
		["$sub"] = function(...) return _._('%s = %s - %s', ({...})[1], ({...})[1], ({...})[3]) end,
		["$mul"] = function(...) return _._('%s = %s * %s', ({...})[1], ({...})[1], ({...})[3]) end,
		["$div"] = function(...) return _._('%s = %s / %s', ({...})[1], ({...})[1], ({...})[3]) end
	},
	___ = function(__)
		-- syntax error
		_______ = __
		return __
	end
}
asmJIT = {
	Instructions = {
		-- print
		["logtxt"] = function(...) return _._('print("%s")', _.__({...}, " ")) end,
		["log"] = function(...) return _._('print(%s)', _.__(_._______({...}), ", ")) end,
		-- functions
		["call"] = function(...) local __ = {...}; local ___ = __[1]; __ = _.____(__, 1); return _._('%s(%s)', ___, _.__(_._______(__), ', ')) end,
		["callset"] = function(...) _.______(({...})[1]); local __ = {...}; local ___ = __[1]; local ____ = __[2]; __ = _.____(__, 2); return _._('%s = %s(%s)', ___, ____, _.__(_._______(__), ", ")) end,
		["safecall"] = function(...) local __ = {...}; local ___ = __[1]; __ = _.____(__, 1); return _._('pcall(function()%s(%s)end)', ___, _.__(_._______(__), ', ')) end,
		["safecallset"] = function(...) _.______(({...})[1]); local __ = {...}; local ___ = __[1]; local ____ = __[2]; __ = _.____(__, 2); return _._('_, %s = pcall(function() return %s(%s) end)', ___, ____, _.__(_._______(__), ", ")) end,
		-- variables
		["set"] = function(...) _.______(({...})[1]); return _._('%s = %s', ({...})[1], ({...})[2]) end,
		["setstr"] = function(...) local __ = ({...}); __ = _.____(__, 1); return _._('%s = "%s"', ({...})[1], _.__(__, ' ')) end,
		["setfindex"] = function(...) _.______(({...})[1]); return _._('%s = %s[%s]', ({...})[1], ({...})[2], _._____(({...})[3])) end,
		["setindex"] = function(...) _.______(({...})[1]); return _._('%s[%s] = %s', ({...})[1], _._____(({...})[2]), ({...})[3]) end,
		["chk"] = function(...) _.______(({...})[1]); return (______._[(({...})[2])] and ______._[(({...})[2])](...) or ______.___('Invalid CHK')) end,
		-- operations
		["opp"] = function(...) return _._('%s = not %s', ({...})[1], ({...})[2]) end,
		["neg"] = function(...) return _._('%s = -%s', ({...})[1], ({...})[2]) end,
		["len"] = function(...) return _._('%s = #%s', ({...})[1], ({...})[2]) end,
		["opr"] = function(...) return (______.__[(({...})[2])] and ______.__[(({...})[2])](...) or ______.___('Invalid OPR')) end,
		-- jump
		["jmp"] = function(...) return _._('return jump("%s")', ({...})[1]) end,
		["jmpif"] = function(...) return _._('if %s then return jump("%s") end', ({...})[1], ({...})[2]) end,
		["cjmp"] = function(...) return _._('return cjump("%s")', ({...})[1]) end,
		["cjmpif"] = function(...) return _._('if %s then return cjump("%s") end', ({...})[1], ({...})[2]) end,
		-- other
		["halt"] = function(...) return _._('wait(%s)', tonumber((...)[1]) / 1000) end,
		["tick"] = function(...) return "task.wait()" end,
		-- legacy
		["add"] = ______["__"]["$add"],
		["sub"] = ______["__"]["$sub"],
		["mul"] = ______["__"]["$mul"],
		["div"] = ______["__"]["$div"]
	},
	Headers = "::init\
--[[\
    Compiled using asmJIT\
        This is NOT compatible with regular Lua.\
--]]\
",
	Format = function(UnCompiledScript)
		local UnCompiledScript = UnCompiledScript:gsub('\n;', ';'):gsub('\n', ';'):split(';')
		for Index = 1, #UnCompiledScript do
			UnCompiledScript[Index] = UnCompiledScript[Index]:gsub('^%s*', '')
		end
		return UnCompiledScript
	end,
	IsJump = function(Line)
		local JumpTypes = {"@", ":-", "::"}
		local ___
		for _, Jump in pairs(JumpTypes) do
			if Line:sub(1, #Jump) == Jump then
				___ = Line:sub(#Jump + 1, -1)
			end
		end
		return ___
	end,
	Compile = function(ASM)
		local CompiledScript = asmJIT.Headers
		local UnCompiledScript = asmJIT.Format(ASM)
		for Index, ___ in pairs(UnCompiledScript) do
			if asmJIT.IsJump(___) then
				local Arguments = asmJIT.IsJump(___):split(' ')
				CompiledScript = CompiledScript .. "\n" .. _._('::%s', Arguments[1])
			else
				local Segments = ___:split(' ')
				if #Segments > 1 then
					local InstructionCompiled = false
					for Instruction, CompilerFunction in pairs(asmJIT.Instructions) do
						if Instruction:lower() == Segments[1]:lower() then
							Segments = _.____(Segments, 1)
							CompiledScript = CompiledScript .. "\n" .. CompilerFunction(_.___(Segments))
							InstructionCompiled = true
						end
					end
					if not InstructionCompiled then
						CompiledScript = CompiledScript .. "\n" .. _._('--# %s #--', _._('Instruction "%s" doesn\'t exist.', Segments[1]:upper()))
					end
					if _______ then
						warn('Error while compiling')
						warn(_______)
						return asmJIT.Headers .. 'logtxt("Failed to compile script. Check output.")'
					end
				end
			end
		end
		print(CompiledScript)
		return CompiledScript:gsub('\'', '"')
	end,
	Jump = function(__)
		asmJIT.Environment.script = nil
		asmJIT.Environment.jump = asmJIT.Jump
		asmJIT.Jumps[__]()
	end,
	Jumps = {},
	JumpHeader = "::",
	Environment = getfenv(),
	CreateExecutable = function(Lua)
		local ActiveJump = "init"
		local Jumps = {}
		local ToCompile = Lua:split('\n')
		for Index = 1, #ToCompile do
			if ToCompile[Index]:sub(1, #(asmJIT.JumpHeader)) == asmJIT.JumpHeader then
				if ActiveJump then
					local PossibleReturn = Jumps[ActiveJump][#Jumps[ActiveJump]]
					if PossibleReturn:sub(1, #("return ")) ~= "return " then
						Jumps[ActiveJump][#Jumps[ActiveJump] + 1] = string.format("return jump('%s')", ToCompile[Index]:sub(#(asmJIT.JumpHeader) + 1))
					end
				end
				ActiveJump = ToCompile[Index]:sub(#asmJIT.JumpHeader + 1)
				Jumps[ActiveJump] = {}
			else
				Jumps[ActiveJump][#Jumps[ActiveJump] + 1] = ToCompile[Index]
			end
		end
		for Index, Jump in pairs(Jumps) do
			asmJIT.Jumps[Index] = __________.__(__________._(table.concat(Jump, "\n"), "JIT"), asmJIT.Environment)
		end
		if asmJIT.Jumps["init"] then
			asmJIT.Jump('init')
		else
			error('INIT jump doesn\'t exist, for some reason.')
		end
	end
}

print(asmJIT.Compile([[
cmt btw this doesn't support too many instances;
cmt just a few part types;

callset a game.GetService game HttpService;
callset b a.GetAsync a https://f3xteam.com/bt/export/3pg6;
callset b a.JSONDecode a b;
set b b.Items;
len a b;
set i 0;

@build_loop;
add i 1;
chk z $egrt i a;
setfindex x b i; cmt x is literally the object;
jmpif z finished;
jmp identify;

@identify;
setfindex _a x 1;
chk n $equ _a 0;
jmpif n part;
chk n $equ _a 1;
jmpif n wedge;
chk n $equ _a 4;
jmpif n seat;
jmp build_loop; cmt i am not in the mood to support all types right now;

@part;
callset y Instance.new Part;
jmp basepart;

@wedge;
callset y Instance.new WedgePart;
jmp basepart;

@seat;
callset y Instance.new Seat;
jmp basepart;

@basepart;
setindex y Parent script;
setfindex _a x 4;
setfindex _b x 5;
setfindex _c x 6;
callset d Vector3.new _a _b _c;
setindex y Size d;
setfindex _a x 7;
setfindex _b x 8;
setfindex _c x 9;
setfindex _d x 10;
setfindex _e x 11;
setfindex _f x 12;
setfindex _g x 13;
setfindex _h x 14;
setfindex _i x 15;
setfindex _j x 16;
setfindex _k x 17;
setfindex _l x 18;
callset d CFrame.new _a _b _c _d _e _f _g _h _i _j _k _l;
setindex y CFrame d;
setfindex _a x 19;
setfindex _b x 20;
setfindex _c x 21;
callset d Color3.new _a _b _c;
setindex y Color d;
setfindex _a x 22;
setindex y Material _a;
setfindex _a x 24;
chk _a $equ _a 1;
setindex y CanCollide _a;
setfindex _a x 23;
chk _a $equ _a 1;
setindex y Anchored _a;
setfindex _a x 26;
setindex y Transparency _a;
jmp build_loop;

@finished;
logtxt Finished.;
]]))
