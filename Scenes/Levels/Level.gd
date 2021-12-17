extends YSort

onready var pathfinder = $Tilemap/Pathfinder

func _ready() -> void:
	var __ = EVENTS.connect("actor_died", self, "_on_EVENTS_actor_died")
	
	_close_doors()
	_feed_enemies()


func _feed_enemies() -> void:
	var enemies_array = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in enemies_array:
		enemy.pathfinder = pathfinder


func _close_doors() -> void:
	var doors_array = get_tree().get_nodes_in_group("Door")
	
	for door in doors_array:
		door.close()


func _on_EVENTS_actor_died(actor: Actor) -> void:
	if actor is Enemy:
		var nb_enemies = get_tree().get_nodes_in_group("Enemy").size() - 1
		
		if nb_enemies == 0:
			EVENTS.emit_signal("room_completed")
