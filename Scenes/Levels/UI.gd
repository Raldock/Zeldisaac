extends Control

func _ready() -> void:
	var __ = EVENTS.connect("character_hp_changed", self, "_on_EVENTS_character_hp_changed")


func _on_EVENTS_character_hp_changed(hp: int) -> void:
	$HUD/HP.set_value(hp)
