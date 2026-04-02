class_name Player
extends CharacterBody2D

## 跳躍初速（負值代表向上）
const JUMP_VELOCITY: float = -600.0

## 重力加速度
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	move_and_slide()


## 施加重力
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


## 處理跳躍輸入（鍵盤、滑鼠、觸控統一透過 Input Map）
func _handle_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		EventBus.player_jumped.emit()


## 玩家死亡，發送事件
func die() -> void:
	EventBus.player_died.emit()
