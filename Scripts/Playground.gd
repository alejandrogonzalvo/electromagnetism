extends Polygon2D




var bodies
var distances_image
var charges_image
var array_texture
func _ready() -> void:
	

	
	# Creating an distances_image to store the array values. We set the width to the array size.
	# The height is set to 1. That way we have one pixel for each array item.
	# We don't use mipmaps, we don't need them for a pure data distances_image.
	# Finally we set the format to RGF. It means "red green float". So we have two channels,
	# each can store a float (32 bit). This is perfect for storing 2D vectors.
	distances_image = Image.new()
	bodies = get_children()
	distances_image.create(bodies.size(), 1, false, distances_image.FORMAT_RGF)
	
	charges_image = Image.new()
	charges_image.create(bodies.size(), 1, false, distances_image.FORMAT_RF)
	
	charges_image.lock()
	for index in bodies.size():
		var charge = bodies[index].charge
		charges_image.set_pixel(index, 0, Color(charge, 0.0, 0.0, 0.0))
	charges_image.unlock()
		
	# Create a texture. Raw images can't be set as a shader param, so we need
	# this additional step to wrap the data into a texture.
	array_texture = ImageTexture.new()
	array_texture.create_from_image(charges_image)
	
	# Finally set the shader parameter to use our data texture. This will automatically
	# transfer the distances_image data to the GPU so that we can use the data in the shader.
	material.set_shader_param('charges', array_texture)

	


func _physics_process(delta):
	for attractor in get_children():
		for attracted in get_children():
			if attracted != attractor and not attracted.still:
				var direction_vector = (attractor.position - attracted.position).normalized()
				var distance = sqrt(pow(direction_vector.x, 2) + pow(direction_vector.y, 2))
				attracted.velocity += -direction_vector * attractor.charge * attracted.charge / pow(distance, 2)
				attracted.move_and_slide(attracted.velocity)
	
	# We lock the distances_image (means no one else can access the pixels while we modify them)
	# and fill it with our data. For that we iterate our array and set the corresponding
	# pixels. Finally we unlock the distances_image again, otherwise it could not be accessed
	# for transferring it to the GPU.
	distances_image.lock()
	for index in bodies.size():
		var vector = bodies[index].position
		distances_image.set_pixel(index, 0, Color(vector.x, vector.y, 0.0, 0.0))
	distances_image.unlock()
		
	# Create a texture. Raw images can't be set as a shader param, so we need
	# this additional step to wrap the data into a texture.
	array_texture = ImageTexture.new()
	array_texture.create_from_image(distances_image)
	
	# Finally set the shader parameter to use our data texture. This will automatically
	# transfer the distances_image data to the GPU so that we can use the data in the shader.
	material.set_shader_param('distances', array_texture)

func on_tree_exited():
	distances_image = Image.new()
	bodies = get_children()
	distances_image.create(bodies.size(), 1, false, distances_image.FORMAT_RGF)
	
	charges_image = Image.new()
	charges_image.create(bodies.size(), 1, false, distances_image.FORMAT_RF)
	
	charges_image.lock()
	for index in bodies.size():
		var charge = bodies[index].charge
		charges_image.set_pixel(index, 0, Color(charge, 0.0, 0.0, 0.0))
	charges_image.unlock()

	array_texture = ImageTexture.new()
	array_texture.create_from_image(charges_image)

	material.set_shader_param('charges', array_texture)
