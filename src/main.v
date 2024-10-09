module main

import irishgreencitrus.raylibv as r
import constants
import tetris

const bg_color = r.Color{ r: 40, g: 40, b: 60, a: 255 }
const start_screen_width = 800
const start_screen_height = 600

fn main() {
	r.set_config_flags(r.flag_window_resizable)
	r.init_window(start_screen_width, start_screen_height, 'vetris'.str)
	r.set_target_fps(60)

	mut game_step_interval_mul := 1.0
	mut step_accumulator := 0.0

	tetris_target := r.load_render_texture(constants.game_width, constants.game_height)

	mut tetris_game := tetris.Tetris.new()

	for !r.window_should_close() {
		screen_width, screen_height := r.get_screen_width(), r.get_screen_height()
		
		dt := r.get_frame_time()

		if !tetris_game.game_over {
			mut input := 0
			if r.is_key_pressed(r.key_left) {
				input -= 1
			}
			if r.is_key_pressed(r.key_right) {
				input += 1
			}
			tetris_game.handle_input(input, r.is_key_pressed(r.key_x))

			if r.is_key_down(r.key_down) {
				game_step_interval_mul = 0.1
			} else {
				game_step_interval_mul = 1
			}
			step_accumulator += dt
			for step_accumulator > 0 {
				step_accumulator -= constants.game_start_step_interval * game_step_interval_mul * 1.0 / (f32(tetris_game.blocks_placed) * constants.game_acceleration_magic_number + 1.0)
				tetris_game.step()
			}

			r.begin_texture_mode(tetris_target)
			tetris_game.draw()
			r.end_texture_mode()
		}

		if tetris_game.game_over {
			if r.is_key_pressed(r.key_enter) {
				tetris_game = tetris.Tetris.new()
			}
		}

		r.begin_drawing()
		r.clear_background(bg_color)
		
		dst_width := tetris_target.texture.width * screen_height / f32(tetris_target.texture.height)
		dst_height := screen_height
		r.draw_texture_pro(
			r.Texture2D(tetris_target.texture), 
			r.Rectangle{0.0, 0.0, tetris_target.texture.width, f32(-tetris_target.texture.height)},
			r.Rectangle{screen_width / 2 - dst_width / 2, 0.0, dst_width, dst_height},
			r.Vector2{0, 0},
			0,
			r.Color{ r: 255, g: 255, b: 255, a: 255 }
			)

		r.draw_text('score: ${tetris_game.score}'.str, 0, 0, 40, r.Color{r: 255, g: 255, b: 255, a: 255})

		if tetris_game.game_over {
			width := r.measure_text('GAME OVER'.str, 100)
			r.draw_text('GAME OVER'.str, screen_width / 2 - width / 2, screen_height / 5, 100, r.Color{r: 255, g: 255, b: 255, a: 255})
		}

		r.end_drawing()
	}
	r.close_window()
}