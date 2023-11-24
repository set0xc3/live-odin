package live

import sa "core:container/small_array"

Entity :: struct {
	uuid:      string,
	name:      string,
	transform: Transform,
	sprite:    ^Sprite,
}

Scene_Context :: struct {
	entities: sa.Small_Array(1000, ^Entity),
}

scene_init :: proc(ctx: ^Scene_Context) {

}

scene_destroy :: proc(ctx: ^Scene_Context) {

}

scene_update :: proc(ctx: ^Scene_Context, t: f32) {

}

scene_entity_make :: proc(ctx: ^Scene_Context) -> (entity: ^Entity) {
	entity = new(Entity)
	entity.uuid = uuid4_string(uuid4_generate())
	entity.name = "Entity"
	entity.transform = transform_init()
	sa.append(&ctx.entities, entity)
	return
}

scene_entity_delete :: proc(entity: ^Entity) {
}
