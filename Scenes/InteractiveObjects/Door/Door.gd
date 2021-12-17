extends StaticBody2D

onready var door_sprite = $DoorSprite
onready var grid_sprite = $GridSprite
onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	var __ = EVENTS.connect("room_completed", self, "_on_EVENTS_room_completed")


func open() -> void:
	grid_sprite.play("Unlock")
	yield(grid_sprite, "animation_finished")
	
	grid_sprite.play("Idle")
	
	door_sprite.play("Open")
	yield(door_sprite, "animation_finished")
	
	door_sprite.play("Opened")
	
	collision_shape.set_disabled(true)


func close() -> void:
	collision_shape.set_disabled(false)
	
	door_sprite.play("Close")
	yield(door_sprite, "animation_finished")
	
	door_sprite.play("Closed")
	grid_sprite.play("Lock")


func _on_EVENTS_room_completed() -> void:
	open()
