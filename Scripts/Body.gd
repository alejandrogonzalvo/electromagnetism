extends KinematicBody2D


export var charge:float = 0.1
export var velocity = Vector2.ZERO
export var still:bool = false

func _ready():
	scale.x = charge
	scale.y = charge
	_set_texture()
	var playground = get_parent()
	connect("tree_exited", playground, "on_tree_exited")

func _on_Area2D_area_entered(area):
	var collider = area.get_parent()
	
	if collider.charge == charge:
		if position.x < collider.position.x:
			queue_free()
		else:
			velocity += collider.velocity
			charge += collider.charge
			scale.x = charge
			scale.y = charge

	elif abs(collider.charge) < abs(charge):
		velocity += collider.velocity
		charge += collider.charge
		scale.x = charge
		scale.y = charge
	elif abs(collider.charge) >= abs(charge):
		queue_free()

func _set_texture():
	if charge > 0:
		$Sprite.texture = load("res://Static/positive.png")
	elif charge < 0:
		$Sprite.texture = load("res://Static/negative.png")
