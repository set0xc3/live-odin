package live_input

import os "live:os"

import sdl "vendor:sdl2"

Context :: struct {
	last_key_code:          [len(sdl.Scancode)]b32,
	curr_key_code:          [len(sdl.Scancode)]b32,
	last_mouse_button_code: [len(os.Mouse_Button_Code)]b32,
	curr_mouse_button_code: [len(os.Mouse_Button_Code)]b32,
	mouse_position:         [2]f32,
	mouse_wheel:            [2]f32,
}

begin :: proc(ctx: ^Context) {
	ctx.last_key_code = ctx.curr_key_code
	ctx.last_mouse_button_code = ctx.curr_mouse_button_code
	ctx.mouse_wheel = 0
}

key_pressed :: proc(ctx: ^Context, code: sdl.Scancode) -> b32 {
	return ctx.last_key_code[code] && ctx.curr_key_code[code]
}

key_down :: proc(ctx: ^Context, code: sdl.Scancode) -> b32 {
	return !ctx.last_key_code[code] && ctx.curr_key_code[code]
}

key_up :: proc(ctx: ^Context, code: sdl.Scancode) -> b32 {
	return ctx.last_key_code[code] && !ctx.curr_key_code[code]
}

mouse_button_pressed :: proc(ctx: ^Context, code: os.Mouse_Button_Code) -> b32 {
	return ctx.last_mouse_button_code[code] && ctx.curr_mouse_button_code[code]
}

mouse_button_down :: proc(ctx: ^Context, code: os.Mouse_Button_Code) -> b32 {
	return !ctx.last_mouse_button_code[code] && ctx.curr_mouse_button_code[code]
}

mouse_button_up :: proc(ctx: ^Context, code: os.Mouse_Button_Code) -> b32 {
	return ctx.last_mouse_button_code[code] && !ctx.curr_mouse_button_code[code]
}
