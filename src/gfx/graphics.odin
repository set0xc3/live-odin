package live_graphics

import sa "core:container/small_array"
import fmt "core:fmt"
import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"

Rect :: struct {
	x, y: f32,
	w, h: f32,
}

Vector2 :: glm.vec2
Vector3 :: glm.vec3
Vector4 :: glm.vec4
Matrix4 :: glm.mat4
Quaternion :: glm.quat
Color :: glm.vec4

Transform :: struct {
	translation: Vector3,
	rotation:    Quaternion,
	scale:       Vector3,
}

Vertex :: struct {
	position: Vector3,
	color:    Vector4,
}

Shader :: struct {
	id:   u32,
	path: string,
}

Context :: struct {
	default_shader: ^Shader,
}

vao, vbo, ebo: u32

vertices: sa.Small_Array(1000, Vertex)
indices: sa.Small_Array(1000 * 6, u32)
draw_idx: u32


vertex_source := `#version 330 core

layout(location=0) in vec3 a_position;
layout(location=1) in vec4 a_color;

out vec4 v_color;

uniform mat4 u_transform;

void main() {
	gl_Position = u_transform * vec4(a_position, 1.0);
	v_color = a_color;
}
`

fragment_source := `#version 330 core

in vec4 v_color;
out vec4 o_color;
void main() {
	o_color = v_color;
}
`

init :: proc(ctx: ^Context) {
	// sa.resize(&vertices, 1000)
	// sa.resize(&indices, 1000 * 6)

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	// initialization of OpenGL buffers
	gl.GenBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices.data), nil, gl.DYNAMIC_DRAW)

	sa.append(&indices, 0, 1, 2, 2, 3, 0)
	sa.append(&indices, 0, 1, 2, 2, 3, 0)
	sa.append(&indices, 0, 1, 2, 2, 3, 0)
	sa.append(&indices, 0, 1, 2, 2, 3, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(indices.data), &indices.data, gl.STATIC_DRAW)

	gl.EnableVertexAttribArray(0)
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, position))
	gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, color))


	// Update vertex buffers

	{
		sa.append(
			&vertices,
			Vertex{{-1.0, +1.0, 0}, {1.0, 0.0, 0.0, 0.75}},
			Vertex{{-1.0, -1.0, 0}, {0.0, 0.0, 0.0, 0.75}},
			Vertex{{+1.0, -1.0, 0}, {0.0, 0.0, 0.0, 0.75}},
			Vertex{{+1.0, +1.0, 0}, {0.0, 0.0, 0.0, 0.75}},
		)
		gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
		gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices.data), &vertices.data, gl.DYNAMIC_DRAW)
	}
	{
		sa.append(
			&vertices,
			Vertex{{-1.0, +2.0, 0}, {1.0, 0.0, 0.0, 0.75}},
			Vertex{{-1.0, -2.0, 0}, {1.0, 1.0, 0.0, 0.75}},
			Vertex{{+1.0, -0.0, 0}, {0.0, 1.0, 0.0, 0.75}},
			Vertex{{+1.0, +0.0, 0}, {0.0, 0.0, 1.0, 0.75}},
		)
		gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
		gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices.data), &vertices.data, gl.DYNAMIC_DRAW)
	}

	gl.ClearColor(0.0, 0.0, 0.0, 0.0)

	ctx.default_shader = shader_create(vertex_source, fragment_source)
}

shader_create :: proc(vertex_source, fragment_source: string) -> (out_shader: ^Shader) {
	out_shader = new(Shader)
	program, program_ok := gl.load_shaders_source(vertex_source, fragment_source)
	if !program_ok {
		fmt.eprintln("Failed to create GLSL program")
		free(out_shader)
		return nil
	}
	out_shader.id = program
	return
}

shader_destroy :: proc(shader: ^Shader) {
	gl.DeleteProgram(shader.id)
	free(shader)
}

shader_bind :: proc(shader: ^Shader) {
	gl.UseProgram(shader.id)
}

shader_unbind :: proc(shader: ^Shader) {
	gl.UseProgram(0)
}

shader_set_uniform_mat4 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.UniformMatrix4fv(uniforms[uniform_str].location, 1, false, data)
}

shader_set_uniform_vec2 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.Uniform2fv(uniforms[uniform_str].location, 1, data)
}

shader_set_uniform_vec3 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.Uniform3fv(uniforms[uniform_str].location, 1, data)
}

shader_set_uniform_vec4 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.Uniform4fv(uniforms[uniform_str].location, 1, data)
}

begin :: proc(width, height: i32) {
	gl.Viewport(0, 0, width, height)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	// draw_rect({0, 0, 1, 1}, {1, 0, 0, 1})
	// draw_rect({1, 1, 1, 1}, {0, 1, 0, 1})
}

flush :: proc() {
	if draw_idx == 0 {
		// return
	}

	gl.BindVertexArray(vao)

	// Render the first quad
    // gl.DrawArrays(gl.QUADS, 0, 4);

    // Render the second quad
    // gl.DrawArrays(gl.QUADS, 4, 4);

	gl.DrawElements(gl.TRIANGLES, 12, gl.UNSIGNED_INT, nil)

	draw_idx = 0
}

push_quad :: proc(rect: Rect, color: Color) {
	if draw_idx == 1000 {
		flush()
	}

	vertex_idx := draw_idx * 6
	index_idx := draw_idx * 6

	x, y := rect.x, rect.y
	w, h := rect.w, rect.h

	// sa.set(&vertices, int(vertex_idx + 0), Vertex{{-x, -y, 0}, color})
	// sa.set(&vertices, int(vertex_idx + 1), Vertex{{x + w, -y, 0}, color})
	// sa.set(&vertices, int(vertex_idx + 2), Vertex{{-x, y + h, 0}, color})
	// sa.set(&vertices, int(vertex_idx + 3), Vertex{{x + w, y + h, 0}, color})

	sa.append(
		&vertices,
		Vertex{{x, y, 0}, color},
		Vertex{{x + w, y, 0}, color},
		Vertex{{x, y + h, 0}, color},
		Vertex{{x + w, y + h, 0}, color},
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		sa.cap(vertices) * size_of(vertices.data[0]),
		&vertices.data,
		gl.DYNAMIC_DRAW,
	)

	// sa.set(&indices, int(index_idx + 0), 0)
	// sa.set(&indices, int(index_idx + 1), 1)
	// sa.set(&indices, int(index_idx + 2), 2)
	// sa.set(&indices, int(index_idx + 3), 2)
	// sa.set(&indices, int(index_idx + 4), 3)
	// sa.set(&indices, int(index_idx + 5), 1)

	sa.append(&indices, 0, 1, 2, 2, 3, 1)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		sa.cap(indices) * size_of(indices.data[0]),
		&indices.data,
		gl.DYNAMIC_DRAW,
	)

	// fmt.println(sa.cap(vertices), sa.len(vertices))
	// fmt.println(sa.cap(indices), sa.len(indices))

	draw_idx += 1
}

draw_rect :: proc(rect: Rect, color: Color) {
	push_quad(rect, color)
}
