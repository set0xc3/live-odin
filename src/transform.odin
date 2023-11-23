package live

import linalg "core:math/linalg"
import glm "core:math/linalg/glsl"

Transform :: struct {
	parent:       ^Transform,
	position:     Vector3,
	rotation:     Quaternion,
	scale:        Vector3,
	local_matrix: Matrix4,
	is_dirty:     b32,
}

transform_init :: proc() -> (transform: Transform) {
	transform.scale = {1.0, 1.0, 1.0}
	transform.local_matrix = glm.identity(Matrix4)
	return
}

transform_get_model_matrix :: proc(transform: ^Transform) -> Matrix4 {
	if transform.is_dirty {
		translate := glm.mat4Translate(transform.position)
		rotate := glm.mat4FromQuat(transform.rotation)
		scale := glm.mat4Scale(transform.scale)
		transform.is_dirty = false
		return translate * rotate * scale
	}
	return transform.local_matrix
}

transform_get_world_matrix :: proc(transform: ^Transform) -> Matrix4 {
	local := transform_get_model_matrix(transform)
	if transform.parent != nil {
		parent := transform_get_world_matrix(transform.parent)
		return linalg.mul(local, parent)
	}
	return local
}

transform_set_parent :: proc(transform: ^Transform, parent: ^Transform) {
	transform.parent = parent
	transform.is_dirty = true
}

transform_set_position :: proc(transform: ^Transform, position: Vector3) {
	transform.position = position
	transform.is_dirty = true
}

transform_set_rotation :: proc(transform: ^Transform, rotation: Quaternion) {
	transform.rotation = rotation
	transform.is_dirty = true
}

transform_set_scale :: proc(transform: ^Transform, scale: Vector3) {
	transform.scale = scale
	transform.is_dirty = true
}

transform_translate :: proc(transform: ^Transform, translate: Vector3) {
	transform.position += translate
	transform.is_dirty = true
}

transform_rotate :: proc(transform: ^Transform, axis: Vector3, angle: f32) {
	transform.rotation = glm.quatAxisAngle(axis, linalg.to_radians(angle))
	transform.is_dirty = true
}

transform_scale :: proc(transform: ^Transform, scale: Vector3) {
	transform.scale += scale
	transform.is_dirty = true
}
