class_name WorldGenerator
extends Node

## 障礙物場景
@export var obstacle_scene: PackedScene

## 生成位置 X（畫面右側外）
var _spawn_x: float = 0.0

## 視窗寬度
var _viewport_width: float = 0.0

## 生成計時器
var _spawn_timer: Timer

## 地板磚塊池
var _ground_tiles: Array[StaticBody2D] = []


func _ready() -> void:
	_viewport_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	_spawn_x = _viewport_width + 100.0
	_setup_timer()
	_setup_ground()
	EventBus.game_started.connect(_on_game_started)
	EventBus.player_died.connect(_on_player_died)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManagerClass.GameState.PLAYING:
		return
	_scroll_ground(delta)


# === 地板系統 ===


## 建立地板物件池：用足夠的磚塊覆蓋畫面 + 一塊緩衝
func _setup_ground() -> void:
	var tile_count := ceili(_viewport_width / Constants.GROUND_TILE_WIDTH) + 2
	for i in tile_count:
		var tile := _create_ground_tile()
		tile.position = Vector2(
			i * Constants.GROUND_TILE_WIDTH,
			Constants.GROUND_Y
		)
		add_child(tile)
		_ground_tiles.append(tile)


## 建立單個地板磚塊（StaticBody2D + CollisionShape2D + ColorRect）
func _create_ground_tile() -> StaticBody2D:
	var body := StaticBody2D.new()

	var shape := RectangleShape2D.new()
	shape.size = Vector2(Constants.GROUND_TILE_WIDTH, Constants.GROUND_TILE_HEIGHT)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(Constants.GROUND_TILE_WIDTH / 2.0, Constants.GROUND_TILE_HEIGHT / 2.0)
	body.add_child(col)

	var rect := ColorRect.new()
	rect.color = Constants.GROUND_COLOR
	rect.size = Vector2(Constants.GROUND_TILE_WIDTH, Constants.GROUND_TILE_HEIGHT)
	body.add_child(rect)

	return body


## 捲動地板，超出畫面左側的磚塊回收到右側
func _scroll_ground(delta: float) -> void:
	var speed := GameManager.current_speed
	var rightmost_x := _find_rightmost_x()
	for tile in _ground_tiles:
		tile.position.x -= speed * delta
		if tile.position.x <= -Constants.GROUND_TILE_WIDTH:
			tile.position.x = rightmost_x + Constants.GROUND_TILE_WIDTH
			rightmost_x = tile.position.x


## 找出最右側磚塊的 X 座標
func _find_rightmost_x() -> float:
	var max_x := -INF
	for tile in _ground_tiles:
		if tile.position.x > max_x:
			max_x = tile.position.x
	return max_x


# === 障礙物系統 ===


## 建立生成用 Timer
func _setup_timer() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)


## 開始生成循環
func start_spawning() -> void:
	_start_next_timer()


## 停止生成並清除所有障礙物
func stop_spawning() -> void:
	_spawn_timer.stop()
	for child in get_children():
		if child is Obstacle:
			child.queue_free()


## 設定隨機間隔並啟動計時器
func _start_next_timer() -> void:
	var interval := randf_range(
		Constants.OBSTACLE_SPAWN_MIN_INTERVAL,
		Constants.OBSTACLE_SPAWN_MAX_INTERVAL
	)
	_spawn_timer.start(interval)


## 生成一個障礙物
func _spawn_obstacle() -> void:
	if obstacle_scene == null:
		return
	var obstacle: Obstacle = obstacle_scene.instantiate()
	var is_high := randf() > 0.5
	if is_high:
		obstacle.obstacle_type = Obstacle.Type.HIGH
		obstacle.position = Vector2(_spawn_x, Constants.GROUND_Y - Constants.OBSTACLE_HIGH_OFFSET_Y)
	else:
		obstacle.obstacle_type = Obstacle.Type.LOW
		obstacle.position = Vector2(_spawn_x, Constants.GROUND_Y)
	add_child(obstacle)
	EventBus.obstacle_spawned.emit(obstacle)


func _on_spawn_timer_timeout() -> void:
	if GameManager.current_state == GameManagerClass.GameState.PLAYING:
		_spawn_obstacle()
		_start_next_timer()


func _on_game_started() -> void:
	stop_spawning()
	start_spawning()


func _on_player_died() -> void:
	stop_spawning()
