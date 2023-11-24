package live

import lld "core:container/intrusive/list"
import sa "core:container/small_array"
import "core:dynlib"
import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:mem"
import "core:time"
import "core:c/libc"

import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

gfx_ctx: ^GFX_Context
input_ctx: ^Input_Context
os_ctx: ^OS_Context
scene_ctx: ^Scene_Context
ui_ctx: ^UI_Context

main :: proc() {
	gfx_ctx = new(GFX_Context)
	input_ctx = new(Input_Context)
	os_ctx = new(OS_Context)
	scene_ctx = new(Scene_Context)
	ui_ctx = new(UI_Context)

	os_init(os_ctx)
	gfx_init(gfx_ctx)
	scene_init(scene_ctx)
	ui_init(ui_ctx)

	// high precision timer
	start_tick := time.tick_now()

	camera := transform_init()

	loop: for {
		if os_ctx.is_quit {
			break loop
		}

		duration := time.tick_since(start_tick)
		t := f32(time.duration_seconds(duration))

		event, event_ok := os_event_next()
		os_process_event(os_ctx, &event)

		// Camera
		proj := glm.mat4Ortho3d(0.0, DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT, 0.0, -1.0, 1.0)

		gfx_begin(DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT)

		gfx_draw_rect({-1, 0, 1, 1}, {1, 0, 0, 1})

		gfx_shader_bind(gfx_ctx.default_shader)
		model := transform_get_model_matrix(&camera)
		u_transform := proj * model
		gfx_shader_set_uniform_mat4(gfx_ctx.default_shader, "u_transform", &u_transform[0, 0])

		// gfx_shader_bind(gfx_ctx.default_shader)
		// for variant in gfx_next_command_iterator(gfx_ctx) {
		// 	switch cmd in variant {
		// 		case ^Command_Rect:
		// 		gfx_draw_rect({-1, 0, 1, 1}, {1, 0, 0, 1})

		// 		model := transform_get_model_matrix(&cmd.transform)
		// 		u_transform := proj * view * model
		// 		gfx_shader_set_uniform_mat4(gfx_ctx.default_shader, "u_transform", &u_transform[0, 0])
		// 	}
		// }

		gfx_flush()

		sdl.GL_MakeCurrent(os_ctx.root_window.handle, os_ctx.root_window.gl_ctx)
		os_window_flush(os_ctx.root_window)

		os_delay(1)
	}
}
