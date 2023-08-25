extends CharacterBody3D

enum States{
	patrol,
	chasing,
	hunting,
	waiting
}

var playerInEarshotFar : bool 
var playerInEarshotClose : bool
var playerInSightFar : bool
var playerInSightClose : bool

var state : States
var navAgent : NavigationAgent3D
var waypointIndex : int

var Player

@export var waypoint : Array
@export var chaseSpeed = 6
@export var huntingSpeed = 4.5
@export var patrolSpeed = 3

var patrolTimer : Timer

func _ready():
	state = States.patrol
	navAgent = $NavigationAgent3D
	Player = get_tree().get_nodes_in_group("Player")[0]
	waypoint = get_tree().get_nodes_in_group("Ennemy Waypoint")
	navAgent.set_target_position(waypoint[0].global_position)
	patrolTimer = $PatrolTimer

func _process(delta):
	
	match state:
		States.patrol:
			if (navAgent.is_navigation_finished()):
				state = States.waiting
				patrolTimer.start()
				return 
			moveTowardPoint(delta, patrolSpeed)
			if(playerInEarshotFar):
				checkForPlayer()
		States.chasing:
			if (navAgent.is_navigation_finished()):
				patrolTimer.start()
				state = States.waiting
				return
			navAgent.set_target_position(Player.global_position)
			moveTowardPoint(delta, chaseSpeed)
		States.hunting:
			if (navAgent.is_navigation_finished()):
				patrolTimer.start()
				state = States.waiting
				return
			moveTowardPoint(delta, huntingSpeed)
		States.waiting:
			pass

func moveTowardPoint(delta, speed):
	var targetPos = navAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	move_and_slide()
	if (playerInEarshotFar):
		checkForPlayer()

func checkForPlayer():
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create($Head.global_position, Player.get_node("Camera3D").global_position, 1, [self]))
	if result.size() > 0:
		if(result["collider"].is_in_group("Player")):
			if(playerInEarshotClose):
				if(result["collider"].crouch == false):
					state = States.chasing
			
			if(playerInEarshotFar):
				if(result["collider"].crouch == false):
					state = States.hunting
					navAgent.set_target_position(Player.global_position)
			
			if(playerInSightClose):
					state = States.chasing
			
			if(playerInSightFar):
				if(result["collider"].crouch == false):
					state = States.hunting
					navAgent.set_target_position(Player.global_position)

func faceDirection(direction : Vector3):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _on_patrol_timer_timeout():
	state = States.patrol
	waypointIndex += 1
	if waypointIndex > waypoint.size()-1:
		waypointIndex = 0
	navAgent.set_target_position(waypoint[waypointIndex].global_position)

func _on_hearing_far_body_entered(body):
	if body.is_in_group("Player"):
		playerInEarshotFar = true
		print("Player's far")

func _on_hearing_far_body_exited(body):
	if body.is_in_group("Player"):
		playerInEarshotFar = false
		print("Player's far anymore")

func _on_hearing_close_body_entered(body):
	if body.is_in_group("Player"):
		playerInEarshotClose = true
		print("Player's close")

func _on_hearing_close_body_exited(body):
	if body.is_in_group("Player"):
		playerInEarshotClose = false
		print("Player's close anymore")

func _on_sight_close_body_entered(body):
	if body.is_in_group("Player"):
		playerInSightClose = true
		print("Player enter close sight")

func _on_sight_close_body_exited(body):
	if body.is_in_group("Player"):
		playerInSightClose = false
		print("Player left close sight")

func _on_sight_far_body_entered(body):
	if body.is_in_group("Player"):
		playerInSightFar = true
		print("Player enter far sight")

func _on_sight_far_body_exited(body):
	if body.is_in_group("Player"):
		playerInSightFar = false
		print("Player left far sight")
