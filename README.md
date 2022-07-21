# LuaASM

Fork of TPScript (primarily so I can bug TPose less to fix bugs, and just fix them myself)

Example that runs inside of Roblox Luau:
```
callset part Instance.new Part workspace
callset v3 Vector3.new 0 20 0

setindex part Anchored $true

add y 0
::loop
add y 0.1
callset t math.sin y
callset r math.cos y
set x v3.X
set z v3.Z
set u v3.Y
mul t 10
mul r 10
add u t
add x r
callset v Vector3.new x u z
setindex part Position v
call wait 0.1
jmp loop
```
Semicolons are also optional.
```
set a 10;
add a 5
log a;
```
```
15
```

More examples are available under the examples/ directory.

A wiki will / should be accessable soon.

## Notes

This was designed for Luau. There isn't planned support for any other environments.

Use TPScript directly if you want support for regular Lua 5.1! :)
