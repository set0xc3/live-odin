package live

import lld "core:container/intrusive/list"
import "core:fmt"

import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

GL_VERSION_MAJOR :: 3
GL_VERSION_MINOR :: 3

DEFAULT_WINDOW_WIDTH :: 1280
DEFAULT_WINDOW_HEIGHT :: 720

Mouse_Button_Code :: enum {
	UNKNOWN,
	LEFT,
	MIDDLE,
	RIGHT,
}

Window :: struct {
	node:     lld.Node,
	child:    lld.Node,
	handle:   ^sdl.Window,
	renderer: ^sdl.Renderer,
	gl_ctx:   sdl.GLContext,
	title:    string,
	size:     [2]i32,
	position: [2]i32,
}

Window_List :: struct {
	list: lld.List,
}

OS_Context :: struct {
	is_quit:     b32,
	window_list: Window_List,
}

os_init :: proc(ctx: ^OS_Context) {
	if err := sdl.Init({.VIDEO}); err != 0 {
		fmt.eprintln(err)
		return
	}

	sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, i32(sdl.GLprofile.CORE))
	sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, GL_VERSION_MAJOR)
	sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, GL_VERSION_MINOR)

	window := os_window_create(
		ctx,
		"Live",
		{sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED},
		{DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT},
	)

	// load the OpenGL procedures once an OpenGL context has been established
	gl.load_up_to(GL_VERSION_MAJOR, GL_VERSION_MINOR, sdl.gl_set_proc_address)
}

os_destroy :: proc(ctx: ^OS_Context) {
	sdl.Quit()
}

os_delay :: proc(ms: u32) {
	sdl.Delay(ms)
}

os_perf_counter :: proc() -> u64 {
	return sdl.GetPerformanceCounter()
}


os_perf_frequency :: proc() -> u64 {
	return sdl.GetPerformanceFrequency()
}

os_event_next :: proc() -> (out_event: sdl.Event, out_event_ok: b32) {
	out_event_ok = b32(sdl.PollEvent(&out_event))
	return
}

os_process_event :: proc(ctx: ^OS_Context, event: ^sdl.Event) {
	#partial switch event.type {
	case .QUIT:
		ctx.is_quit = true
	case .MOUSEMOTION:
	case .MOUSEBUTTONDOWN, .MOUSEBUTTONUP:
		is_pressed: b32
		is_pressed = event.button.state == sdl.PRESSED ? true : false
		code: Mouse_Button_Code

		switch event.button.button {
		case sdl.BUTTON_LEFT:
			code = .LEFT
		case sdl.BUTTON_MIDDLE:
			code = .MIDDLE
		case sdl.BUTTON_RIGHT:
			code = .RIGHT
		}
	case .KEYDOWN, .KEYUP:
		code := event.key.keysym.scancode
		state := b32(event.key.state)
	}
}

os_window_create :: proc(
	ctx: ^OS_Context,
	title: cstring,
	position: [2]i32,
	size: [2]i32,
) -> (
	out_window: ^Window,
) {
	out_window = new(Window)
	out_window.handle = sdl.CreateWindow(title, position.x, position.y, size.x, size.y, {.OPENGL})
	if out_window.handle == nil {
		fmt.eprintln("Failed to create window")
		free(out_window)
		return
	}

	backend_idx: i32 = -1
	if n := sdl.GetNumRenderDrivers(); n <= 0 {
		fmt.eprintln("No render drivers available")
		free(out_window)
		return
	} else {
		for i in 0 ..< n {
			info: sdl.RendererInfo
			if err := sdl.GetRenderDriverInfo(i, &info); err == 0 {
				// NOTE(bill): "direct3d" seems to not work correctly
				if info.name == "opengl" {
					backend_idx = i
					break
				}
			}
		}
	}

	out_window.renderer = sdl.CreateRenderer(
		out_window.handle,
		backend_idx,
		{.ACCELERATED, .PRESENTVSYNC},
	)

	if out_window.renderer == nil {
		fmt.eprintln("SDL.CreateRenderer:", sdl.GetError())
		free(out_window)
		return
	}

	out_window.gl_ctx = sdl.GL_CreateContext(out_window.handle)
	out_window.title = string(title)
	out_window.position = position
	out_window.size = size
	lld.push_back(&ctx.window_list.list, &out_window.node)
	return
}

os_window_destroy :: proc(window: ^Window) {
	if window != nil {
		sdl.GL_DeleteContext(window.gl_ctx)
		sdl.DestroyWindow(window.handle)
		free(window)
	}
}

os_window_flush :: proc(window: ^Window) {
	sdl.GL_SwapWindow(window.handle)
}
