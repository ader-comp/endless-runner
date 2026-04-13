class_name MainMenu
extends CanvasLayer

## 開始按鈕（Step 2 時在場景中指定）
@onready var start_button: Button = $StartButton
@onready var high_score_label: Label = $HighScoreLabel


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	EventBus.game_started.connect(_on_game_started)
	_update_high_score()


## 顯示最高分
func _update_high_score() -> void:
	high_score_label.text = "BEST: " + str(SaveSystem.load_high_score())


## 按下開始按鈕，發送 game_started 事件
func _on_start_pressed() -> void:
	EventBus.game_started.emit()


## 遊戲開始時隱藏主選單（包含初次開始與 Retry）
func _on_game_started() -> void:
	visible = false
