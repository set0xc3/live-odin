/*
  Today:
  - [/] добавить камеру
  - [/] graphics: добавить буферы
*/

package live

import lld "core:container/intrusive/list"
import sa "core:container/small_array"
import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:time"

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

	gfx_init(gfx_ctx)
	os_init(os_ctx)
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

		// // Camera
		// view := glm.mat4LookAt({0, 0, 10}, {0, 0, 0}, {0, 1, 0})
		// proj := glm.mat4Perspective(
		// 	45,
		// 	DEFAULT_WINDOW_WIDTH / DEFAULT_WINDOW_HEIGHT,
		// 	0.1,
		// 	100.0,
		// )

		// for i := 0; i < entities.len; i += 1 {
		// 	model := transform_get_model_matrix(&entities.data[i].transform)

		// 	u_transform := proj * view * model

		// 	gfx_begin(DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT)
		// 	gfx_shader_bind(gfx_ctx.default_shader)
		// 	gfx_shader_set_uniform_mat4(gfx_ctx.default_shader, "u_transform", &u_transform[0, 0])
		// 	gfx_flush()
		// }

		// it := lld.iterator_head(os_ctx.window_list.list, Window, "node")
		// for window in lld.iterate_next(&it) {
		// 	sdl.GL_MakeCurrent(window.handle, window.gl_ctx)
		// 	os_window_flush(window)
		// }

		os_delay(1)
	}
}
