--!strict
-- Config.lua
-- Every tunable value in the game lives here. Never hardcode these in logic.
-- Filled with placeholders during scaffolding; tune as we build and playtest.

export type SongConfig = {
	id: string,
	title: string,
	bpm: number,
	-- Roblox audio asset id, pasted in after Matt uploads the Suno track.
	assetId: string?,
}

local Config = {}

-- Host priority. Matt's daughter jumps to the front of the Cookie queue and can
-- extend past the per-round cap. UserId confirmed out of band.
Config.HOST_USER_ID = 9536769581

-- Round timing, in seconds.
Config.PREP_SECONDS = 240
Config.SHOW_SECONDS = 150
Config.CURTAIN_CALL_SECONDS = 60

-- Cookie queue.
Config.QUEUE_ROUND_CAP = 2 -- only applies when someone else is waiting

-- Choreography.
Config.RECORD_BEATS = 32
Config.DANCE_MOVES = { "wave", "spin", "jump", "clap", "point", "shuffle" }

-- Applause meter. Starts halfway and only ever goes up.
Config.APPLAUSE_START = 50
Config.TIER_SWEET = 50 -- "Sweet Show!"   50-69
Config.TIER_SOLD_OUT = 70 -- "Sold Out!"    70-89
Config.TIER_LEGENDARY = 90 -- "Legendary!"   90-100

-- Persistence.
Config.AUTOSAVE_SECONDS = 60
Config.SAVE_RETRY_LIMIT = 3
Config.MAX_ROUTINES = 3
Config.WARDROBE_ITEM_COUNT = 10

-- Songs. assetId gets filled in after upload.
Config.SONGS = {
	sprinkles = {
		id = "sprinkles",
		title = "Sprinkles",
		bpm = 116,
		assetId = nil,
	} :: SongConfig,
	midnight_bakery = {
		id = "midnight_bakery",
		title = "Midnight Bakery",
		bpm = 92,
		assetId = nil,
	} :: SongConfig,
}

return Config
