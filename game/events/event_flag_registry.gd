class_name EventFlagRegistry
extends RefCounted

## Centralized registry of all event flag string constants.
## Use these constants instead of inline string literals to prevent typos
## and enable IDE navigation.

# --- Recruitment flags ---
const OPENING_LYRA_DISCOVERED: String = "opening_lyra_discovered"
const IRIS_RECRUITED: String = "iris_recruited"
const GARRICK_RECRUITED: String = "garrick_recruited"
const NYX_MET: String = "nyx_met"
const NYX_INTRODUCTION_SEEN: String = "nyx_introduction_seen"

# --- Story event flags ---
const GARRICK_MET_LYRA: String = "garrick_met_lyra"
const GARRICK_NIGHT_SCENE: String = "garrick_night_scene"
const CAMP_SCENE_THREE_FIRES: String = "camp_scene_three_fires"
const BOSS_DEFEATED: String = "boss_defeated"
const DEMO_COMPLETE: String = "demo_complete"
const AFTER_CAPITAL_CAMP_SEEN: String = "after_capital_camp_seen"
const LEAVING_CAPITAL_SEEN: String = "leaving_capital_seen"
const LYRA_FRAGMENT_2_COLLECTED: String = "lyra_fragment_2_collected"

# --- Gardener resolution flags ---
const GARDENER_ENCOUNTERED: String = "gardener_encountered"
const GARDENER_RESOLUTION_PEACEFUL: String = "gardener_resolution_peaceful"
const GARDENER_RESOLUTION_QUEST: String = "gardener_resolution_quest"
const GARDENER_RESOLUTION_DEFEATED: String = "gardener_resolution_defeated"
