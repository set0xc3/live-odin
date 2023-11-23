package live

import sa "core:container/small_array"

Entity :: struct {
	uuid:      string,
	transform: Transform,
}

Scene_Context :: struct {
	entities: sa.Small_Array(1000, ^Entity),
}

scene_init :: proc(ctx: ^Scene_Context) {

}

scene_entity_create :: proc(ctx: ^Scene_Context) -> (entity: ^Entity) {
	entity = new(Entity)
	entity.uuid = uuid4_string(uuid4_generate())
	entity.transform = transform_init()
	sa.append(&ctx.entities, entity)
	return
}
