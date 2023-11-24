package live

/* 
if input.mouse_button_click(.LEFT) {}
*/

player: ^Entity

sandbox_init :: proc() {
	player = scene_entity_make(nil); defer scene_entity_delete(player)
}