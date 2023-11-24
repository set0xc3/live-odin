package live

import glm "core:math/linalg/glsl"

Vector2 :: glm.vec2
Vector3 :: glm.vec3
Vector4 :: glm.vec4
Matrix4 :: glm.mat4
Quaternion :: glm.quat
Color :: glm.vec4

Rect :: struct {
	x, y: f32,
	w, h: f32,
}

Vertex :: struct {
	position: Vector3,
	color:    Vector4,
}

Shader :: struct {
	id:   u32,
	path: string,
}

Texture :: struct {
	uuid: string,
}


Sprite :: struct {
	uuid: string,
	texture: ^Texture,
}
