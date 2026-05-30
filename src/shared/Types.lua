--!strict
-- Types.lua
-- Shared type definitions. Require this in any module that touches saved data so
-- the shapes stay honest across server and client.

export type DanceMove = {
	moveId: string,
	beat: number,
}

export type Routine = {
	name: string,
	songId: string,
	bpm: number,
	totalBeats: number,
	moves: { DanceMove },
}

export type Cue = {
	kind: string, -- "spotlight" | "color" | "strobe" | "blackout" | "confetti" | "fog" | "sparkle" | "backdrop"
	beat: number,
	value: string?, -- e.g. a color name or backdrop id, when the cue needs one
}

export type CueSheet = {
	name: string,
	songId: string,
	cues: { Cue },
}

export type Wardrobe = {
	unlocked: { string },
}

export type Stats = {
	showsPerformed: number,
	topTier: string,
	favoriteSong: string,
}

export type Profile = {
	routines: { Routine }, -- up to Config.MAX_ROUTINES
	lightSheets: { CueSheet },
	fxSheets: { CueSheet },
	wardrobe: Wardrobe,
	stats: Stats,
}

return nil
