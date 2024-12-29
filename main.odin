package main

import "core:fmt"
import rl "vendor:raylib"

// Constants
player_speed :: 400
gravity :: 2000
jump_speed :: 600
scale_factor :: 4


Animation_Name :: enum {
	Idle,
	Run,
}

Animation :: struct {
	texture:       rl.Texture2D,
	num_frames:    int,
	frame_timer:   f32,
	current_frame: int,
	frame_length:  f32,
	name:          Animation_Name,
}

update_animation :: proc(a: ^Animation) {
	a.frame_timer += rl.GetFrameTime()

	if a.frame_timer > a.frame_length {
		a.current_frame += 1
		a.frame_timer = 0

		if a.current_frame >= a.num_frames {
			a.current_frame = 0
		}
	}
}

draw_animation :: proc(a: Animation, pos: rl.Vector2, flip: bool) {
	current_anim_width := f32(a.texture.width)
	current_anim_height := f32(a.texture.height)

	player_run_source_frame_x := f32(a.current_frame) * current_anim_width

	draw_player_source := rl.Rectangle {
		x      = player_run_source_frame_x / f32(a.num_frames),
		y      = 0,
		width  = current_anim_width / f32(a.num_frames),
		height = current_anim_height,
	}

	if flip {
		draw_player_source.width *= -1
	}

	draw_player_dest := rl.Rectangle {
		x      = pos.x,
		y      = pos.y,
		width  = current_anim_width * scale_factor / f32(a.num_frames),
		height = current_anim_height * scale_factor,
	}

	rl.DrawTexturePro(a.texture, draw_player_source, draw_player_dest, 0, 0, rl.WHITE)
}

main :: proc() {
	rl.InitWindow(1280, 720, "My First Game")
	player_pos := rl.Vector2{640, 320}
	player_vel: rl.Vector2
	player_grounded: bool
	player_flip: bool

	player_run := Animation {
		texture      = rl.LoadTexture("assets/cat_run.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run,
	}

	player_idle := Animation {
		texture      = rl.LoadTexture("assets/cat_idle.png"),
		num_frames   = 2,
		frame_length = 0.5,
		name         = .Idle,
	}

	current_anim := player_idle

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground({110, 184, 168, 255})

		is_moving: bool

		// X-axis movement
		if rl.IsKeyDown(.A) && !rl.IsKeyDown(.D) {
			player_vel.x = -player_speed
			player_flip = true
			is_moving = true
		} else if rl.IsKeyDown(.D) && !rl.IsKeyDown(.A) {
			player_vel.x = player_speed
			player_flip = false
			is_moving = true
		} else {
			player_vel.x = 0
			is_moving = false
		}

		// Y-axis movement
		player_vel.y += gravity * rl.GetFrameTime()
		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_vel.y = -jump_speed
			player_grounded = false
		}

		// Update player position
		player_pos += player_vel * rl.GetFrameTime()

		// Clamp player position
		if player_pos.y > f32(rl.GetScreenHeight()) - 64 {
			player_pos.y = f32(rl.GetScreenHeight()) - 64
			player_grounded = true
		}

		if (current_anim.name != .Run && is_moving) {
			current_anim = player_run
		} else if (current_anim.name != .Idle && !is_moving) {
			current_anim = player_idle
		}

		update_animation(&current_anim)

		draw_animation(current_anim, player_pos, player_flip)


		rl.EndDrawing()
	}

	rl.CloseWindow()
}
