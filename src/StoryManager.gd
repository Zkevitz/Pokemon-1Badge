extends Node

enum Flag {
	HAS_POKEMON,
	INTRO_DONE,
	KEEPER_GIFT_DONE,
	RIVAL_BATTLE_1_DONE,
}

var flags: Dictionary = {}


func set_flag(key: Flag, value: bool = true) -> void:
	flags[key] = value


func get_flag(key: Flag, default: bool = false):
	return flags.get(key, default)


func has_flag(key: Flag) -> bool:
	return flags.has(key)


func reset() -> void:
	flags.clear()
