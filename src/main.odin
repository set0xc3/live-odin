package live

import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

os_ctx: ^OS_Context

main :: proc() {
	os_ctx = new(OS_Context)

	os_init(os_ctx)

	camera := transform_init()

	loop: for {
		if os_ctx.is_quit {
			break loop
		}

		event, event_ok := os_event_next()
		os_process_event(os_ctx, &event)

		// os_gl_begin_render(os_ctx)
		// os_gl_end_render(os_ctx)

		os_delay(1)
	}
}
