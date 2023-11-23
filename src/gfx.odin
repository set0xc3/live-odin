package live

import sa "core:container/small_array"
import fmt "core:fmt"
import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"

GFX_Context :: struct {
	default_shader: ^Shader,
}

vao, vbo, ebo: u32

vertices: sa.Small_Array(1000, Vertex)
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

gfx_init :: proc(ctx: ^GFX_Context) {
	sa.resize(&vertices, 1000)

	gl.Enable(gl.DEPTH_TEST)

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.GenBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices.data), nil, gl.DYNAMIC_DRAW)

	gl.EnableVertexAttribArray(0)
	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, position))
	gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, color))

	gl.ClearColor(0.0, 0.0, 0.0, 0.0)

	ctx.default_shader = gfx_shader_create(vertex_source, fragment_source)
}

gfx_shader_create :: proc(vertex_source, fragment_source: string) -> (out_shader: ^Shader) {
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

gfx_shader_destroy :: proc(shader: ^Shader) {
	gl.DeleteProgram(shader.id)
	free(shader)
}

gfx_shader_bind :: proc(shader: ^Shader) {
	gl.UseProgram(shader.id)
}

gfx_shader_unbind :: proc(shader: ^Shader) {
	gl.UseProgram(0)
}

gfx_shader_set_uniform_mat4 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.UniformMatrix4fv(uniforms[uniform_str].location, 1, false, data)
}

gfx_shader_set_uniform_vec2 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.Uniform2fv(uniforms[uniform_str].location, 1, data)
}

gfx_shader_set_uniform_vec3 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.Uniform3fv(uniforms[uniform_str].location, 1, data)
}

gfx_shader_set_uniform_vec4 :: proc(shader: ^Shader, uniform_str: string, data: [^]f32) {
	uniforms := gl.get_uniforms_from_program(shader.id)
	gl.Uniform4fv(uniforms[uniform_str].location, 1, data)
}

gfx_begin :: proc(width, height: i32) {
	gl.Viewport(0, 0, width, height)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	// draw_rect({-1, 0, 1, 1}, {1, 0, 0, 1})
	gfx_draw_rect({0, 0, 1, 1}, {0, 1, 0, 1})
	// draw_rect({1, 0, 1, 1}, {0, 0, 1, 1})
}

gfx_flush :: proc() {
	if draw_idx == 0 {
		return
	}

	gl.BindVertexArray(vao)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(draw_idx * 6))

	draw_idx = 0
}

push_quad :: proc(rect: Rect, color: Color) {
	if draw_idx == 1000 {
		gfx_flush()
	}

	vertex_idx := draw_idx * 6

	x, y := rect.x, rect.y
	w, h := rect.w, rect.h

	sa.set(&vertices, int(vertex_idx + 0), Vertex{{-1.0, -1.0, 0.0}, color})
	sa.set(&vertices, int(vertex_idx + 1), Vertex{{1.0 + w, -1.0, 0.0}, color})
	sa.set(&vertices, int(vertex_idx + 2), Vertex{{-1.0, 1.0 + h, 0.0}, color})

	sa.set(&vertices, int(vertex_idx + 3), Vertex{{-1.0, 1.0 + h, 0.0}, color})
	sa.set(&vertices, int(vertex_idx + 4), Vertex{{1.0 + w, 1.0 + h, 0.0}, color})
	sa.set(&vertices, int(vertex_idx + 5), Vertex{{1.0 + w, -1.0, 0.0}, color})


	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		sa.cap(vertices) * size_of(vertices.data[0]),
		&vertices.data,
		gl.DYNAMIC_DRAW,
	)

	draw_idx += 1
}

gfx_draw_rect :: proc(rect: Rect, color: Color) {
	push_quad(rect, color)
}
