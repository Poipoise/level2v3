extends CharacterBody2D
class_name player

signal health_changed

@export var invincible = false
@export var dive_speed = 125
var run_speed = 75
var sprint_speed = 125
var attacking = false
var health = 5
enum states {IDLE, MOVING, ATTACKING, DEAD, HURT, DIVING}
var state = states.IDLE
var input
var diving = false

func _physics_process(delta):
	choose_action()
	input = Input.get_vector("left", "right", "up", "down")
	
	
	if attacking:
		velocity = Vector2.ZERO
	elif state == states.DIVING:
		velocity = input * dive_speed
	elif Input.is_action_pressed("sprint"):
		velocity = input * sprint_speed
	else:
		velocity = input * run_speed
	
	if not attacking and not diving:
		if velocity.length() > 0:
				state = states.MOVING
		if velocity.length() == 0:
				state = states.IDLE
	if velocity.x != 0:
		transform.x.x = sign(velocity.x)
	move_and_slide()
	
	
func _input(event):
	if event.is_action_pressed("attack"):
		state = states.ATTACKING
	if event.is_action_pressed("roll"):
		state = states.DIVING
		
func choose_action():
	$Label.text = states.keys()[state]
	match state:
		states.DEAD:
			$AnimationPlayer.play("death")
			set_physics_process(false)
			velocity = Vector2.ZERO
			$CollisionShape2D.disabled = true
		states.IDLE:
			$AnimationPlayer.play("idle")
		states.MOVING:
			$AnimationPlayer.play("run")
			if velocity.x != 0:
				transform.x.x = sign(velocity.x)
		states.ATTACKING:
			attacking = true
			$AnimationPlayer.play("attack")
			await $AnimationPlayer.animation_finished
			attacking = false
			if velocity.length() > 0:
				state = states.MOVING
			if velocity.length() == 0:
				state = states.IDLE
		states.DIVING:
			diving = true
			$AnimationPlayer.play("dive")
			await $AnimationPlayer.animation_finished
			diving = false
			if velocity.length() > 0:
				state = states.MOVING
			if velocity.length() == 0:
				state = states.IDLE
func die():
	velocity = Vector2.ZERO
	$AnimationPlayer.play("death")

func hurt(amount, dir):
	if not invincible:
		var prev_state = state
		state = states.HURT
		health -= amount
		health_changed.emit(health)
		velocity = dir * 100
		await get_tree().create_timer(0.2).timeout
		state = prev_state
		if health <= 0:
			state = states.DEAD

func _on_hurtbox_body_entered(body):
	body.hurt(1, position.direction_to(body.position))
