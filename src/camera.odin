package live

Camera :: struct {
	// attribures
	position:          Vector3,
	front:             Vector3,
	up:                Vector3,
	right:             Vector3,
	world_up:          Vector3,

	// euler angles
	yaw, pitch:        f32,

	// options
	movement_speed:    f32,
	mouse_sensitivity: f32,
	zoom:              f32,
}
