class_name Player
extends CharacterBody2D

## 跳躍初速（負值代表向上）
const JUMP_VELOCITY: float = -600.0

## 重力加速度
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

## 場景指定的初始位置，用於重試時把玩家拉回原點
var _spawn_position: Vector2


func _ready() -> void:
	_spawn_position = position
	EventBus.game_started.connect(_on_game_started)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	move_and_slide()


## 施加重力
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


## 處理跳躍輸入（鍵盤、滑鼠、觸控統一透過 Input Map）
## 僅在 PLAYING 狀態才允許跳躍，避免菜單或 Game Over 時誤觸發
func _handle_jump() -> void:
	if GameManager.current_state != GameManagerClass.GameState.PLAYING:
		return
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		EventBus.player_jumped.emit()


## 遊戲開始 / 重試時重置位置與速度
func _on_game_started() -> void:
	position = _spawn_position
	velocity = Vector2.ZERO


## 玩家死亡，發送事件
func die() -> void:
	EventBus.player_died.emit()
