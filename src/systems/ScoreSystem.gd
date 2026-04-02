class_name ScoreSystem
extends Node

## 目前分數
var _score: int = 0

## 累計時間（秒）
var _elapsed: float = 0.0


func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)
	EventBus.player_died.connect(_on_player_died)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManagerClass.GameState.PLAYING:
		return
	_update_score(delta)


## 每秒累加分數並發送更新事件
func _update_score(delta: float) -> void:
	_elapsed += delta
	var new_score: int = int(_elapsed) * Constants.SCORE_MULTIPLIER
	if new_score != _score:
		_score = new_score
		EventBus.score_changed.emit(_score)


## 重置分數
func _reset() -> void:
	_score = 0
	_elapsed = 0.0


func _on_game_started() -> void:
	_reset()


## 遊戲結束時儲存最高分
func _on_player_died() -> void:
	EventBus.game_over.emit(_score)
	SaveSystem.save_high_score(_score)
