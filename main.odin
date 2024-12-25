package main

import "core:fmt"
import rl "vendor:raylib"

player_speed: f32 = 400
gravity: f32 = 2000
jump_speed: f32 = 600

main :: proc() {
	rl.InitWindow(1280, 720, "My First Game")

	player_pos := rl.Vector2{640, 320}
	player_vel: rl.Vector2
	player_grounded: bool


	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

		// X-axis movement
		if rl.IsKeyDown(.A) && !rl.IsKeyDown(.D) {
			player_vel.x = -player_speed
		} else if rl.IsKeyDown(.D) && !rl.IsKeyDown(.A) {
			player_vel.x = player_speed
		} else {
			player_vel.x = 0
		}

		// Y-axis movement
		player_vel.y += gravity * rl.GetFrameTime()
		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_vel.y = -jump_speed
			player_grounded = false
		}

		player_pos += player_vel * rl.GetFrameTime()

		if player_pos.y > f32(rl.GetScreenHeight()) - 64 {
			player_pos.y = f32(rl.GetScreenHeight()) - 64
			player_grounded = true
		}

		rl.DrawRectangleV(player_pos, {64, 64}, rl.GREEN)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}
