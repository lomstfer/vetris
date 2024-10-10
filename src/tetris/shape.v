module tetris

import irishgreencitrus.raylibv as r
import constants
import math

const shape_color_1 := r.Color{ r: 255, g: 0, b: 0, a: 255 }
const shape_color_2 := r.Color{ r: 0, g: 255, b: 0, a: 255 }
const shape_color_3 := r.Color{ r: 0, g: 0, b: 255, a: 255 }

const shapes = [
	Shape.new(
		r.Color{ r: 0, g: 255, b: 255, a: 255 }, 
		[
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 3, y: 1}]
			[Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}, Unit{x: 1, y: 3}]
		]
	)
	Shape.new(
		r.Color{ r: 255, g: 255, b: 0, a: 255 }, 
		[
			[Unit{x: 1, y: 0}, Unit{x: 2, y: 0}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}]
		]
	)
	Shape.new(
		r.Color{ r: 255, g: 0, b: 255, a: 255 }, 
		[
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 2, y: 2}]
			[Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 0, y: 2}, Unit{x: 1, y: 2}]
			[Unit{x: 0, y: 0}, Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}]
			[Unit{x: 1, y: 0}, Unit{x: 2, y: 0}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}]
		]
	)
	Shape.new(
		r.Color{ r: 255, g: 128, b: 0, a: 255 }, 
		[
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 0, y: 2}]
			[Unit{x: 0, y: 0}, Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}]
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 2, y: 0}]
			[Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}, Unit{x: 2, y: 2}]
		]
	)
	Shape.new(
		r.Color{ r: 255, g: 0, b: 0, a: 255 }, 
		[
			[Unit{x: 0, y: 2}, Unit{x: 1, y: 2}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}]
			[Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 2, y: 2}]
			[Unit{x: 0, y: 2}, Unit{x: 1, y: 2}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}]
			[Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 2, y: 2}]
		]
	)
	Shape.new(
		r.Color{ r: 128, g: 0, b: 128, a: 255 }, 
		[
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 1, y: 2}]
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}]
			[Unit{x: 1, y: 0}, Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}]
			[Unit{x: 2, y: 1}, Unit{x: 1, y: 0}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}]
		]
	)
	Shape.new(
		r.Color{ r: 0, g: 255, b: 0, a: 255 }, 
		[
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}, Unit{x: 2, y: 2}]
			[Unit{x: 2, y: 0}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 1, y: 2}]
			[Unit{x: 0, y: 1}, Unit{x: 1, y: 1}, Unit{x: 1, y: 2}, Unit{x: 2, y: 2}]
			[Unit{x: 2, y: 0}, Unit{x: 1, y: 1}, Unit{x: 2, y: 1}, Unit{x: 1, y: 2}]
		]
	)
]

struct Shape {
	units [][]Unit
mut:
	x int
	y int
	rotation int // indicates which unit array to use
	last_step_grounded bool
}

pub fn Shape.new(color r.Color, units [][]Unit) Shape {
	mut s := Shape{units: units}
	s.x = int(constants.game_width / 2) - 2
	s.y = -4
	for mut uarr in s.units {
		for mut u in uarr {
			u.color = color
		}
	}
	return s
}

fn (mut s Shape) step(world_units []Unit) /* still moving */ bool {
	if s.can_move_down(world_units) {
		s.y += 1
		s.last_step_grounded = false
	} else {
		if s.last_step_grounded {
			return false
		}
		s.last_step_grounded = true
	}
	return true
}

fn (s Shape) get_units() []Unit {
	return s.units[s.rotation]
}

fn (mut s Shape) try_rotate(world_units []Unit) {
	prev_rot := s.rotation
	s.rotation = (s.rotation + 1) % s.units.len
	if s.is_outside_game_view() || s.overlaps_world_unit(world_units) {
		s.rotation = prev_rot
	}
}

fn (mut s Shape) can_move_down(world_units []Unit) bool {
	for u in s.get_units() {
		moved := s.y + u.y + 1
		if moved >= constants.game_height {
			return false
		}
		if pos_overlaps_world_unit(s.x + u.x, moved, world_units) {
			return false
		}
	}
	return true
}

fn (mut s Shape) try_move_x(translation_x int, world_units []Unit) {
	for u in s.get_units() {
		moved := s.x + translation_x + u.x
		if moved < 0 || moved >= constants.game_width {
			return
		}
		if pos_overlaps_world_unit(moved, s.y + u.y, world_units) {
			return
		}
	}
	
	s.x += translation_x
}

fn (mut s Shape) get_units_in_world_coords() []Unit {
	mut result := []Unit{}
	for u in s.get_units() {
		result << Unit{x: u.x + s.x, y: u.y + s.y, color: u.color}
	}
	return result
}

fn (s Shape) overlaps_world_unit(world_units []Unit) bool {
	for u in s.get_units() {
		for world_u in world_units {
			if s.x + u.x == world_u.x && s.y + u.y == world_u.y {
				return true
			}
		}
	}
	return false
}

fn (s Shape) is_outside_game_view() bool {
	for u in s.get_units() {
		if s.x + u.x < 0 || s.x + u.x >= constants.game_width || s.y + u.y >= constants.game_height {
			return true
		}
	}
	return false
}

fn pos_overlaps_world_unit(x int, y int, world_units []Unit) bool {
	for world_u in world_units {
		if x == world_u.x && y == world_u.y {
			return true
		}
	}
	return false
}