/*
  Today:
  - [/] добавить камеру
  - [/] graphics: добавить буферы
*/

package main

import gfx "live:gfx"
import input "live:input"
import os "live:os"
import ui "live:ui"

import lld "core:container/intrusive/list"
import sa "core:container/small_array"
import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:time"

import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

gfx_ctx: ^gfx.Context
input_ctx: ^input.Context
os_ctx: ^os.Context
ui_ctx: ^ui.Context

main :: proc() {
	gfx_ctx = new(gfx.Context)
	input_ctx = new(input.Context)
	os_ctx = new(os.Context)
	ui_ctx = new(ui.Context)

	os.init(os_ctx)
	gfx.init(gfx_ctx)
	ui.init(ui_ctx)

	// high precision timer
	start_tick := time.tick_now()

	loop: for {
		if os_ctx.is_quit {
			break loop
		}

		duration := time.tick_since(start_tick)
		t := f32(time.duration_seconds(duration))

		event, event_ok := os.event_next()
		os.process_event(os_ctx, &event)

		pos := gfx.Vector3{}
		model := glm.identity(glm.mat4)
		model *= glm.mat4Translate(pos)
		view := glm.mat4LookAt({0, 0, 4}, {0, 0, 0}, {0, 1, 0})
		proj := glm.mat4Perspective(
			45,
			os.DEFAULT_WINDOW_WIDTH / os.DEFAULT_WINDOW_HEIGHT,
			0.1,
			100.0,
		)
		u_transform := proj * view * model

		gfx.begin(os.DEFAULT_WINDOW_WIDTH, os.DEFAULT_WINDOW_HEIGHT)
		gfx.shader_bind(gfx_ctx.default_shader)
		gfx.shader_set_uniform_mat4(gfx_ctx.default_shader, "u_transform", &u_transform[0, 0])
		gfx.flush()

		it := lld.iterator_head(os_ctx.window_list.list, os.Window, "node")
		for window in lld.iterate_next(&it) {
			sdl.GL_MakeCurrent(window.handle, window.gl_ctx)
			os.window_flush(window)
		}

		os.delay(1)
	}
}
