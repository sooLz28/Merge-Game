extends Node2D

var droppable_fruits := [load("res://fruits/droppable/blueberry.tscn"),load("res://fruits/droppable/blueberry.tscn"),load("res://fruits/droppable/cherry.tscn"),load("res://fruits/droppable/cherry.tscn"),load("res://fruits/droppable/grape.tscn"),load("res://fruits/droppable/grape.tscn"),load("res://fruits/droppable/lemon.tscn"),load("res://fruits/droppable/orange.tscn"),load("res://fruits/droppable/strawberry.tscn")]
var score := 0
#var highest_score = 0

var fruit_ready = false
@onready var spawn_point = %spawn_point
@onready var fruits_node = %Fruits
@onready var next_fruit = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !fruit_ready and %spawn_cooldown.time_left == 0:
			
			if next_fruit == null:
				var new_fruit = droppable_fruits.pick_random().instantiate()
				print(new_fruit.find_child("CollisionShape2D").disabled)
				print(new_fruit.find_child("CollisionShape2D").disabled)
				new_fruit.set_collision_layer_value(1,false)
				new_fruit.set_collision_mask_value(1,false)
				spawn_point.add_child(new_fruit)
				fruit_ready = true
			else:
				var new_fruit = next_fruit
				next_fruit = null
				$next_fruit_container/VBoxContainer/Texture.texture = null
				print(new_fruit.find_child("CollisionShape2D").disabled)
				print(new_fruit.find_child("CollisionShape2D").disabled)
				new_fruit.set_collision_layer_value(1,false)
				new_fruit.set_collision_mask_value(1,false)
				spawn_point.add_child(new_fruit)
				fruit_ready = true
				

				
			if next_fruit == null:
				next_fruit = droppable_fruits.pick_random().instantiate()
				next_fruit._ready()
				print(next_fruit.fruit_sprite)
				$next_fruit_container/VBoxContainer/Texture.texture = next_fruit.fruit_sprite

	# Move cursor that moves the fruit before it spawns
	if Input.is_action_pressed("press"):
		if spawn_point.get_child_count() != 0:
			# Get the first child of spawn_point
			var drop_fruit = spawn_point.get_child(0)
			var sprite = drop_fruit.find_child("content").find_child("Sprite")
			if sprite and sprite.texture:
				var sprite_width = sprite.texture.get_width() * sprite.scale.x
				# Constrain the spawn point within the screen bounds
				spawn_point.position.x = clamp(
					get_global_mouse_position().x,
					0 + sprite_width * drop_fruit.find_child("content").scale.x/ 2,
					get_viewport_rect().size.x - sprite_width * drop_fruit.find_child("content").scale.x / 2
				)


	#Drop the fruit
	if Input.is_action_just_released("press"):
		
		if spawn_point.get_child_count() != 0:
			# Get the first child of spawn_point
			var drop_fruit = spawn_point.get_child(0)
			var drop_fruit_global_pos = drop_fruit.global_position
			print(drop_fruit_global_pos)
			drop_fruit.set_collision_layer_value(1,true)
			drop_fruit.set_collision_mask_value(1,true)
			
			# Remove the child from spawn_point and add it to the current node
			spawn_point.remove_child(drop_fruit)
			fruits_node.add_child(drop_fruit)
		
			
			drop_fruit.find_child("Area2D").body_entered.connect(Callable(_on_area_2d_body_entered).bind(drop_fruit))

			# Update the position to maintain its global position
			drop_fruit.global_position = drop_fruit_global_pos
			drop_fruit.gravity_scale = 1.5
			
			fruit_ready = false
			%spawn_cooldown.start()
		else:
			print("No children in spawn_point.")
		

func create_next_fruit():
	pass

func add_new_fruit(new_fruit: Node2D) -> void:
	fruits_node.add_child(new_fruit)
	
func _on_area_2d_body_entered(body,fruit) -> void:
	if body != fruit and body != $wall:
		if  body.fruit_name.to_lower() == fruit.fruit_name.to_lower():
			var spawn_pos = (body.position + fruit.position) / 2
			
			var new_fruit
			if fruit.next_fruit:
				new_fruit = fruit.next_fruit.instantiate()
				new_fruit.find_child("Area2D").body_entered.connect(Callable(_on_area_2d_body_entered).bind(new_fruit))
				
				new_fruit.position = spawn_pos
				new_fruit.gravity_scale = 1
				call_deferred("add_new_fruit", new_fruit)

				score+=fruit.fruit_score * 2
				$Score.text=str(score)

				fruit.queue_free()
				body.queue_free()
				body.find_child("Area2D").body_entered.disconnect( Callable(_on_area_2d_body_entered))


	
func new_game():
	score = 0
	pass


func _on_death_zone_body_entered(body: Node2D) -> void:
	print("_on_death_zone_body_entered")
	if body != $wall and $death_timer.is_stopped():
		print(" it is a fruit")
		$death_timer.start()

func _on_death_timer_timeout() -> void:
	var bodies = $death_zone.get_overlapping_bodies()  # Get all overlapping bodies
	var game_over = false
	
	# If there are no bodies at all, we don't need to trigger game over
	if bodies.is_empty():
		$death_timer.stop()
		return
	
	var i = 0
	for body in bodies:
		# Check if the body has the fruit_name variable
		if "fruit_name" in body:
			i+=1
		if i >= 5:
			game_over = true
			break
	
	# Only trigger game over if we found at least one fruit
	if game_over:
		
		$gameover.show()
		Engine.time_scale = 0
	else:
		$death_timer.stop()
