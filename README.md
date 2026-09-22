# Y Access UI

Compact Roblox access and startup interfaces for Y Hub. Shared mouse/touch controls, safe-area layout, keyboard-aware scrolling, and short transitions.

This library contains presentation only. It does not validate keys, make HTTP requests, store credentials, or start a game script. Callbacks belong to the consuming application.

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/GodErste/Y-Access-UI/main/Library.lua"))()
local Screen = UI.CreateAccess({ Discord = "https://discord.gg/53J4h36DtX" })
Screen:Bind(function(Key, Remember)
    -- Validate in your own controller.
end, function()
    Screen:Destroy()
end)
Screen:SetRememberAvailable(false)
```

`CreateProgress()` returns a view with `SetStage(index, message)`, `SetResult(success, message)`, `Dismiss()` and `Destroy()`. `CreateAccess()` returns the access view with `Bind`, `SetBusy`, `SetStatus`, `ClearKey`, `SetRememberAvailable` and `Destroy`.

Edit `src/`, then run `node tools/build.mjs`. Consumers can pin and embed `Library.lua` during their own build; a runtime download is optional.
