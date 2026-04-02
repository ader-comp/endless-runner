class_name Obstacle
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_move(delta)
	_check_off_screen()


## 從右向左移動，速度從 GameManager 取得
func _move(delta: float) -> void:
	position.x -= GameManager.current_speed * delta


## 離開畫面左側時自動釋放
func _check_off_screen() -> void:
	if position.x < -100.0:
		queue_free()


## 碰到 Player 時觸發死亡
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		EventBus.player_died.emit()
