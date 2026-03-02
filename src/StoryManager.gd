extends Node

var flags: Dictionary = {}

func set_flag(key: String, value: bool = true) -> void:
	flags[key] = value


func get_flag(key: String, default: bool = false):
	return flags.get(key, default)


func has_flag(key: String) -> bool:
	return flags.has(key)


func reset() -> void:
	flags.clear()
