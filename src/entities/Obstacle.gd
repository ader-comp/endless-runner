class_name Obstacle
extends Area2D

enum Type { LOW, HIGH }

var obstacle_type: Type = Type.LOW


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_visual()
	_setup_collision()


func _process(delta: float) -> void:
	if GameManager.current_state != GameManagerClass.GameState.PLAYING:
		return
	_move(delta)
	_check_off_screen()


## 根據類型設定 ColorRect 外觀
func _setup_visual() -> void:
	var size := _get_size()
	var rect := ColorRect.new()
	rect.color = Constants.OBSTACLE_COLOR
	rect.size = size
	rect.position = Vector2(-size.x / 2.0, -size.y)
	add_child(rect)


## 根據類型設定碰撞形狀
func _setup_collision() -> void:
	var size := _get_size()
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0.0, -size.y / 2.0)
	add_child(col)


func _get_size() -> Vector2:
	if obstacle_type == Type.HIGH:
		return Constants.OBSTACLE_HIGH_SIZE
	return Constants.OBSTACLE_LOW_SIZE


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
