package live

import fmt "core:fmt"

import mu "vendor:microui"
import sdl "vendor:sdl2"

UI_Context :: struct {
	mu_ctx:        ^mu.Context,
	bg:            mu.Color,
	atlas_texture: ^sdl.Texture,
}

ui_init :: proc(ctx: ^UI_Context) {
	ctx.mu_ctx = new(mu.Context);defer free(ctx.mu_ctx)
	ctx.bg = {90, 95, 100, 255}

	mu.init(ctx.mu_ctx)

	ctx.mu_ctx.text_width = mu.default_atlas_text_width
	ctx.mu_ctx.text_height = mu.default_atlas_text_height
}

ui_being :: proc(ctx: ^UI_Context) {
	mu.begin(ctx.mu_ctx)
}

ui_end :: proc(ctx: ^UI_Context) {
	mu.end(ctx.mu_ctx)

	command_backing: ^mu.Command
	for variant in mu.next_command_iterator(ctx.mu_ctx, &command_backing) {
		switch cmd in variant {
		case ^mu.Command_Text:
		// dst := sdl.Rect{cmd.pos.x, cmd.pos.y, 0, 0}
		// for ch in cmd.str do if ch & 0xc0 != 0x80 {
		// 	r := min(int(ch), 127)
		// 	src := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + r]
		// 	render_texture(ctx.renderer, &dst, src, cmd.color)
		// 	dst.x += dst.w
		// }
		case ^mu.Command_Rect:
		// sdl.SetRenderDrawColor(
		// 	ctx.renderer,
		// 	cmd.color.r,
		// 	cmd.color.g,
		// 	cmd.color.b,
		// 	cmd.color.a,
		// )
		// sdl.RenderFillRect(
		// 	ctx.renderer,
		// 	&sdl.Rect{cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h},
		// )
		case ^mu.Command_Icon:
		// src := mu.default_atlas[cmd.id]
		// x := cmd.rect.x + (cmd.rect.w - src.w) / 2
		// y := cmd.rect.y + (cmd.rect.h - src.h) / 2
		// render_texture(ctx.renderer, &sdl.Rect{x, y, 0, 0}, src, cmd.color)
		case ^mu.Command_Clip:
		// sdl.RenderSetClipRect(
		// 	ctx.renderer,
		// 	&sdl.Rect{cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h},
		// )
		case ^mu.Command_Jump:
		}
	}

	// sdl.RenderPresent(ctx.renderer)
}

ui_on_mouse_motion :: proc(ctx: ^UI_Context, motion: [2]f32) {}

ui_on_mouse_wheel :: proc(ctx: ^UI_Context, wheel: [2]f32) {}

ui_on_mouse_button :: proc(ctx: ^UI_Context, is_down: b32, code: Mouse_Button_Code) {}

ui_on_key :: proc(ctx: ^UI_Context, is_down: b32, code: sdl.Scancode) {}

ui_on_text_input :: proc(ctx: ^UI_Context, input: string) {}
