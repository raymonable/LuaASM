local LuaASM;
local LuaASM_Environment = getfenv(0);
local LuaASM_Passthroughs = {};
local LuaASM_Jumps = {};
local LuaASM_Hooks = {};
local LuaASM_Functions = {};
local LuaASM_Index = 1;
local LuaASM_Returns = {};
local LuaASM_LatestArguments;
local LuaASM_Hooks_Enabled = false; -- Luau was being funky, so I had to add this in.
local LuaASM_Functions = {};
local LuaASM_LatestVFArguments;
function LuaASM_Search(ASM)
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
    ["callset"] = {
        ins = function(ToWriteTo, Variable, ...)
            if LuaASM_Functions[Variable] then
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
            if LuaASM_Functions[Variable] then
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
                        LuaASM_Environment[ToWriteTo] = LuaASM_Search(Variable) == Value
                    end
                end
            end
        end
    },
    ["cmt"] = {
        ins = function() end
    },
    -- The following four instructions are considered deprecated. It's recommended you use `opr` in place of them. ex: `opr a $add 10;`
    ["add"] = {
        ins = function(Variable, Value)
            if not LuaASM_Environment[Variable] then
                LuaASM_Environment[Variable] = 0
            end
            LuaASM_Environment[Variable] = LuaASM_Environment[Variable] + tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
        end
    },
    ["sub"] = {
        ins = function(Variable, Value)
            if not LuaASM_Environment[Variable] then
                LuaASM_Environment[Variable] = 0
            end
            LuaASM_Environment[Variable] = LuaASM_Environment[Variable] - tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
        end
    },
    ["mul"] = {
        ins = function(Variable, Value)
            if not LuaASM_Environment[Variable] then
                LuaASM_Environment[Variable] = 0
            end
            LuaASM_Environment[Variable] = LuaASM_Environment[Variable] * tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
        end
    },
    ["div"] = {
        ins = function(Variable, Value)
            if not LuaASM_Environment[Variable] then
                LuaASM_Environment[Variable] = 0
            end
            LuaASM_Environment[Variable] = LuaASM_Environment[Variable] / tonumber(LuaASM_Environment[Value] or Value) or LuaASM_Environment[Value] or Value
        end
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
    ["hook"] = { -- This, currently, is a fairly hacky method of doing this. If there's a better solution that's been implemented, please inform me.
        ins = function(ToHookTo, Path, AllowInterruptions)
            if typeof(LuaASM_Search(ToHookTo)) == "RBXScriptSignal" then
                LuaASM_Hooks_Enabled = true
                LuaASM_Hooks[Path] = LuaASM_Search(ToHookTo):Connect(function(...)
                    if LuaASM_Search(AllowInterruptions or '$false') == true or LuaASM_Index == 0 then
                        LuaASM_LatestArguments = table.pack(...);
                        LuaASM_Environment[Path](LuaASM_LatestArguments);
                    end
                end)
            end
        end
    },
    ["setfhook"] = {
        ins = function(...)
            if LuaASM_LatestArguments then
                local Arguments = table.pack(...)
                for i = 1, #Arguments do
                    LuaASM_Environment[Arguments[i]] = LuaASM_LatestArguments[i] 
                end
                LuaASM_LatestArguments = nil;
            end
        end
    },
    ["setfvfunc"] = {
        ins = function(...)
            if LuaASM_LatestVFArguments then
                local Arguments = table.pack(...)
                for i = 1, #Arguments do
                    LuaASM_Environment[Arguments[i]] = LuaASM_Search(LuaASM_LatestVFArguments[i]) or LuaASM_LatestVFArguments[i]
                end
                LuaASM_LatestVFArguments = nil;
            end
        end 
    },
    ["ret"] = {
        ins = function(...)
            if ... then
                LuaASM_LatestVFArguments = table.pack(...)
            end
        end
    },
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
    if ASM_Instruction then
        if ASM_Instruction['concat'] then
            ASM_Instruction['ins'](table.concat(ASM_Arguments, " "));
        else
            ASM_Instruction['ins'](table.unpack(ASM_Arguments));
        end;
    end
end;
function LuaASM_CleanASM(ASM)
    local ASM_Column = ASM:gsub("\n;", ";"):gsub("\n", ";"):split(";")
    for i = 1, #ASM_Column do
        ASM_Column[i] = ASM_Column[i]:gsub('^%s*', ''); -- Remove any additional tabs or spaces
    end;
    return ASM_Column;
end;
function LuaASM_RunInstructions(ASM, StandaloneFunction)
    local _LuaASM_Index = 0
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
                    for __Index = _Index+1, EndLine+1 do
                        table.insert(Instructions, ASM[__Index])
                        table.insert(InstructionsCount, __Index)
                    end
                    LuaASM_Functions[_ASM:sub(3, -1)] = {
                        Start = _Index,
                        End = EndLine,
                        InstructionCount = InstructionsCount,
                        Instructions = table.concat(Instructions, "\n")
                    }
                    LuaASM_Environment[_ASM:sub(3, -1)] = function(ShouldHalt)
                        if ShouldHalt then
                            LuaASM_RunInstructions(Instructions, true)
                        end
                    end
                end
            end
        end
        if not StandaloneFunction then
            _LuaASM_Index = LuaASM_Index
        end
    else
        _LuaASM_Index = 1
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
                    if _LuaASM_Index[ASM_Row[3]] then
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
    -- Ended.
end;
LuaASM = {
    Interpret = function(ASM)
        return function(Passthroughs,  Debugging)
            LuaASM_Passthroughs = Passthroughs or {};

            LuaASM_Environment = getfenv(0);
            LuaASM_Environment['debug'] = Debugging or false;
            for Key, Value in pairs(LuaASM_Passthroughs) do
                LuaASM_Environment[Key] = Value;
            end

            local Instructions = LuaASM_CleanASM(ASM);
            LuaASM_RunInstructions(Instructions);
        end
    end
}
return LuaASM;
