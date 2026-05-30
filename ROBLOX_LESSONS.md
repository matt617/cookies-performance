# Lessons from Building Cookie's Performance

A drop-in addendum for future Roblox-game CLAUDE.md files. These are the potholes I actually hit, not generic advice.

---

## 1. WEPPY MCP sandbox quirks

When driving Roblox Studio through the WEPPY MCP, `execute_luau` runs in a sandboxed Lua context that rejects more than the docs admit. Symptoms: `loadstring() is not available` errors that aren't actually about loadstring.

Triggers I confirmed:

- **`Vector3 + Vector3` arithmetic** in execute_luau scripts. The `__add` metamethod path uses loadstring internally. Workaround: `Vector3.new(a.X + dx, a.Y + dy, a.Z + dz)`.
- **Long mixed scripts**. Combining many mutations + queries + conditionals in one call sporadically trips the sandbox. Split into one-operation-per-call.
- **Lowercase `workspace` global** sometimes resolves as userdata. Use `game:GetService("Workspace")` everywhere.
- **`while true do` / `repeat ... until false`** in the *source code* you write into a Script's Source — the sandbox scans the string for the pattern. Use recursive `task.delay`:

  ```lua
  local function tick()
      task.delay(60, function()
          doWork()
          tick()
      end)
  end
  tick()
  ```

- **Cloning a complex Humanoid Model with WeldConstraints and setting Parent** can trigger the same error. Clone the BASE rig and strip variants inline; don't maintain separate parallel template models.
- **Dot-access on certain Folder.ModelName patterns** intermittently fails. Use `:FindFirstChild` or `:WaitForChild` when scripts get flaky.
- **execute_luau timeout (30s)** during playtest = Studio main thread busy. Wait it out; `system_info ping` confirms the MCP is alive.

Basic vs Pro tier matters a lot. `mass_create`, `create_tree`, `workspace_state.snapshot`, `execute_luau`, `run_test`, and `place_info` are Pro-only. Basic forces one-part-at-a-time MCP calls — fine for setup, painful for 100+ part venues.

---

## 2. StreamingEnabled is the #1 mystery bug for NPC characters

**New Roblox places default to `Workspace.StreamingEnabled = true`.** With streaming on, Models with a `Humanoid` (i.e., NPC characters) **don't reliably stream to clients**. Symptom: NPCs visible in edit mode, invisible the moment you F5.

Two fixes:

- **Small venue (< 5000 parts):** `workspace.StreamingEnabled = false`. Done.
- **Large world:** Set `ModelStreamingMode = Enum.ModelStreamingMode.Persistent` on each NPC model.

Verify in Output during playtest — your server's startup print should show the right NPC count. If it shows zero, streaming or path resolution is the culprit.

---

## 3. R15 rigging — biggest pothole

If you hand-roll an R15 rig from primitives, **Roblox catalog dance animations will scatter the limbs** because their rotation axes assume the standard R15 Motor6D C0/C1 orientations.

Three viable paths:

### A. Use `CreateHumanoidModelFromDescription` and re-skin
```lua
local rig = Players:CreateHumanoidModelFromDescription(
    HumanoidDescription.new(),
    Enum.HumanoidRigType.R15
)
-- Hide MeshPart visuals, overlay primitive Parts welded to them.
```
Best for "characters that need real animations." May not work in the MCP sandbox (it didn't in mine).

### B. Hand-rolled rig + programmatic animation
Don't use catalog animations at all. Animate `HumanoidRootPart.CFrame` via TweenService; limbs follow through Motor6D constraints. Works great for canned dance moves (bounce / spin / tilt). Doesn't get per-limb articulation.

### C. Static rigs (no animation)
For decorative NPCs only. Anchor everything, accept they won't dance.

### Anchor + Humanoid rules (works for paths B and C)

Once you have NPCs in Workspace, they need a specific Anchored/Massless combo or they collapse / scatter / vanish on F5:

```lua
for _, p in ipairs(rig:GetDescendants()) do
    if p:IsA("BasePart") then
        if p.Name == "HumanoidRootPart" then
            p.Anchored = true   -- holds the rig in place
        else
            p.Anchored = false  -- needed so Motor6D Transform can move limbs
            p.Massless = true   -- so gravity doesn't drag them down
        end
    end
end

local h = rig:FindFirstChildOfClass("Humanoid")
h.PlatformStand = true            -- don't auto-stand / walk
h.MaxHealth = 1e9
h.Health = 1e9
h.BreakJointsOnDeath = false      -- don't disassemble on edge cases
h.RequiresNeck = false            -- don't despawn if Neck breaks
h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None  -- hide floating name
```

Without `PlatformStand=true` + `BreakJointsOnDeath=false`, Roblox's character runtime can kill the rig at playtest start. Symptom: NPCs gone in F5, present in edit mode.

### Template gotcha
**Anchor parts on the *template* in ReplicatedStorage before cloning.** Otherwise, when `clone.Parent = workspace` runs, physics start ticking and parts drift away from your intended positions before your post-clone code finishes positioning them. Then your "shift by delta" math reads the drifted positions and compounds the error.

---

## 4. PivotTo lies about position for cloned characters

`Model:PivotTo(CFrame.new(target))` moves the model's **WorldPivot** to the target, not its PrimaryPart. For cloned character models, WorldPivot is often offset from the PrimaryPart (Roblox sets WorldPivot from the model's bounding-box center or similar — see [devforum thread](https://devforum.roblox.com/t/pivotto-weirdly-offsets-all-of-the-baseparts-in-the-model/2226575)).

Reliable replacement: direct part shift by delta from current HRP position.

```lua
local hrp = clone.HumanoidRootPart
local dx = targetX - hrp.Position.X
local dy = targetY - hrp.Position.Y
local dz = targetZ - hrp.Position.Z
for _, p in ipairs(clone:GetDescendants()) do
    if p:IsA("BasePart") then
        local pos = p.Position
        p.Position = Vector3.new(pos.X + dx, pos.Y + dy, pos.Z + dz)
    end
end
```

This bypasses WorldPivot entirely. Combine with the anchored-template rule above and positions are predictable.

---

## 5. Nano Banana image pipeline for Roblox assets

If you're using the `nanobanana` skill (Gemini 3 Pro Image) for art:

- **Default output:** ~1376×768 JPEG, even when the prompt asks for 2K. Plan to resample.
- **File extension lies:** the skill saves with `.png` but the content is JPEG. Roblox doesn't care, but re-save through Pillow if you need a real PNG.
- **Text rendering is genuinely good** — bake the title text into the thumbnail prompt rather than overlaying it later. Use single quotes inside the prompt: `Render the text 'COOKIE'S PERFORMANCE' in large bold pink frosting letters with a gold drop shadow`.
- **Resample after generation** with PIL LANCZOS for clean scaling:
  ```python
  from PIL import Image
  Image.open("in.png").convert("RGB").resize((1920, 1080), Image.LANCZOS).save("out.png", "PNG")
  ```
- **Run generations in parallel** via background bash to save wall time.
- **One canonical generation that's good enough beats five attempts.** Each costs API tokens.

### Roblox asset specs (current as of 2026-05)

| Asset | Size | Format | Safe zone |
|-------|------|--------|-----------|
| Experience Icon | **512×512** (1:1) | PNG | Inner 420×420 — corners get rounded |
| Experience Thumbnail | **1920×1080** (16:9) | PNG or JPG | Bottom 15% covered by player-count overlay |

The first thumbnail in your asset list shows in Home Recommendations. Quality matters: Roblox data showed +7.2% unique plays from upgrading thumbnails. Sources: [Roblox 16:9 announcement](https://devforum.roblox.com/t/169-experience-thumbnails-are-coming-to-home-in-april-%E2%80%93-update-yours-now/2875237), [icon and thumbnail sizes thread](https://devforum.roblox.com/t/roblox-game-icon-and-thumbnail-sizes/2180402).

---

## 6. Visual layout gotchas

Things I had to fix mid-build:

- **Wood-on-wood blends.** If your stage is wood and your floor is wood, the stage doesn't read as "raised." Either change the floor material/color, or add a contrasting stage skirt (fabric in a different color around the front/sides).
- **Backdrop bottom should match stage top.** If the stage is raised by H studs, the backdrop bottom Y should be H, not 0. Otherwise the wall plants itself in the floor next to the stage.
- **Overhead truss needs vertical clearance.** Put the lighting truss several studs above the backdrop top, or it visually merges with the upper backdrop and stops reading as overhead lighting.
- **Cupcake-style stacked geometry:** if you put a wider sphere directly over a narrower cylinder, the sphere occludes the cylinder. Make the dome a squashed ellipsoid (`Size = (5.5, 3, 5.5)`) positioned ABOVE the cylinder (`Position.Y = cylinderTop + halfDomeHeight`) so the full cylinder shows.
- **Front row of audience looks "low"** if all other rows are on risers and the front isn't. Give the front row its own short riser (1-2 stud) for visual consistency.
- **SurfaceGui.Face is counterintuitive.** Front = -Z, Back = +Z, Top = +Y. For a stage backdrop at Z=-147 with audience at Z > -147, set `Face = Enum.NormalId.Back` so the audience sees the GUI.

---

## 7. Architecture patterns that worked

### Folder layout (what I'd repeat)

```
ReplicatedStorage/
  Config/           -- single ModuleScript exporting a Config table
  Shared/           -- ModuleScripts used by both server and client
  Songs/<id>/notes  -- per-song note charts as ModuleScripts
  Animations/       -- Animation instances by id (Anim Editor or catalog refs)
  RemoteEvents/     -- one RemoteEvent per server-action verb

ServerScriptService/
  GameLoop/         -- ChoreoServer, StationServer, GameLoopServer
  Persistence/      -- ProfileStore (ModuleScript) + PersistenceServer (Script)
  Queue/            -- QueueServer
  WorldBuilder/     -- (deferred to a future session, or fill on rebuild)

StarterPlayer/StarterPlayerScripts/
  UI/               -- LocalScripts that own ScreenGuis (ShowOverlay, StationClient, QueueClient)
  Mechanics/        -- LocalScripts that own input + zone-based mechanics (ChoreoClient, VocalClient)
```

### DataStore wrapper (works in production)

```lua
function ProfileStore.save(userId)
    local attempts = 0
    while attempts < 3 do
        attempts += 1
        local ok, err = pcall(function() store:SetAsync(tostring(userId), profiles[userId]) end)
        if ok then return true end
        warn("[ProfileStore] save attempt", attempts, "failed:", err)
        task.wait(2 ^ attempts)
    end
    warn("[ProfileStore] save FAILED after 3 attempts for", userId)
    return false
end
```

Three attempts with exponential backoff (2/4/8 sec). Always `pcall`. Fail soft — log warning, don't crash. Studio without "Enable Studio Access to API Services" silently fails the GetDataStore call; the wrapper degrades to in-memory only.

### Zone detection (works)

```lua
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p = hrp.Position
    local inZone = (p.X >= 38 and p.X <= 62 and p.Z >= -12 and p.Z <= 12 and p.Y < 30)
    -- toggle GUI visibility
end)
```

Simpler than `.Touched` events. No false positives from random parts. Cheap (one bounding-box check per frame).

### RemoteEvent discipline

- One RemoteEvent per server-action verb: `TriggerDance`, `StartRecording`, `JoinQueue`, `SetCue`, etc.
- Client fires the event with a small typed payload. Server validates type and value bounds (`if type(moveId) ~= "string" then return end`).
- Server broadcasts state changes via `*Updated` events (`QueueUpdated`, `CueSheetUpdated`).
- Don't put gameplay logic on the client — server is the source of truth for queue, applause, persistence.

### ProximityPrompt > ClickDetector

ProximityPrompts work on mobile, PC, and controller out of the box. ClickDetectors are mouse-only on PC. Set `HoldDuration = 0` for tap-to-trigger. Provide both ActionText (verb) and ObjectText (noun).

### Cross-script server coordination

Server Scripts can't directly call each other. Three patterns that work:

1. **Shared ModuleScript** — both scripts `require()` it. Best for shared state (e.g., ProfileStore).
2. **BindableEvent as a child of one Script** — the other script does `:FindFirstChild(...)` and `:Fire()`. I used this for "show finished" → queue advance.
3. **RemoteEvent** — works for server-internal too if you don't mind the indirection. Both scripts `:Connect` to `.OnServerEvent`.

---

## 8. UI patterns that worked

- **Radial wheel of 6 action buttons + center trigger button.** Used for the dance wheel. Each peripheral button is an action; center is the meta button (record/stop). Buttons arranged via `math.cos / math.sin * radius`.
- **32-beat horizontal timeline with palette buttons above.** Tap palette to arm a cue type, tap timeline slot to place it, tap occupied slot to clear. Works on touch and mouse.
- **Top-left for HUD panels, top-center for meters, bottom-center for action wheels, mid-screen for modal overlays.** Don't fight the convention.
- **FredokaOne font** reads as warm and kid-friendly across all sizes. Use it everywhere user-facing.
- **No-fail messaging:** "GREAT!" and "Good!" on hits; silent on misses. Never "MISS!" or numeric scores.
- **Tween everything.** No instant state changes. EasingStyle.Sine InOut at 0.2-0.4 sec covers most UI transitions.

---

## 9. What to defer (don't try to do in one session)

These showed up in spec but turned out to be 1-2 hours each on their own. Plan to ship without them and add later:

- **Player character SWAP** to a custom rig when they become "the protagonist." Toast notification is fine for v1.
- **Per-limb dance animations** on custom rigs. Programmatic CFrame motion is good enough for v1.
- **4-minute prep phase** for round structure. Irrelevant for solo testing; wire up once you have multiplayer playtests.
- **Wardrobe unlock triggers** wired to first-try-of-each-station + applause-tier milestones. Storage exists; triggers are bookkeeping.
- **Audience emoji throws** during shows. Cute but big lift.
- **Lighting auto-grading** based on time of day / song mood. Save for v1.1.

---

## 10. Process notes for working with Claude on Roblox

- **Build infrastructure → playtest checkpoint → build mechanics → playtest checkpoint.** Don't ship three systems then F5. You'll have three bugs at once and won't know which to chase first.
- **Server-side errors are silent in execute_luau.** They only appear in Studio's Output panel during playtest. Always look there when a feature "doesn't do anything."
- **MCP responds + execute_luau times out = Studio is in playtest.** Wait it out. `system_info ping` confirms MCP is alive.
- **When a script "doesn't work," check first:**
  1. Is the parent folder right? (e.g., LocalScript in `StarterPlayerScripts.UI` vs `StarterPlayerScripts.Mechanics`)
  2. Does it have a `print()` at the bottom that fires? If not, it errored on load.
  3. Are there `require()`s pointing at ModuleScripts that have syntax issues?
  4. Is the RemoteEvent actually firing? (Add a server-side print at the top of `OnServerEvent`.)
- **"Get ready to execute X"** from the user usually means "plan + start the first concrete step," not "just plan." Ship the first action; ask before the second.
- **Each turn that creates UI, tell the user where to look** — viewport coordinates, which key/button activates it, what they should see. Otherwise they F5 into a black screen and think it's broken.
- **Skill output beats raw model output for templated tasks.** The `nanobanana` skill bakes in the right prompt patterns; you get better images than hand-rolling the API call.
- **Save IDs and constants to memory.** The user shouldn't have to re-paste their daughter's UserId, their game's place ID, asset IDs, etc. across sessions.

---

## 11. Spec-writing advice for the NEXT game's CLAUDE.md

Things I wish the spec had baked in from day one:

- **Anchor template parts before cloning.** Specify it explicitly.
- **StreamingEnabled = false** if the venue fits.
- **Use programmatic CFrame motion for any custom character animations** unless you're rigging a proper R15.
- **Always start with: spawn one test part via MCP, confirm visible in Studio, delete.** The Cookie spec did this and it saved time.
- **Lock the visual style early** with one good reference image, then build to match. Don't iterate composition with the user mid-build.
- **State coordinate origins explicitly.** "Floor center at (0, -2, -30). Stage center at (0, 3, -130). All audience faces +Z." Without this, every position decision becomes a negotiation.
- **List the tier thresholds, BPM, and exact note count up front.** Letting the AI guess produces sluggish chart pacing.
- **Defer everything controller-related to v1.1** unless you're shipping on PlayStation day one.
