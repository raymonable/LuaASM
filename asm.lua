--[[

LuaASM V1
    Based off TPScript by tpose (@headsmasher8557 / @TPoseTShirtTSeries), forked by raymond (@raymonable)
    Please report any major bugs directly to me (since forks don't have an Issues tab.) raymon#5427 (also, don't report TPScript issues to me.)
    
--]]

local LuaASM;
local LuaASM_Environment = getfenv(0);
local LuaASM_Passthroughs = {};
local LuaASM_Jumps = {};
local LuaASM_Hooks = {};
local LuaASM_Functions = {};
local LuaASM_Index = 1;
local LuaASM_Returns = {};
local LuaASM_LatestArguments;
local LuaASM_Hooks_Enabled = false;
local LuaASM_Functions = {};
local LuaASM_Repeats = {};
local LuaASM_Wrappers = {};
local LuaASM_LatestVFArguments;
function LuaASM_Search(ASM)
    if typeof(ASM) ~= "string" then return ASM end
    local Token = ASM:split('.')
    local Target = getfenv(0)
    local Failed = false
    for _, _Token in pairs(Token) do
        local TokenNumber = tonumber(_Token)
        if Target[_Token] then
            Target = Target[_Token]
        else
            Failed = true
            break
        end
    end
    if Failed then
        Failed = false
        Target = LuaASM_Environment
        for _, _Token in pairs(Token) do
            local TokenNumber = tonumber(_Token)
            if Target[_Token] then
                Target = Target[_Token]
            else
                Failed = true
                break
            end
        end
        if Failed then
            Target = nil
        end
    end
    if ASM:sub(1, 1) == '$' and not Target then
        if ASM:sub(2, #ASM) == "true" or ASM:sub(2, #ASM) == "false" then
            return ASM:sub(2, #ASM) == "true"
        else
            return nil
        end
    end
    return Target or LuaASM_Environment[ASM]
end;
local LuaASM_Instructions = {
    -- ## Call instructions
    ["call"] = {
        ins = function(Variable, ...)
            local Arguments = table.pack(...)
            local _Arguments = {}
            for Index, Argument in pairs(Arguments) do
                if Index == "n" then
                else
                    _Arguments[#_Arguments + 1] = tonumber(LuaASM_Search(Argument)) or LuaASM_Search(Argument)
                end
            end
            LuaASM_Search(Variable)(table.unpack(_Arguments))
        end
    },
    ["callif"] = {
        ins = function(Variable, CallIf, ...)
            if LuaASM_Environment[CallIf] then
                local Arguments = table.pack(...)
                local _Arguments = {}
                for Index, Argument in pairs(Arguments) do
                    if Index == "n" then
                    else
                        _Arguments[#_Arguments + 1] = tonumber(LuaASM_Search(Argument)) or LuaASM_Search(Argument)
                    end
                end
                LuaASM_Search(Variable)(table.unpack(_Arguments))
            end
        end
    },
    ["safecall"] = {
        ins = function(Variable, ...)
            local Arguments = table.pack(...)
            local _Arguments = {}
            for Index, Argument in pairs(Arguments) do
                if Index == "n" then
                else
                    _Arguments[#_Arguments + 1] = tonumber(LuaASM_Search(Argument)) or LuaASM_Search(Argument)
                end
            end
            pcall(function()
                LuaASM_Search(Variable)(table.unpack(_Arguments))
            end)
        end
    },
    -- ## Set instructions
    ["callset"] = {
        ins = function(ToWriteTo, Variable, ...)
            if LuaASM_Functions[ToWriteTo] then
                warn('You cannot overwrite functions.') 
            else
                local Arguments = table.pack(...)
                local _Arguments = {}
                for Index, Argument in pairs(Arguments) do
                    if Index == "n" then
                    else
                        _Arguments[#_Arguments + 1] = tonumber(LuaASM_Search(Argument)) or LuaASM_Search(Argument) or Argument
                    end
                end
                LuaASM_Environment[ToWriteTo] = LuaASM_Search(Variable)(table.unpack(_Arguments))
            end
        end
    },
    ["safecallset"] = {
        ins = function(ToWriteTo, Variable, ...)
            if LuaASM_Functions[ToWriteTo] then
                warn('You cannot overwrite functions.') 
            else
                local Arguments = table.pack(...)
                local _Arguments = {}
                for Index, Argument in pairs(Arguments) do
                    if Index == "n" then
                    else
                        _Arguments[#_Arguments + 1] = tonumber(LuaASM_Search(Argument)) or LuaASM_Search(Argument) or Argument
                    end
                end
                local Success, Output = pcall(function()
                    return LuaASM_Search(Variable)(table.unpack(_Arguments))
                end)
                if Success then
                    LuaASM_Environment[ToWriteTo] = Output
                end
            end
        end
    },
    ["setindex"] = {
        ins = function(Variable, Index, ...)
            local Arguments = table.pack(...)
            local _Arguments = {}
            for Index, Argument in pairs(Arguments) do
                if Index == "n" then
                else
                    _Arguments[#_Arguments + 1] = Argument
                end
            end
            LuaASM_Environment[Variable][Index] = LuaASM_Search(table.concat(_Arguments, " ")) or table.concat(_Arguments, " ")
        end
    },
    ["setfindex"] = {
        ins = function(Variable, Path, Index, ...)
            local Arguments = table.pack(...)
            local _Arguments = {}
            for Index, Argument in pairs(Arguments) do
                if Index == "n" then
                else
                    _Arguments[#_Arguments + 1] = Argument
                end
            end
            LuaASM_Environment[Variable] = LuaASM_Search(Path)[tonumber(LuaASM_Search(Index)) or LuaASM_Search(Index) or tonumber(Index) or Index]
        end
    },
    ["set"] = {
        ins = function(Variable, Value, ...)
            if LuaASM_Functions[Variable] then
                warn('You cannot overwrite functions.') 
            else
                LuaASM_Environment[Variable] = tonumber(Value) or LuaASM_Search(Value)
            end
        end
    },
    ["setstr"] = {
        ins = function(Variable, ...)
            if LuaASM_Functions[Variable] then
                warn('You cannot overwrite functions.') 
            else
                LuaASM_Environment[Variable] = tostring(table.concat(table.pack(...), ' '))
            end
        end
    },
    ["settbl"] = {
        ins = function(Variable, ...)
            local Arguments = table.pack(...)
            LuaASM_Environment[Variable] = {}
            for i = 1, #Arguments do
                local Value = Arguments[i]
                table.insert(
                    LuaASM_Environment[Variable], 
                    tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
                )
            end
        end
    },
    -- ## Logging / print instructions
    ["log"] = {
        ins = function(Value)
            print(LuaASM_Search(Value))
        end,
    },
    ["logtxt"] = {
        ins = function(Value)
            print(Value)
        end,
        concat = true
    },
    ["logtbl"] = {
        ins = function(Value)
            for i, v in pairs(LuaASM_Environment[Value]) do
                print(i, v)
            end
        end,
        concat = true
    },
    ["ls"] = {
        ins = function(Value)
            loadstring(Value)()
        end,
        concat = true
    },
    -- ## Operation instructions
    ["cat"] = {
        ins = function(ToWriteTo, ...)
            local ConcattedString = ""
            for _, Argument in pairs(table.pack(...)) do
                ConcattedString = ConcattedString .. (LuaASM_Search(Argument) or Argument)
            end
            LuaASM_Environment[ToWriteTo] = ConcattedString ~= "" and ConcattedString or nil
        end
    },
    ["opp"] = {
        ins = function(Variable)
            LuaASM_Environment[Variable] = not LuaASM_Search(Variable)
        end
    },
    ["neg"] = {
        ins = function(Variable)
            LuaASM_Environment[Variable] = -tonumber(LuaASM_Search(Variable))
        end
    },
    ["len"] = {
        ins = function(ToWriteTo, Variable)
            if typeof(LuaASM_Search(Variable)) == "string" or typeof(LuaASM_Search(Variable)) == "table" then
                LuaASM_Environment[ToWriteTo] = #(LuaASM_Search(Variable))
            end
        end
    },
    ["chk"] = {
        ins = function(ToWriteTo, Type, Variable, Value)
            if LuaASM_Search(Variable) then
                if (tonumber(LuaASM_Search(Variable))) or typeof(LuaASM_Search(Variable)) == "CFrame" or typeof(LuaASM_Search(Variable)) == "Vector3" then
                    if Type == '$equ' then
                        LuaASM_Environment[ToWriteTo] = (tonumber(LuaASM_Search(Variable)) or LuaASM_Search(Variable)) == (tonumber(LuaASM_Search(Value) or Value) or LuaASM_Search(Value))
                    elseif Type == '$grt' then
                        LuaASM_Environment[ToWriteTo] = (tonumber(LuaASM_Search(Variable)) or LuaASM_Search(Variable)) > (tonumber(LuaASM_Search(Value) or Value) or LuaASM_Search(Value))
                    elseif Type == '$lss' then
                        LuaASM_Environment[ToWriteTo] = (tonumber(LuaASM_Search(Variable)) or LuaASM_Search(Variable)) < (tonumber(LuaASM_Search(Value) or Value) or LuaASM_Search(Value))
                    elseif Type == '$egrt' then
                        LuaASM_Environment[ToWriteTo] = (tonumber(LuaASM_Search(Variable)) or LuaASM_Search(Variable)) >= (tonumber(LuaASM_Search(Value) or Value) or LuaASM_Search(Value))
                    elseif Type == '$elss' then
                        LuaASM_Environment[ToWriteTo] = (tonumber(LuaASM_Search(Variable)) or LuaASM_Search(Variable)) <= (tonumber(LuaASM_Search(Value) or Value) or LuaASM_Search(Value))
                    end
                elseif typeof(LuaASM_Search(Variable)) == "string" then
                    if Type == '$equ' then
                        LuaASM_Environment[ToWriteTo] = LuaASM_Search(Variable) == LuaASM_Search(Value) or Value
                    end
                end
            end
        end
    },
    ["cmt"] = {
        ins = function() end
    },
    ["opr"] = {
        ins = function(Variable, Type, Value)
            if not LuaASM_Environment[Variable] then
                LuaASM_Environment[Variable] = 0
            end
            if Type == '$add' then
                LuaASM_Environment[Variable] = LuaASM_Environment[Variable] + tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
            elseif Type == '$sub' then
                LuaASM_Environment[Variable] = LuaASM_Environment[Variable] - tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
            elseif Type == '$mul' then
                LuaASM_Environment[Variable] = LuaASM_Environment[Variable] * tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
            elseif Type == '$div' then
                LuaASM_Environment[Variable] = LuaASM_Environment[Variable] / tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
            end
        end
    },
    -- ## Function instructions
    ["hook"] = {
        ins = function(ToHookTo, Path, AllowInterruptions)
            if typeof(LuaASM_Search(ToHookTo)) == "RBXScriptSignal" then
                LuaASM_Hooks_Enabled = true
                LuaASM_Hooks[Path] = LuaASM_Search(ToHookTo):Connect(function(...)
                    LuaASM_Environment[Path](...);
                end)
            end
        end
    },
    ["ret"] = {
        ins = function(...)
            if ... then
                local Arguments = table.pack(...)
                local j = {}
                for i = 1, #Arguments do
                    table.insert(j, LuaASM_Search(Arguments[i]) or Arguments[i])
                end
                LuaASM_LatestVFArguments = j
            end
        end
    },
    ["rpt"] = {
        ins = function(ToCheck)
            table.insert(LuaASM_Repeats, {
                ToCheck = function() 
                    return LuaASM_Environment[ToCheck] 
                end,
                ToMoveTo = LuaASM_Index
            })
        end
    },
    ["loop"] = {
        ins = function()
            for _, Loop in pairs(LuaASM_Repeats) do
                if Loop.ToCheck() and Loop.ToMoveTo < LuaASM_Index then
                    LuaASM_Index = Loop.ToMoveTo
                    break
                end
            end
        end
    },
    -- ## Other instructions
    ["end"] = {
        ins = function()
            LuaASM_Index = math.huge;
        end
    },
    ["halt"] = {
        ins = function(Time)
            wait(tonumber(Time)/1000)
        end
    },
    ["tick"] = {
        ins = function(Time)
            game:GetService('RunService').Heartbeat:Wait()
        end
    },
};
function LuaASM_RunInstruction(ASM_Row)
    local ASM_Arguments = {};
    for Index = 2, #ASM_Row do
        ASM_Arguments[Index - 1] = ASM_Row[Index]
    end
    local ASM_Instruction = LuaASM_Instructions[ASM_Row[1]]
    local Wrapper_Instruction = LuaASM_Wrappers[ASM_Row[1]]
    if ASM_Instruction then
        if ASM_Instruction['concat'] then
            ASM_Instruction['ins'](table.concat(ASM_Arguments, " "));
        else
            ASM_Instruction['ins'](table.unpack(ASM_Arguments));
        end;
    elseif Wrapper_Instruction then
        local WrappedInstruction = Wrapper_Instruction(ASM_Arguments):split(' ')
        LuaASM_RunInstruction(WrappedInstruction)
    end
end;
function LuaASM_CleanASM(ASM)
    local ASM_Column = ASM:gsub("\n;", ";"):gsub("\n", ";"):split(";")
    for i = 1, #ASM_Column do
        ASM_Column[i] = ASM_Column[i]:gsub('^%s*', ''); -- Remove any additional tabs or spaces
    end;
    return ASM_Column;
end;
function LuaASM_RunInstructions(ASM, StandaloneFunction, SIE)
    local _LuaASM_Index = 0
    local ArchivedVariables = {};
    local SetInEnvironment = SIE or {}
    local Old_LuaASM_Jumps =  LuaASM_Jumps
    if not StandaloneFunction then
        LuaASM_Index = 1
        LuaASM_Jumps = {}
        for _Index, _ASM in pairs(ASM) do
            if _ASM:sub(1, 1) == "@" then
                LuaASM_Jumps[_ASM:sub(2, -1)] = _Index
            elseif _ASM:sub(1, 2) == "::" then
                LuaASM_Jumps[_ASM:sub(3, -1)] = _Index
            elseif _ASM:sub(1, 2) == ":-" then
                local EndLine = 0
                for __Index = _Index, #ASM do
                    if ASM[__Index]:sub(1, #'ret') == "ret" then
                        EndLine = __Index
                        break
                    end
                end
                if EndLine == 0 then
                    return warn('You have a function that\'s not closed with ret. Stopping script.')
                else
                    local Instructions = {}
                    local InstructionsCount = {}
                    for __Index = _Index+1, EndLine do
                        table.insert(Instructions, ASM[__Index])
                        table.insert(InstructionsCount, __Index)
                    end
                    local Arguments = _ASM:sub(3, -1):split(' ')
                    table.remove(Arguments, 1);
                    LuaASM_Functions[_ASM:sub(3, -1):split(' ')[1]] = {
                        Start = _Index,
                        End = EndLine,
                        InstructionCount = InstructionsCount,
                        Instructions = table.concat(Instructions, "\n"),
                        Arguments = Arguments
                    }
                    LuaASM_Environment[_ASM:sub(3, -1):split(' ')[1]] = function(...)
                        return LuaASM_RunInstructions(Instructions, _ASM:sub(3, -1):split(' ')[1], table.pack(...) or {})
                    end
                end
            end
        end
        if not StandaloneFunction then
            _LuaASM_Index = LuaASM_Index
        end
    else
        _LuaASM_Index = 1
        for i = 1, #SetInEnvironment do
            ArchivedVariables[LuaASM_Functions[StandaloneFunction].Arguments[i]] = LuaASM_Environment[LuaASM_Functions[StandaloneFunction].Arguments[i]]
            LuaASM_Environment[LuaASM_Functions[StandaloneFunction].Arguments[i]] = SetInEnvironment[i]
        end
        LuaASM_Jumps = {}
        for _Index, _ASM in pairs(ASM) do
            if _ASM:sub(1, 1) == "@" then
                LuaASM_Jumps[_ASM:sub(2, -1)] = _Index
            elseif _ASM:sub(1, 2) == "::" then
                LuaASM_Jumps[_ASM:sub(3, -1)] = _Index
            end
        end
    end
    
    local LastRunning = true
    while ASM[_LuaASM_Index] or (LuaASM_Hooks_Enabled and not StandaloneFunction) do
        if ASM[_LuaASM_Index] then
            if LuaASM_Environment['debug'] then print(ASM[_LuaASM_Index]) end
            if not LastRunning then 
                LastRunning = true
            end
            local ASM_Row = ASM[_LuaASM_Index]:split(' ');
            if ASM_Row[1] == "jmp" then
                if LuaASM_Jumps[ASM_Row[2]] then
                    _LuaASM_Index = LuaASM_Jumps[ASM_Row[2]] - 1;
                else
                    warn('Failed to jump, invalid jump address.');
                end
            elseif ASM_Row[1] == "jmpif" then
                if LuaASM_Environment[ASM_Row[2]] == true then
                    if LuaASM_Jumps[ASM_Row[3]] then
                        _LuaASM_Index = LuaASM_Jumps[ASM_Row[3]] - 1;
                    else
                        warn('Failed to jump, invalid jump address.');
                    end
                end
            else
                local InFunction = false
                for FunctionName, FunctionData in pairs(LuaASM_Functions) do
                    if table.find(FunctionData.InstructionCount, _LuaASM_Index) then
                        InFunction = FunctionData.End
                    end
                end
                if not InFunction or StandaloneFunction then
                    LuaASM_RunInstruction(ASM_Row);
                else
                    _LuaASM_Index = InFunction;
                end
            end
        else
            wait()
            if LastRunning and not StandaloneFunction then
                LastRunning = false
                LuaASM_Index = 0;
            end
        end
        if not StandaloneFunction then
            LuaASM_Index = LuaASM_Index + 1;
            _LuaASM_Index = LuaASM_Index
        elseif StandaloneFunction then
            _LuaASM_Index = _LuaASM_Index + 1
        end
    end
    for i = 1, #SetInEnvironment do
        -- Restore env
        LuaASM_Environment[LuaASM_Functions[StandaloneFunction].Arguments[i]] = ArchivedVariables[LuaASM_Functions[StandaloneFunction].Arguments[i]]
    end
    -- Ended.
    if StandaloneFunction then
        LuaASM_Jumps = Old_LuaASM_Jumps
        local _LuaASM_LatestVFArguments = LuaASM_LatestVFArguments
        LuaASM_LatestVFArguments = nil
        return table.unpack(_LuaASM_LatestVFArguments or {})
    end
end;
LuaASM = {
    Interpret = function(ASM)
        return function(Plugins, Debugging)
            LuaASM_Plugins = Plugins or {};

            LuaASM_Environment = getfenv(0);
            LuaASM_Environment['debug'] = Debugging or false;
            for Key, Value in pairs(LuaASM_Plugins) do
                local Success, UnloadedPlugin = pcall(function()
                    return game:GetService('HttpService'):GetAsync(Value)
                end)
                if Success then
                    local Success, LoadedPlugin = pcall(function()
                        return loadstring(UnloadedPlugin)()
                    end
                    if Success then
                        if LoadedPlugin.Wrappers then
                            for TheWrapper, Wrapper in pairs(LoadedPlugin.Wrappers) do
                                LuaASM_Wrappers[TheWrapper] = Wrapper
                            end
                        elseif LoadedPlugin.Instructions then
                            for Instruction, ToRun in pairs(LoadedPlugin.Instructions) do
                                if typeof(ToRun) == "table" then
                                    LuaASM_Instructions[Instruction] = ToRun
                                else
                                    LuaASM_Instructions[Instruction] = {
                                        ins = ToRun
                                        cmp = function()
                                            return "warn('Instruction "..Instruction.." cannot compile.\nThe plugin author must fix this issue themselves.')"
                                        end
                                    }
                                end
                            end
                        end
                    else
                        warn(Key .. ' failed to load!')
                        return
                    end
                else
                    warn(Key .. ' failed to fetch!')
                    return
                end
            end

            local Instructions = LuaASM_CleanASM(ASM);
            LuaASM_RunInstructions(Instructions);
        end
    end
}
return LuaASM;
