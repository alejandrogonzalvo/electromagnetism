shader_type canvas_item;

// This texture will be used to transfer the array data from the
// CPU (GDScript) to the GPU (shader code). It will be generated
// in a script and then set as the shader parameter within that
// script, which will automatically push it to the GPU so we can
// use it here.
uniform sampler2D distances : hint_black;
uniform sampler2D charges: hint_black;

// We can only access the VERTEX built-in variable in the vertex
// stage. However, we need the current drawing position in the 
// fragement stage to calculate the distance to the nearest potential.
// Therefore we define this varying to pass the information from
// vertex to fragment stage.
varying vec2 position;


/*
 * This is basically the method where you implement your distance
 * function. I simply use the distance to the nearest potential,
 * but to be honest have no idea if this is correct for electric
 * distances.
 */
float getDistance(vec2 current_position) {
	// Read the texture size and get the width component.
	// This is equal to the original array size.
	int array_size = textureSize(distances, 0).x;
	
	// Distance of first array item. Calculated by fetching the first pixel of
	// the texture, then calculating the distance to the current position
	vec2 pos = texelFetch(distances, ivec2(0, 0), 0).xy;
	float charge = texelFetch(charges, ivec2(0, 0), 0).x;
	float dist = distance(pos, current_position);
	float potential = 1000.0*charge/pow(dist, 2);
	
	// Iterate all other items (start=1) and override distance if it is shorter.
	// You could also do things like calculating the average of all items.
	for (int index=1; index<array_size; index++) {
		// Fetch position from texture using the index
		pos = texelFetch(distances, ivec2(index, 0), 0).xy;
		charge = texelFetch(charges, ivec2(index, 0), 0).x;
		dist = distance(pos, current_position);
		potential += 1000.0*charge/pow(dist, 2);
	}
	
	// Finally return the potential
	return potential;
}

/*
 * This will run for every vertex. We use it to pass the vertex position
 * into our position varying to later use it in the fragment stage
 */
void vertex() {
	position = VERTEX;
}

/*
 * This will run for every fragment that is rendered. We use it to fetch
 * the distance to the distances. We then calculate lines based on that.
 */
void fragment() {
	// Get the distance to the nearest potential
	float potential = getDistance(position);
	float floored_potential = potential - mod(potential, 1.0/64.0);
	COLOR.rgb = vec3(floored_potential + 0.5);
	
// Old code	
//	COLOR.rgb = vec3(potential < 1000.0 && potential > 200.0*0.7 ? 1.0 : 0.0);

//	int iter = 100;
//	float step_ = 10.0;
//	float start = 50.0;
//	for (int index=0; index<iter; index++) {
//		float potential_range = start - float(index)*step_;
//		COLOR.rgb += vec3(potential < potential_range && potential > potential_range*0.9 ? 1.0:0.0);
//	}	
}
