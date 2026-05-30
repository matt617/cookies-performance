# Cookie's Performance backlog

Optional polish and v2 ideas. Nothing here is required for v1 (see the Definition
of Done in CLAUDE.md). Pull from this list only after v1 holds.

## Audience cupcake wrapper patterns (optional)

Put an image on the paper-liner part of the audience cupcakes. The mesh is the
"texturable" version with a real wrapper UV, so an image wraps cleanly around the
liner.

Ideas:
- A repeating liner pattern (stripes or polka dots) so the wrappers read like real
  paper cups.
- Something personal printed on the front of every wrapper: Cookie's name, a star,
  or one of her own drawings.

How to do it when we get to it:
1. Generate the image with the nanobanana skill (a tiling pattern, or the personal art).
2. Upload the PNG to Roblox (Asset Manager accepts .png), get the decal/image asset id.
3. Apply it to each seat's Wrapper part as a Texture or SurfaceAppearance.

Reference assets (already uploaded):
- Cupcake model: 98923177359139
- Wrapper mesh: rbxassetid://136006678508647 (this is the part that takes the picture)
- Frosting mesh: rbxassetid://106778616261389
- Cherry mesh: rbxassetid://119993486354590
- Template lives at ReplicatedStorage.CupcakeSeatTemplate; the 32 seats are
  Workspace.Venue.Audience.Cupcake_R{row}_C{col} (each a 3-part Model).

When the WorldBuilder script is written (build step 2), bake the cupcake audience in:
mesh ids above, scale 2.5, the varied frosting palette, and the grid math
(columns 8 studs apart, rows 13 apart and tiered up 2 studs).

## Cookie character rig (star + dancers)

The blocky dummies were replaced with a proper cartoon cookie person. Source model
asset 129366199099946 imported as 15 R15-named MeshParts + 15 Motor6Ds + RootPart.

Conversion done (bake into WorldBuilder / a CharacterBuilder module later):
- Renamed RootPart -> HumanoidRootPart, set as PrimaryPart.
- Renamed the 15 Motor6Ds to standard R15 joint names (Root, Waist, Neck, LeftShoulder,
  LeftElbow, LeftWrist, ... LeftHip, LeftKnee, LeftAnkle, and the right side).
- Removed the AnimationController, added a Humanoid (RigType R15) + Animator.
- HumanoidRootPart anchored + invisible; all limbs unanchored, massless, no-collide
  (so an in-place display NPC animates without falling).
- Scaled with Model:ScaleTo(1.87) -> about 7.3 studs tall.
- Colored all parts chocolate-chip brown (141,85,36).
- Posed arms down: rotate each shoulder Motor6D C0 by +/-72 deg about local Z and move
  the arm parts to match, so the rest pose is not a T-pose.
- Verified: a default R15 dance (rbxassetid://507771019) loads and plays (head moved).

Template lives at ReplicatedStorage.CookieRigTemplate. Clones placed over the old
CookiePreview (stage star), BackupDancer1-5 (behind stage, z=-135), and Dummy1-3
(choreo studio). Old dummies deleted.

Still TODO:
- Face + chocolate-chip graphics via nanobanana: the model has a flat head front panel
  and torso panel for decals. Generate a face (eyes, smile, cheek star) and a chip
  pattern, upload as images, apply to Head/UpperTorso.
- Wire dance animations (the choreo record-and-playback mechanic) and a looping idle so
  NPCs are never statically posed in play.
- Star Cookie costume layer (cape, headset, sparkle) on the on-stage rig only.

Note: a pre-existing ProfileStore script in the place logs DataStore load failures in
Studio playtest (needs Studio API access enabled, or it is placeholder). Unrelated to
the rig; check when wiring persistence.

## Microphone stands (stage + vocal booth)

Both mics were swapped from primitives to a real 3D mic stand model. Bake these into
the WorldBuilder script (build step 2) so they rebuild themselves and stay in git.

Reference assets (already uploaded):
- Mic model: 115718750691398
- MicHead mesh: rbxassetid://90336745786197
- MicBody mesh: rbxassetid://100940891365855
- StandPole mesh: rbxassetid://106569234227425
- StandBase mesh: rbxassetid://104906637161860
- Template lives at ReplicatedStorage.MicStandTemplate (4-part Model).

Build settings used:
- Scale: 2.5 (gives a slim stand about 5.46 studs tall, base 1.1 wide).
- Colors: MicHead (195,196,200) Metal, MicBody (38,38,44) SmoothPlastic,
  StandPole (172,174,178) Metal, StandBase (34,34,40) SmoothPlastic.

Placements (base sits on the floor at these spots):
- Stage: Workspace.Venue.Stage.MicStand at (0, 6.0, -122). This is about 2.5 studs in
  front of where Cookie stands (she is at X=0, Z=-124.8 on a deck top of Y=6), so the
  slim stand does not cover her. Mic head lands near Y=11.46, her mouth height.
- Vocal booth: Workspace.Venue.VocalBooth.MicStand at (-50, 0.4, 0), centered on the
  booth floor plate inside the half-wall ring.

Note: the headset mic on the cookie avatar (CookiePreview.Costume MicBoom + MicBall) is
separate and intentionally left as is.

## Wall posters (baked-good universe)

Eight framed mock concert/theatre posters hang on the side walls. Art is in
assets/posters/ (generated with nanobanana). Each board is a thin Part with a gold
Metal frame Part behind it, under Workspace.Venue.Posters. Decals already uploaded
and applied. West-wall boards use Decal Face Right, east-wall boards use Face Left.

Layout (boards centered at y=13, ~9 wide x 13.5 tall):
- West wall (x=-79.7): TaylorSift z=-110, Bunyonce z=-70, ElvisPretzely z=-20, DoughaLipa z=40
- East wall (x=79.7): BrunoMacaroon z=-110, Whisked z=-70, PhantomOvena z=-20, Frosted z=40

Decal asset ids:
- Taylor Sift: 76712388279635
- Bun-yonce: 73753750679212
- Elvis Pretzely: 78182678868270
- Dough-a Lipa: 117315526562000
- Bruno Macaroon: 119565125149458
- Whisked: 91027214032610
- Phantom of the Oven-a: 119237852227850
- Frosted: 105554672061540
- Benson Boule: 121808504895619 (on the BACK wall, x=0 z=89.9, Decal Face Front)

Bake into WorldBuilder later. Easy to add more posters: same pattern, pick a free z.

## EastWallCupcake (optional)

The cupcake on the wall in Venue.Walls is still the old primitive version. Swap it
to the mesh cupcake if we want it to match the audience.
