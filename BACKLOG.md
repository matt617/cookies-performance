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

## EastWallCupcake (optional)

The cupcake on the wall in Venue.Walls is still the old primitive version. Swap it
to the mesh cupcake if we want it to match the audience.
