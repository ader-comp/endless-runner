class_name HUD
extends CanvasLayer

## 分數顯示 Label（Step 2 時在場景中指定）
@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var retry_button: Button = $GameOverPanel/RetryButton


func _ready() -> void:
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.game_over.connect(_on_game_over)
	EventBus.game_started.connect(_on_game_started)
	retry_button.pressed.connect(_on_retry_pressed)
	_update_high_score()
	game_over_panel.visible = false


## 更新目前分數顯示
func _on_score_changed(new_score: int) -> void:
	score_label.text = str(new_score)


## 顯示最高分
func _update_high_score() -> void:
	high_score_label.text = "BEST: " + str(SaveSystem.load_high_score())


## 遊戲結束時顯示結果面板
func _on_game_over(final_score: int) -> void:
	_update_high_score()
	game_over_panel.visible = true


## 遊戲開始時隱藏結果面板
func _on_game_started() -> void:
	game_over_panel.visible = false
	score_label.text = "0"


## 重試按鈕：重新開始遊戲
func _on_retry_pressed() -> void:
	EventBus.game_started.emit()
