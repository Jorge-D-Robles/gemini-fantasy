extends GutTest

## Tests for party recruitment wiring in Act II story events.
## Verifies that Cipher, Sienna, and Ash recruitment events
## load character data and have correct data path constants.


# --- Cipher (iron_coast.gd) ---


func test_cipher_data_path_defined() -> void:
	assert_eq(
		IronCoast.CIPHER_DATA_PATH,
		"res://data/characters/cipher.tres",
		"Cipher data path should be defined",
	)


func test_cipher_data_loads() -> void:
	var data := load(IronCoast.CIPHER_DATA_PATH)
	assert_not_null(data, "Cipher data should load")


func test_cipher_data_is_character() -> void:
	var data := load(IronCoast.CIPHER_DATA_PATH)
	assert_is(data, CharacterData, "Should be CharacterData")


func test_cipher_data_id() -> void:
	var data := load(IronCoast.CIPHER_DATA_PATH) as CharacterData
	assert_eq(data.id, &"cipher", "ID should be cipher")


# --- Sienna (sisters_shadow.gd) ---


func test_sienna_data_path_defined() -> void:
	assert_eq(
		SistersShadow.SIENNA_DATA_PATH,
		"res://data/characters/sienna.tres",
		"Sienna data path should be defined",
	)


func test_sienna_data_loads() -> void:
	var data := load(SistersShadow.SIENNA_DATA_PATH)
	assert_not_null(data, "Sienna data should load")


func test_sienna_data_is_character() -> void:
	var data := load(SistersShadow.SIENNA_DATA_PATH)
	assert_is(data, CharacterData, "Should be CharacterData")


func test_sienna_data_id() -> void:
	var data := load(
		SistersShadow.SIENNA_DATA_PATH,
	) as CharacterData
	assert_eq(data.id, &"sienna", "ID should be sienna")


# --- Ash (fire_and_ash.gd) ---


func test_ash_data_path_defined() -> void:
	assert_eq(
		FireAndAsh.ASH_DATA_PATH,
		"res://data/characters/ash.tres",
		"Ash data path should be defined",
	)


func test_ash_data_loads() -> void:
	var data := load(FireAndAsh.ASH_DATA_PATH)
	assert_not_null(data, "Ash data should load")


func test_ash_data_is_character() -> void:
	var data := load(FireAndAsh.ASH_DATA_PATH)
	assert_is(data, CharacterData, "Should be CharacterData")


func test_ash_data_id() -> void:
	var data := load(FireAndAsh.ASH_DATA_PATH) as CharacterData
	assert_eq(data.id, &"ash", "ID should be ash")
