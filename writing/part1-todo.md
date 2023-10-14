## to-do
**Things that happen when tp into the desert**
- MessageBox: "As you venture forth, be aware that the tides of time may carry you to places unknown, and the consequences could be beyond imagination. Are you ready?"
- journal ggw_01_tg 1
- player->removespell ggw_cave_spelleffect_01
- player->removespell ggw_cave_spelleffect_02
- player->removespell ggw_cave_spelleffect_02a
- player->removespell ggw_cave_spelleffect_03
- player->removespell ggw_cave_spelleffect_04
- player->removespell ggw_cave_spelleffect_04a
- player->removespell ggw_cave_spelleffect_05
- tp to desert (anywhere with the halls in view)
- MessageBox upon arrival "You find yourself in a desert expanse, weakened, disoriented, and utterly confused. The transition through the rift has left your senses in disarray, and the searing heat of the desert sun beats down upon you"
- timer (5-10 seconds)
- Messagebox "After mere minutes of wandering, the extreme heat takes its toll on you. Dizziness sets in, and your vision blurs as you stumble and collapse onto the hot sand. "
- fadeout/fadein, tp in "Imperial Outpost" 2634, -1246, -114

**Other things	
- shader/decal/glitch/heartbeat for decay with stronger effect near the rift
- script the rowboat to take the player through the waterfall
Starting point:
`{ cell = "ggw cave", position = { -1498.1079101563, 174.79121398926, -15.893859863281 }, orientation = { 0, 0, -2.5661191940308 } },`
Way point
`{ cell = "ggw cave", position = { -2485.6877441406, -1004.0860595703, -169.69999694824 }, orientation = { 0, 0, -2.3975887298584 } },`
Destination
`{ cell = "ggw cave", position = { -3133.7785644531, -1862.3043212891, -33.118621826172 }, orientation = { 0, 0, -2.5835921764374 } },`
> for now rowboat-door trick - Danae

**We need...**
- Decaying variants of appropriate flora and fauna assets.
- Assets for the artifact itself.
- Distortion VFX shaders