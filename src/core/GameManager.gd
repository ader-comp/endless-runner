class_name GameManagerClass
extends Node

enum GameState { MENU, PLAYING, DEAD }

## 目前遊戲狀態
var current_state: GameState = GameState.MENU

## 目前移動速度
var current_speed: float = Constants.INITIAL_SPEED

## 加速計時器
var _speed_timer: float = 0.0


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.player_died.connect(_on_player_died)
	EventBus.returned_to_menu.connect(_on_returned_to_menu)


func _process(delta: float) -> void:
	if current_state != GameState.PLAYING:
		return
	_update_speed(delta)


## 切換遊戲狀態
func change_state(new_state: GameState) -> void:
	current_state = new_state
	match new_state:
		GameState.MENU:
			_reset()
		GameState.PLAYING:
			_reset()
		GameState.DEAD:
			pass


## 隨時間增加速度
func _update_speed(delta: float) -> void:
	_speed_timer += delta
	if _speed_timer >= Constants.SPEED_INTERVAL:
		_speed_timer = 0.0
		current_speed = minf(current_speed + Constants.SPEED_INCREMENT, Constants.MAX_SPEED)


## 重置速度與計時器
func _reset() -> void:
	current_speed = Constants.INITIAL_SPEED
	_speed_timer = 0.0


func _on_game_started() -> void:
	change_state(GameState.PLAYING)


func _on_player_died() -> void:
	change_state(GameState.DEAD)


func _on_returned_to_menu() -> void:
	change_state(GameState.MENU)
