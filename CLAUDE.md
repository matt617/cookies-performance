# Cookie's Performance

A Roblox experience for Matt's daughter (nicknamed Cookie, age 6-10) and her friends.
The player is a pop-star cookie performing at a giant bakery concert hall. She trains
vocals with a rhythm mini-game, choreographs backup dancers, and performs a show.
Friends join to run lights, fire confetti, and watch. Every show ends in confetti.
There is no losing.

Mobile-first (iPad, phone), PlayStation compatible, PC compatible. Friends-only
multiplayer, strangers never join.

## Design constraints (DO NOT CHANGE WITHOUT ASKING)

These are locked decisions. Confirm with Matt before deviating.

### Tone and audience
- The whole experience exists to make a 7-year-old feel like a star for 90 seconds.
- No losing. No leaderboards. No ranking one player against another. No failure language.
- The applause meter starts at 50% and only goes up. Every show is a good show.
- The one allowed on-screen number is Sprinkles, a happy collectible currency earned by
  playing (see DESIGN.md). It is personal and only goes up, never a grade or a comparison.
- Code can be messy and assets can be primitive. The feeling cannot be wrong: lights
  drop, song starts, dancers fall in behind her, confetti at the end, dad watching.

### Scope (do not expand without asking)
- No monetization, ever. No Robux purchases, no game passes, no premium currency.
- No leaderboards, no ranking players against each other. The applause meter only goes up.
- A Sprinkles economy is in scope (earn by playing, spend later, see DESIGN.md). Soft
  currency only: never purchasable with Robux or real money.
- No voice chat. Roblox voice chat is age-gated and not relevant here.
- No tutorial NPC. Matt cut this on purpose. Floor signs and single-line hints only.
- Production crew ships 2 stations in v1: Lights and Stage FX. Sound mixing and Dance
  Captain are deferred to v2. If you finish v1 early, write a v2 backlog, do not build it.
- Nothing gameplay-relevant is gated. All moves, songs, and stations are unlocked day one.
  Persistence is for saved work and cosmetics only. Friends are never behind on capability.

### Visual style
- Toy-like and chunky, built mostly from Roblox primitives (parts, cylinders, wedges,
  spheres) with creative coloring. Every prop is a bakery item at concert-hall scale.
- Do not drift toward realistic. The primitive look is the brief.

## Code lives on disk (source of truth)

This project is a Rojo + git repo. The `src/` tree is the source of truth, not the
live Studio session. This is the whole point of the setup: code you can read, grep,
diff, and roll back is what makes the build consistent across sessions.

- Write code to files under `src/` and let Rojo sync it into Studio. Never hand Matt
  a paste-in script, and do not treat Studio as the place where code lives.
- `manage_scripts` may edit Studio directly for a quick experiment, but anything worth
  keeping gets written to `src/` and committed.
- Commit to git often, in small steps. Studio is fragile. A clean commit per working
  step is the undo button this project otherwise does not have.
- The `weppy-project-sync/` folder is a generated mirror of Studio. It is gitignored.
  Do not edit it by hand and do not treat it as source.

### Rojo layout
- `src/server` -> `ServerScriptService` (round loop, persistence, queue, world builder)
- `src/shared` -> `ReplicatedStorage.Shared` (Config, Remotes, Types, Songs, Animations,
  and modules used by both sides)
- `src/client` -> `StarterPlayer.StarterPlayerScripts` (all UI and input)

## Code conventions

- Luau with `--!strict` at the top of modules where practical. Type the function
  signatures.
- Server scripts: `*.server.lua`. Client scripts: `*.client.lua`. Modules: `*.lua`.
- One responsibility per script. Avoid the one-giant-ServerScript antipattern.
- All tunable values live in `src/shared/Config.lua`, never hardcoded in logic.
- All RemoteEvents and RemoteFunctions are declared once in `src/shared/Remotes.lua`.
- Shared type definitions live in `src/shared/Types.lua`.
- `require()` with `ReplicatedStorage.Shared.*` paths, not relative paths.
- Server owns all state. Clients own UI and input only. Never trust a client payload;
  validate every remote on the server. A friend-of-a-friend on someone's account counts
  as an untrusted client even though a 7-year-old will not exploit anything.
- Modern APIs: `LinearVelocity` not `BodyVelocity`, `AlignPosition` not `BodyPosition`,
  `WaitForChild` with a timeout not bare `WaitForChild`. `TweenService` for UI
  transitions, no jarring snaps.

## Build workflow with weppy MCP

Studio connects through the weppy-roblox-mcp server. Use it. Note that two weppy
servers may appear in the tool list; confirm the one pointed at the Cookie's
Performance place before mutating, so you never build into the wrong project.

### For code changes
- Write to `src/` so the change is in git, then let Rojo sync it.
- For a throwaway experiment, `manage_scripts` is fine, but promote anything real to disk.

### For venue, props, and visual changes
- Use `mutate_instances`, `manage_properties`, `manage_lighting`, `manage_effects`.
- Build chunky primitive blockouts first, color and detail pass after it plays.
- The venue is geometry the WorldBuilder script rebuilds at runtime. Keep the recipe
  in `src/server` so the venue is reproducible, not a hand-placed one-off.

### Verification is mandatory (before declaring any task done)
1. Verify the change with `query_instances` or `workspace_state`.
2. For visual changes, take a screenshot with `manage_camera` and `manage_studio`.
3. Check `manage_logs` for errors.
4. For new systems, spawn a test rig and run `execute_luau` to simulate the interaction
   (a dance playback, a cue firing, a save round-trip).

### Cleanup
- Remove test rigs, temp parts, and debug prints when a task is done.
- Do not leave clutter in the workspace between sessions.

### Read the lessons file first
`ROBLOX_LESSONS.md` holds the potholes already hit on this project: WEPPY sandbox
quirks (Vector3 arithmetic, long mixed scripts, `while true` in script source) and the
StreamingEnabled NPC-invisibility bug. Read it before driving the MCP. The Rojo project
already sets `Workspace.StreamingEnabled = false` to keep NPC dancers visible.

## Build order (v1)

Ship each step playable, then commit, before moving to the next. Verify in Studio as
you go; pull Matt in for a real playtest at the end of a step that changes how the game
feels (avatar, choreo playback, a full show), not at every micro-change.

1. Project skeleton: Config, Remotes, Types, server/client bootstraps. (Done in repo.)
2. WorldBuilder: the whole venue from primitives, runtime-built and reproducible.
3. Cookie avatar + costume layer on a standard R15 rig, swapped on/off by the queue.
4. Choreography record-and-playback. The signature mechanic. Make it feel like magic.
5. Vocal rhythm mini-game. Touch-first, no-fail.
6. Lights station + Stage FX station (one shared timeline UI, instantiated twice).
7. Applause meter + full round loop (prep / show / curtain call).
8. Queue + host priority + solo/show mode auto-flip.
9. DataStore persistence with retry and local caching.
10. Audio integration: note charts and beat grids once the Suno tracks are uploaded.

## The V1 spec

> The live interactive show model in DESIGN.md is the current direction and supersedes
> the prep-then-watch round structure below. The zones, mechanics, venue, and tone here
> still apply; the loop is now a live performance the whole room plays together.

### Session structure (rounds), roughly 8-12 minutes
1. Prep phase (4-5 min): Cookie trains vocals and choreography. Crew sets light and FX
   cues. Audience hangs out.
2. Show phase (2-3 min): Houselights drop. Cookie performs. Dancers run the recorded
   routine. Lights and FX fire programmed cues.
3. Curtain call (1 min): Applause meter celebrates. Next Cookie steps up.

### Mode auto-flip
- Solo Practice (default when alone): no timer, no audience, stations on autopilot.
  Cookie can train and perform freely.
- Show Mode (default at 2+ players): round structure starts. Prompt the solo player:
  "Friends joined! Start a show?"
- Drop back to Solo Practice automatically when everyone leaves, without losing routines.

### Cookie avatar and identity
- Only the player currently on stage wears the cookie avatar and pop-star costume.
  Everyone else keeps their normal Roblox avatar.
- Built from primitives on a standard R15 rig so default animations work. Chocolate-chip
  brown (`Color3.fromRGB(141, 85, 36)`), dot eyes, visible chips.
- Costume layer (active Cookie only): mic headset, sparkly Neon cape, a soft pink
  SpotLight on the HumanoidRootPart, ambient sparkle ParticleEmitter.
- When the round ends and the queue advances, revert the previous Cookie to normal.

### Cookie swap
- "Next Up" sign near the stage. Tap to join the queue. Sign shows the current Cookie
  plus the next three.
- 2-round cap, but only when someone else is waiting.
- Host priority: the config UserId (`Config.HOST_USER_ID`, Matt's daughter) jumps to the
  front and can extend past the cap.

### Mechanics
Backup dancers (record-and-playback):
- Choreo floor has footprint markers and a radial wheel of 6 dance moves, each a built-in
  Roblox emote animation in v1.
- A RECORD button starts a 32-beat timer at the current song's BPM. Taps record
  `{moveId, beat}` entries. 3 studio dummies play moves back live as they are triggered.
- During the show, 5 dancers in a line behind Cookie play the routine on the song's beat
  grid. Cookie can also trigger moves live; the dancers still follow the recording.
- Routine shape lives in `src/shared/Types.lua` (`Routine`).

Vocal training (rhythm mini-game):
- Notes scroll toward a hit target. Tap to hit, hold-and-drag for sustained notes. No
  microphone input, no voice chat.
- Fills a vocal power meter that feeds the applause meter. Missing a note does nothing,
  just a smaller contribution. Never show "MISS".
- Note chart per song in `src/shared/Songs/<song>`. Big circular hit target, color-coded
  notes (blue tap, gold hold), "GREAT!" / "GOOD!" bubbles on hit.

Lights and Stage FX stations:
- Same timeline-cue UI, built once and instantiated twice. A beat track snapped to the
  song's beats, a palette of cue blocks, drag to place, tap to delete. D-pad + Triangle
  to cycle cue types for PlayStation.
- Lights cues: spotlight, color, strobe, blackout. FX cues: confetti, fog, sparkle,
  backdrop change. 3 backdrops: Cotton Candy Sky, Midnight Bakery, Crumb Galaxy.
- An unmanned station runs a competent autopilot cue list during the show.

### Scoring (no-fail)
- Applause meter starts at 50% and only goes up. It fills from rhythm hits, dance moves
  triggered, lighting and FX cues programmed, and audience emoji throws.
- The meter must reach at least 50% by participation alone. Tune rates so this holds.
- Tiers: "Sweet Show!" 50-69, "Sold Out!" 70-89, "Legendary!" 90-100. The meter is for
  the whole show, never per-player. End-of-show language is "Best show yet!", "Crowd
  favorite!", "Sparkliest finale!", never numbers.

### Persistence (DataStore)
Persists per player: up to 3 named routines, named light and FX cue sheets per song,
wardrobe unlocks (10 cosmetic items in v1), and hidden stats (shows performed, top tier,
favorite song; saved quietly, no UI in v1). See `Profile` in `src/shared/Types.lua`.

Nothing gameplay-relevant persists. Wrap every DataStore call in `pcall` with exponential
backoff. Cache in memory and push on leave plus every 60 seconds. If a save fails 3 times,
log a warning and move on. Losing 60 seconds of work beats breaking the session.

Wardrobe unlocks (cosmetic only): 5 from first try of each station, 5 from milestones
(first Sweet Show, first Sold Out, first Legendary, 10 shows, 25 shows).

### Venue (single open-plan space)
One open warehouse-style room, no interior walls, everything visible from spawn.
- Stage at one end: raised platform, backdrop frame, lighting rig overhead.
- Audience seating: tiered cupcake seats facing the stage.
- Vocal Booth (left of center): butter-stick mic stand, music-note floor decal.
- Green Room (center spawn): wardrobe rack and the Next Up sign.
- Choreo Floor (right of center): mirror walls, footprint markers.
- Production Booth (back, raised): the Lights and FX station podiums.

Every prop is a bakery item at scale: rolling-pin mic, giant-whisk lighting rig, cupcake
seats, stand-mixer booth, cutting-board stage.

### No tutorial
Big floor signs label every zone. Single-line hints appear on interaction markers.
Universal icons (microphone, music note, light bulb) so a non-reader can navigate.

## Tone enforcement (user-facing text, signs, comments)

Every piece of user-facing text reads like a person wrote it, and encourages a 6-10
year old.

Good: "Sweet Show!", "Crowd loved it!", "Best one yet!", "Time to dance!", "Nice hit!"
Bad: "Performance Complete.", "Score: 67/100.", "Try again to improve.", "Achievement
Unlocked."

Avoid everywhere:
- Em dashes. Use commas or split the sentence.
- AI-sounding words: "leverage", "utilize", "seamless", "robust", "holistic",
  "paradigm", "cutting-edge", "delve", "tapestry".
- Comparative language ("better than last show", "your friend earned more"), failure
  language ("you lost", "try again", "you missed"). A Sprinkles count is fine to show;
  a grade, a rank, or a player-vs-player score is not.

When in doubt: would this make a 7-year-old smile, or feel like a math test? Aim for smile.

## Assets

Generate visual assets with the nanobanana skill (do not ask Matt to make them by hand),
then upload to Roblox via MCP and reference by asset id. Source files live in `assets/`
(backdrops, icon, promo, reference). The two songs are generated on Suno by Matt, uploaded
under his account, and their asset ids go into `Config.SONGS`. The `.png` and `.mp3`
sources stay local; git tracks the small images and ignores the audio.

The full shot list (backdrops, place thumbnail, avatar reference, title screen) and the
exact prompts that produced the current assets are preserved in `ROBLOX_LESSONS.md` and
the `assets/` folder. Reuse those prompts when regenerating.

## Definition of done for v1

1. Matt's daughter can join the place on her device.
2. She can walk around the venue and recognize every zone.
3. She can train vocals in the booth (rhythm mini-game works).
4. She can record a routine and watch the NPC dancers learn it.
5. She can walk on stage, trigger a show, and see her dancers perform behind her.
6. She can program lights and FX from the production booth.
7. The show ends in confetti and a positive message every time.
8. She can save 3 routines and unlock wardrobe items between sessions.
9. A friend can join, claim the lights station, and contribute to a real show.
10. She queues to be Cookie, performs, and returns to her normal avatar at round end.

When all 10 hold, hand back to Matt with a "v1 is shippable" note. Hold the v2 wishlist
for another conversation.
