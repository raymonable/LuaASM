# LuaASM

LuaASM is a fork of TPScript, which is an experimental scripting language developed for Roblox (not made for production use, of course).</br>
Our fork has more instructions than TPScript which can cause compatibility issues so please keep this in mind.

> :warning: This fork is no longer updated. Everything here is as-is.

## Documentation

Instructions marked with a:
 - green dot, are safe to use in tpscript & LuaASM (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
 - yellow dot, are only usable in LuaASM (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))

### Instructions List
`call (function) (arguments)`
Calls a Lua / Luau function. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`callif (function) (boolean variable) (arguments)`
Calls a Lua / Luau function if the boolean variable is true. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`callset (towrite) (function) (arguments)`
Calls a Lua / Luau function, and sets `(towrite)` to the return value. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`safecall (function) (arguments)`
Calls a Lua / Luau function, but wrapped in a pcall. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`safecallset (towrite) (function) (arguments)`
Calls a Lua / Luau function, and sets `(towrite)` to the return value, but wrapped in a pcall. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`setindex (object) (index) (value)`
Sets an index of an object. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`setfindex (object) (towrite) (index)`
Sets a variable to an index of an object. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`set (variable) (value)`
Sets a variable with a value. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`setstr (variable) (string)`
Sets a variable with a string. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`settbl (variable) (arguments)`
Sets a variable with a table filled with arguments. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`log (variable)`
Logs a variable to the console. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`logtxt (text)`
Logs text to the console. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`logtbl (table)`
Logs the contents of a table to the console. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`ls (string)`
Loadstring a script. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`rpt (boolean variable)`
Starts a repeat loop, that will only loop if the boolean is true. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`loop`
Ends a loop if a `rpt` has been instructed already. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`cat (to write) (to concat)`
Concats the argumented strings together and sets the variable. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`opp (variable)`
Sets a boolean variable to the opposite of itself. *TPScript uses `not`, so it's considered incompatible.* (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`neg (variable)`
Sets a number variable to the negative of itself. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`len (towrite) (variable)`
Gets the length of a table or string. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`chk (towrite) (type) (variable_a) (variable_b)`
*Check*s / compares two variables. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))

```
Valid types and what they do:
'$equ' => (variable_a == variable_b)
'$grt' => (variable_a > variable_b)
'$lss' => (variable_a < variable_b)
'$elss' => (variable_a >= variable_b)
'$egrt' => (variable_a <= variable_b)
```
***
`cmt`
Doesn't do anything, used for comments. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/GreenDotDownscaled.png?raw=true))
***
`opr (variable) (type) (tooperate)`
Operates on a variable. *TPScript may support this eventually.* (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))

```
Valid types and what they do:
'$add' => (variable + tooperate)
'$sub' => (variable - tooperate)
'$mul' => (variable * tooperate)
'$div' => (variable / tooperate)
```
***
`hook (tohook) (path) (allowinteruptions / boolean)`
Hooks to an RBXScriptSignal to jump to a `jmp` label. (May be broken right now) (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`end`
Stops the script. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`ret (optional return values)`
Ends a `VF` with or without additional return values *likely functions differently in TPScript* (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`halt (number)`
Waits for `(number)` milliseconds. *`wait (number)` is the supplement for TPScript.* (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))
***
`tick`
Waits for the next Heartbeat. (![](https://github.com/raymonable/LuaASM/blob/main/wiki_assets/YellowDotDownscaled.png?raw=true))

### Deprecated Instructions

`jmp (label)`
Jumps to the specified `jmp` label.
***
`jmpif (variable) (label)`
Jumps to the specified `jmp` label if `(variable)` is true.

### Discontinued Instructions

Replace with `opr`:

`add (variable) (number)`
Adds `(variable)` and `(number)` together. Replaced by `opr $add`.
***
`sub (variable) (number)`
Subtracts `(variable)` and `(number)`. Replaced by `opr $sub`.
***
`mul (variable) (number)`
Multiplies `(variable)` and `(number)` together. Replaced by `opr $mul`.
***
`div (variable) (number)`
Divides `(variable)` and `(number)` together. Replaced by `opr $div`.

*The above instructions only work if you enable the Full Compatibility plugin.*

### Jump Labels

**Please use VFs for new work. Jump Labels have been deprecated to allow for compilers to be sensibly completed.**

Jump labels are used for `jmp` and `jmpif`.

They are defined by `::name` or `@name` (exclusively for LuaASM), and allow you to move to different points in your script.

### Virtual Functions
Virtual functions are essentially just the interpreter wrapped in a lua function.
They support jump labels, arguments and return values.

They are defined by `:-` (exclusively for LuaASM), and are only callable from `call`, `safecall`, `callset`, and `safecallset`.
Also, they will be ignored by the interpreter; meaning they can be placed just about anywhere without issues.

*Calling a virtual function inside a virtual function seems to work fine. If there's any issues, please shoot me a dm (tag is in `asm.lua`)*

Example:
```
:-test a; cmt a is an argument;
log a;
ret a; cmt just returns the "a" argument because i'm lazy;
callset b test 10; cmt calls the test virtual function and sets the "b" variable to the return value;
log b;
```

### Additional Information (about LuaASM / TPScript)
TPScript will only run your script until it reaches the last instruction.

LuaASM doesn't stop, and instead just loops over a `wait` (only if there's at least one hook active.)
15

## Notes

This was designed for Luau. There isn't planned support for any other environments.

Use TPScript directly if you want support for regular Lua 5.1! :)

More examples are available under the examples/ directory.
