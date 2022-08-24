--[[

This is a TEST compiler.

Lots of changes are necessary to LuaASM in order to have this working 100% of the time.
Simple syntax should be functional, but more advanced syntax will not work.

Also, this REALLY will need a rewrite if I finish this.
Thanks :3

--]]

local syntax_error
local already_set_variables = {}
local instructions = {
	["logtxt"] = function(...)
		return string.format('print("%s")', table.concat(table.pack(...), " "))
	end,
	["log"] = function(...)
		return string.format('print(%s)', table.concat(table.pack(...), ", "))
	end,
	["call"] = function(...)
		local args = table.pack(...)
		local tocall = args[1]
		table.remove(args, 1)
		return tocall .. '('..table.concat(args, ", ")..')'
	end,
	["set"] = function(...)
		local args = table.pack(...)
		local variable_name = args[1]
		table.remove(args, 1)
		if not table.find(already_set_variables, variable_name) then
			table.insert(already_set_variables, variable_name)
			return string.format('local %s = %s', variable_name, args[1]) -- this'll need to be fixed for when i add function and jump support
			-- .. how am i gonna do jumps LOL
		else
			return string.format('%s = %s', variable_name, args[1])
		end
	end,
	["callset"] = function(...)
		local args = table.pack(...)
		local variable_name = args[1]
		table.remove(args, 1)
		local func_name = args[1]
		table.remove(args, 1)
		if not table.find(already_set_variables, variable_name) then
			table.insert(already_set_variables, variable_name)
			return string.format('local %s = %s('..table.concat(args, ', ')..')', variable_name, func_name) -- this'll need to be fixed for when i add function and jump support
			-- .. how am i gonna do jumps LOL
		else
			return string.format('%s = %s('..table.concat(args, ', ')..')', variable_name, func_name)
		end
	end,
	["cmt"] = function(...)
		return "-- ".. table.concat(table.pack(...), " ")
	end,
	["setindex"] = function(...)
		local args = table.pack(...)
		return string.format("%s[%s] = %s", args[1], (not table.find(already_set_variables, args[2]) and '"' .. args[2] .. '"' or args[2]), args[3])
	end,
	["setfindex"] = function(...)
		local args = table.pack(...)
		local variable_name = args[1]
		table.remove(args, 1)
		if not table.find(already_set_variables, variable_name) then
			table.insert(already_set_variables, variable_name)
			return string.format('local %s = %s[%s]', variable_name, args[1], (not table.find(already_set_variables, args[2]) and '"' .. args[2] .. '"' or args[2])) -- this'll need to be fixed for when i add function and jump support
			-- .. how am i gonna do jumps LOL
		else
			return string.format('%s = %s[%s]', variable_name, args[1], (not table.find(already_set_variables, args[2]) and '"' .. args[2] .. '"' or args[2]))
		end
	end,
	["opp"] = function(Variable)
		return string.format(Variable .. " = not "..Variable)
	end,
	["neg"] = function(Variable)
		return string.format(Variable .. " = -"..Variable)
	end,
	["len"] = function(...)
		local args = table.pack(...)
		local variable_name = args[1]
		table.remove(args, 1)
		if not table.find(already_set_variables, variable_name) then
			table.insert(already_set_variables, variable_name)
			return string.format('local %s = -%s', variable_name, args[1])
		else
			return string.format('%s = -%s', variable_name, args[1])
		end
	end,
	["chk"] = function(...)
		return "warn('CHK instruction is not supported yet in the compiler. Please use the interpreter.')"
	end,
	["jmp"] = function(...)
		return "warn('JMP instruction is not supported, and will not be supported due to incompatibility.')"
	end,
	["jmpif"] = function(...)
		return "warn('JMP instruction is not supported, and will not be supported due to incompatibility.')"
	end,
	["opr"] = function(...)
		local args = table.pack(...)
		if args[2] == "$add" then
			return string.format('%s = %s + %s', args[1], args[1], args[3])
		elseif args[2] == "$sub" then
			return string.format('%s = %s - %s', args[1], args[1], args[3])
		elseif args[2] == "$mul" then
			return string.format('%s = %s * %s', args[1], args[1], args[3])
		elseif args[2] == "$div" then
			return string.format('%s = %s / %s', args[1], args[1], args[3])
		else
			syntax_error = 'Invalid operation.'
			return ""
		end
 	end,
	["ret"] = function(...)
		return "return ".. table.concat(table.pack(...), ", ") .. "\nend"
	end,
	["end"] = function(...)
		return "return"
	end,
	["halt"] = function(Time)
		return "wait("..(tonumber(Time) / 1000)..")"
	end,
	["tick"] = function()
		return "task.wait()" -- adding the actual func would be really ugly so i'll go with this for now
	end,
} 

instructions["safecall"] = function(...)
	return string.format('pcall(function() %s end)', instructions["call"](...))
end

instructions["safecallset"] = function(...)
	local args = table.pack(...)
	local variable_name = args[1]
	table.remove(args, 1)
	local func_name = args[1]
	table.remove(args, 1)
	if not table.find(already_set_variables, variable_name) then
		table.insert(already_set_variables, variable_name)
		return string.format('local _, %s = pcall(function() return %s('..table.concat(args, ', ').. ' end)', variable_name, func_name)
	else
		return string.format('_, %s = pcall(function() return %s('..table.concat(args, ', ').. ' end)', variable_name, func_name)
	end
	return string.format('pcall(function() %s end)', instructions["callset"](...))
end

function compile(tpscript)
	local compiled = "--[[ Compiled with LuaASM / TPScript (FORK) ]]--"
	local uncompiled = tpscript:gsub("\n;", ";"):gsub("\n", ";"):split(";")
    for i = 1, #uncompiled do
        uncompiled[i] = uncompiled[i]:gsub('^%s*', ''); -- Remove any additional tabs or spaces
    end;
	for _, line in pairs(uncompiled) do
		if line:sub(1, 2) == ":-" then
			local args = line:sub(3, -1):split(' ')
			local name = args[1]
            table.remove(args, 1);
			compiled = compiled .. "\n" .. string.format('function %s('..table.concat(args, ', ')..')', name)
		else
			local split_line = line:split(' ')
			if #split_line > 1 then
				for instruction, compiler in pairs(instructions) do
					if instruction:lower() == split_line[1]:lower() then
						table.remove(split_line, 1)
						compiled = compiled .. "\n" .. compiler(table.unpack(split_line))
					end
				end
				if syntax_error then
					warn('Error while compiling:')
					warn(syntax_error)
					return ""
				end
			end
		end
		
	end
	return compiled
end
