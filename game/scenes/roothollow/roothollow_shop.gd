class_name RootHollowShop
extends RefCounted

## Flag-conditional shop inventory helper for Roothollow's general store.
## Returns the full item_paths array for ShopData based on current EventFlags.
## After iris_recruited, Bram stocks Forest Remedy and Crystal Wick —
## ingredients Iris identifies as useful in the Verdant Forest.
## See docs/story/act1/04-old-iron.md (Scene 1) for narrative context.

const FOREST_REMEDY_PATH: String = "res://data/items/forest_remedy.tres"
const CRYSTAL_WICK_PATH: String = "res://data/items/crystal_wick.tres"


static func compute_item_paths(
	base_paths: Array[String],
	flags: Dictionary,
) -> Array[String]:
	var paths: Array[String] = base_paths.duplicate()
	if flags.get("iris_recruited", false):
		paths.append(FOREST_REMEDY_PATH)
		paths.append(CRYSTAL_WICK_PATH)
	return paths
