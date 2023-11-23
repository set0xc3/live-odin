package live

import sdl "vendor:sdl2"

Input_Context :: struct {
	last_key_code:          [len(sdl.Scancode)]b32,
	curr_key_code:          [len(sdl.Scancode)]b32,
	last_mouse_button_code: [len(Mouse_Button_Code)]b32,
	curr_mouse_button_code: [len(Mouse_Button_Code)]b32,
	mouse_position:         [2]f32,
	mouse_wheel:            [2]f32,
}

input_begin :: proc(ctx: ^Input_Context) {
	ctx.last_key_code = ctx.curr_key_code
	ctx.last_mouse_button_code = ctx.curr_mouse_button_code
	ctx.mouse_wheel = 0
}

input_key_pressed :: proc(ctx: ^Input_Context, code: sdl.Scancode) -> b32 {
	return ctx.last_key_code[code] && ctx.curr_key_code[code]
}

input_key_down :: proc(ctx: ^Input_Context, code: sdl.Scancode) -> b32 {
	return !ctx.last_key_code[code] && ctx.curr_key_code[code]
}

input_key_up :: proc(ctx: ^Input_Context, code: sdl.Scancode) -> b32 {
	return ctx.last_key_code[code] && !ctx.curr_key_code[code]
}

input_mouse_button_pressed :: proc(ctx: ^Input_Context, code: Mouse_Button_Code) -> b32 {
	return ctx.last_mouse_button_code[code] && ctx.curr_mouse_button_code[code]
}

input_mouse_button_down :: proc(ctx: ^Input_Context, code: Mouse_Button_Code) -> b32 {
	return !ctx.last_mouse_button_code[code] && ctx.curr_mouse_button_code[code]
}

input_mouse_button_up :: proc(ctx: ^Input_Context, code: Mouse_Button_Code) -> b32 {
	return ctx.last_mouse_button_code[code] && !ctx.curr_mouse_button_code[code]
}
