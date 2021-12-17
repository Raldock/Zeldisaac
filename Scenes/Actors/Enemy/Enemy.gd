extends Actor
class_name Enemy

onready var behaviour_tree = $BehaviourTree
onready var chase_area = $ChaseArea
onready var attack_area = $AttackArea
onready var debug_path = $DebugPath

var target : Node2D = null
var path : Array = []

var pathfinder : Pathfinder = null

var target_in_chase_area : bool = false setget set_target_in_chase_area
var target_in_attack_area : bool = false setget set_target_in_attack_area

signal target_in_chase_area_changed
signal target_in_attack_area_changed
signal move_path_finished

#### ACCESSORS ####

func set_target_in_chase_area(value: bool) -> void:
	if value != target_in_chase_area:
		target_in_chase_area = value
		emit_signal("target_in_chase_area_changed", target_in_chase_area)

func set_target_in_attack_area(value: bool) -> void:
	if value != target_in_attack_area:
		target_in_attack_area = value
		emit_signal("target_in_attack_area_changed", target_in_attack_area)


#### BUILT-IN ####

func _ready() -> void:
	var __ = chase_area.connect("body_entered", self, "_on_ChaseArea_body_entered")
	__ = chase_area.connect("body_exited", self, "_on_ChaseArea_body_exited")
	__ = attack_area.connect("body_entered", self, "_on_AttackArea_body_entered")
	__ = attack_area.connect("body_exited", self, "_on_AttackArea_body_exited")
	__ = $BehaviourTree/Attack/Cooldown.connect("timeout", self, "_on_AttackCooldown_timeout")
	__ = connect("target_in_chase_area_changed", self, "_on_target_in_chase_area_changed")
	__ = connect("target_in_attack_area_changed", self, "_on_target_in_attack_area_changed")



#### LOGIC ####

func _update_target() -> void:
	if !target_in_attack_area && !target_in_chase_area:
		target = null


func _update_behaviour_state() -> void:
	if state_machine.get_state_name() == "Dead":
		return
	
	if target_in_attack_area:
		if $BehaviourTree/Attack.is_cooldown_running():
			behaviour_tree.set_state("Inactive")
		else:
			behaviour_tree.set_state("Attack")
		
	elif target_in_chase_area:
		behaviour_tree.set_state("Chase")
	
	else:
		behaviour_tree.set_state("Wander")


func update_move_path(dest: Vector2, remove_last_point: bool = false) -> void:
	if pathfinder == null:
		path = [dest]
	else:
		path = pathfinder.find_path(global_position, dest)
		
		if remove_last_point && !path.empty():
			path.remove(path.size() - 1)
	
	if debug_path.is_visible():
		var pool_v_path = PoolVector2Array(path)
		var local_path = get_transform().xform_inv(pool_v_path)
		debug_path.set_points(local_path)


func move_along_path(delta: float) -> void:
	if path.empty():
		return
	
	var dir = global_position.direction_to(path[0])
	var dist = global_position.distance_to(path[0])
	
	set_moving_direction(dir)
	
	if dist <= speed * delta:
		var __ = move_and_collide(dir * dist)
		path.remove(0)
		
		if path.empty():
			emit_signal("move_path_finished")
		
	else:
		var __ = move_and_collide(dir * speed * delta)


func die() -> void:
	behaviour_tree.set_state("Inactive")
	.die()


#### SIGNAL RESPONSES ####

func _on_ChaseArea_body_entered(body: Node2D) -> void:
	if body is Character:
		set_target_in_chase_area(true)
		target = body


func _on_ChaseArea_body_exited(body: Node2D) -> void:
	if body is Character:
		set_target_in_chase_area(false)


func _on_AttackArea_body_entered(body: Node2D) -> void:
	if body is Character:
		set_target_in_attack_area(true)
		target = body


func _on_AttackArea_body_exited(body: Node2D) -> void:
	if body is Character:
		set_target_in_attack_area(false)


func _on_target_in_chase_area_changed(_value: bool) -> void:
	_update_target()
	_update_behaviour_state()


func _on_target_in_attack_area_changed(_value: bool) -> void:
	_update_target()
	
	if target_in_attack_area:
		_update_behaviour_state()


func _on_moving_direction_changed() -> void:
	face_direction(moving_direction)


func _on_StateMachine_state_changed(state: Object) -> void:
	if state_machine == null:
		return
	
	var previous_state = state_machine.previous_state
	
	if state.name == "Hurt":
		behaviour_tree.set_state("Inactive")
	
	elif (state.name == "Idle" && previous_state == $StateMachine/Attack) \
			or previous_state == $StateMachine/Hurt:
		_update_behaviour_state()
	
	elif state.name == "Attack":
		face_position(target.global_position)


func _on_AttackCooldown_timeout() -> void:
	_update_behaviour_state()
