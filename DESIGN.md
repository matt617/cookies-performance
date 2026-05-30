# Cookie's Performance — Interactive Show Design

This is the current gameplay direction. It supersedes the prep-then-watch round
structure in CLAUDE.md. The venue, zones, tone, and the no-fail spirit there all still
hold; the loop is now a live performance the whole room plays together.

## The core idea

The show is the game. Everyone performs live, at the same time, for about 90 seconds.
The old plan put all the doing in prep (record the dance, program the lights, program
the FX) and made the show itself a thing you watched. That was backwards: the peak
moment, being a pop star on stage, was the least interactive part. So prep is now
optional and the performance is where the fun lives.

## Two gears

The venue slides between two states with no menus and no loading:

- **Hangout** (default): everyone wanders, messes with stations, practices in the booth,
  records routines on the choreo floor. No timer, no pressure.
- **Show** (live, ~90 seconds): the whole room performs together, then confetti and
  Sprinkles rain, then back to Hangout.

**Solo** is just Hangout while alone: practice vocals, record a routine, sandbox the
lights and FX, and step on stage to perform with the crew on autopilot whenever. Nothing
is gated. This works whether it is the host's daughter alone or any friend solo
pretending to be Cookie.

## Who is Cookie (and the badge)

- **Default star, can lend the mic.** The host account (Config.HOST_USER_ID, the
  daughter) is Cookie by default, always wears the badge, and has priority. She can
  choose to hand the mic to a friend for a song, then take it back.
- **The badge.** Her account always wears a HUD chip, a little crown with "YOU'RE
  COOKIE" (or "HEADLINER"), visible the whole time so she feels like the star even while
  just hanging out. When a show starts it blooms into her performer HUD.
- **Director powers.** Cookie is the one who calls a show (see below).
- Any solo player can be the on-stage Cookie when alone; only the host account wears the
  admin badge.

## Show lifecycle

1. **Hangout.** Friends mill about, mess with stations.
2. **Cookie calls the show.** Only Cookie/admin presses "Start Show." She is the
   director and controls the pacing. (Solo needs no call; she just steps on stage.)
3. **Friends claim jobs.** Walk up to the Lights booth or the FX booth to grab that job.
   Everyone else is in the crowd. No menus.
4. **"Places, everyone!"** A short countdown builds the moment.
5. **Transformation beat.** House lights dim, a spotlight snaps onto Cookie, sparkles
   burst, her avatar becomes the cookie pop-star, a cue hits ("You're on, Cookie!").
6. **The live show.** The song plays and every role performs live (below).
7. **Curtain call.** Confetti, the applause tier ("Sweet Show!" / "Sold Out!" /
   "Legendary!"), and everyone's Sprinkles total celebrates.
8. **Back to Hangout.**

## Live gameplay, by role

Everyone is doing something during the show. That is the answer to "more jobs."

- **Cookie (the star):** sing the scrolling notes (tap/hold on the beat), pop dance moves
  from the radial wheel (dancers mirror her live), and nail hype prompts ("Hands up!",
  "Strike a pose!", "Big finish!"). Busy and expressive the whole song.
- **Lights crew (friend):** run the rig live, fire spotlight/color/strobe/blackout on the
  beat, keep the spotlight on Cookie. On-beat cues feel and pay better.
- **Stage FX crew (friend):** fire confetti/sparkle/fog/backdrop live, timed to the song
  and Cookie's big moments.
- **Audience (friends with no station):** throw reaction emojis, mash cheer at the finish.
- **Backup dancers (NPC):** mirror Cookie's live moves. They run an optional recorded
  routine as a base if one exists, otherwise a good default routine.

Empty stations run a competent autopilot so a solo show still looks great.

## Choreography recording (optional flourish)

Recording is a practice-and-customize toy, never a pre-show chore.

- Available in Hangout/solo at the choreo floor. Record a 32-beat routine; the studio
  dummies learn it live so you can see it; replay to check it.
- The dancers always have a good default routine, so you can skip recording entirely and
  still put on a full show.
- A saved routine becomes the dancers' base for the next show; Cookie's live moves layer
  on top.

## Economy: Sprinkles

A soft collectible currency earned by playing your job well during the show. (Where to
spend Sprinkles is intentionally parked for later.)

Three rules keep it on-brand:
- **Only ever goes up.** A miss earns zero, never a penalty. Same no-fail spirit as the
  applause meter.
- **Personal, not a ranking.** Each kid sees their own happy pile grow. Never
  player-vs-player, no leaderboard.
- **Generous floor, higher ceiling.** A button-masher still gets a satisfying shower; a
  kid who feels the beat earns more. Skill rewards timing, it never gates the fun.

Earning (values illustrative, live in Config):

- **Cookie:** hit a note +1, with a Great/Good timing bump (+3/+1); sustained note held
  +5; on-beat dance move +2 and a sparkle (off-beat still +1); hype prompt nailed +10
  burst; a clean streak lights an "On fire!" glow that doubles coins while it lasts
  (breaking it just ends the glow, no loss).
- **Lights:** any cue +1, on-beat +3 and a "Nice cue!" pop; spotlight kept on Cookie, a
  steady trickle; reading the song (strobe on chorus, color on the drop) +5.
- **FX:** confetti on chorus/finale +5, sparkle on a big move +3, fog/backdrop on a
  transition +5; same on-beat bump.
- **Audience:** reaction emoji +1 each; cheer flurry at the finish.

Shared moments:
- **Showcase peaks** (chorus, drop, finale): every action is worth more for everyone at
  once.
- **Perfect Moment:** when multiple roles land the same beat together (Cookie's finish +
  confetti + spotlight + crowd cheer), a big shared coin shower. The teamwork hook.
- **Golden Sprinkle:** a rare jackpot coin that pops out at a peak.

End of show:
- A finale bonus for everyone scaled to the shared applause tier ("Sold Out! Everyone
  +50"), so it is collaborative, not competitive.
- A flat "you performed!" participation bonus so nobody leaves with nothing.

The applause meter is the room's collective success and sets the end tier. Sprinkles are
your personal take-home from how you played. Good play feeds both.

## Open / parked

- Where to spend Sprinkles (wardrobe, stickers, venue decor, etc.). Parked on purpose.
- Whether lending the mic uses a light "Next Up" sign or a direct hand-off gesture.
