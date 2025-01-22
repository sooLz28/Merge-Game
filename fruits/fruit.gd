extends RigidBody2D

@export var resource: Resource  # Reference the custom resource

var fruit_name: String = "Unknown"
var fruit_scale:= 1.0
var fruit_sprite : Texture
var fruit_score:= 0.0
var next_fruit : PackedScene
func _ready() -> void:
	if resource and resource is FruitsResources:
		fruit_name = resource.fruit_name
		fruit_scale = resource.scale
		fruit_sprite = resource.fruit_sprite
		fruit_score = resource.score
		next_fruit = resource.next_fruit
		
		
		$content/Sprite.texture = fruit_sprite
	
	$content.scale = Vector2(fruit_scale,fruit_scale)
	$CollisionShape2D.scale = Vector2(fruit_scale,fruit_scale)
	physics_material_override.absorbent = true
	physics_material_override.bounce = resource.bounce
	physics_material_override.friction = resource.friction	
	
