module tetris

import irishgreencitrus.raylibv as r
import constants
import rand

const bg_color := r.Color{ r: 0, g: 0, b: 0, a: 255 }

pub struct Tetris {
mut: 
	moving_shape Shape
	world_units []Unit
	shape_idx int
pub mut:
	game_over bool
	blocks_placed int
	score int
}

pub fn Tetris.new() Tetris {
	mut t := Tetris{}
	random_shape_idx := rand.int_in_range(0, shapes.len) or {
		println("error generating random")
		0
	}
	t.moving_shape = shapes[random_shape_idx]
	return t
}

pub fn (mut t Tetris) step() {
	if !t.moving_shape.step(t.world_units) {
		t.world_units << t.moving_shape.get_units_in_world_coords()

		t.shape_idx = (t.shape_idx + 1) % shapes.len
		t.moving_shape = shapes[t.shape_idx]
		t.blocks_placed += 1
		if t.moving_shape.overlaps_world_unit(t.world_units) {
			t.game_over = true
		}
	} else {
		t.check_remove_rows()
	}
}

pub fn (mut t Tetris) handle_input(input_x int, rotation_input bool) {
	t.moving_shape.try_move_x(input_x, t.world_units)
	if rotation_input {
		t.moving_shape.try_rotate(t.world_units)
	}
}

pub fn (mut t Tetris) check_remove_rows() {
	mut rows_to_remove := []int{}
	for i in 0 .. constants.game_height {
		mut amount := 0
		for u in t.world_units {
			if u.y == i {
				amount += 1
			}
		}
		if amount == constants.game_width {
			rows_to_remove << i
		}
	}
	for i := t.world_units.len - 1; i >= 0; i-- {
		u := t.world_units[i]
		if u.y !in rows_to_remove {
			continue
		}
		t.world_units.delete(i)
		t.score += 1
	}
	for mut u_to_lower in t.world_units {
		mut move_down := 0
		for row_y in rows_to_remove {
			if u_to_lower.y < row_y {
				move_down += 1
			}
		}
		u_to_lower.y += move_down
	}
}

pub fn (t Tetris) draw() {
	r.clear_background(bg_color)

	for u in t.world_units {
		r.draw_rectangle(u.x, u.y, 1, 1, u.color)
	}
	if !t.game_over {
		for u in t.moving_shape.get_units() {
			r.draw_rectangle(t.moving_shape.x + u.x, t.moving_shape.y + u.y, 1, 1, u.color)
		}
	}
}