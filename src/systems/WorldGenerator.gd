class_name WorldGenerator
extends Node

## 障礙物場景
@export var obstacle_scene: PackedScene

## 生成位置 X（畫面右側外）
var _spawn_x: float = 0.0

## 生成計時器
var _spawn_timer: Timer

## 地板磚塊池
var _ground_tiles: Array[StaticBody2D] = []


func _ready() -> void:
	_setup_timer()
	_setup_ground()
	get_viewport().size_changed.connect(_on_viewport_resized)
	EventBus.game_started.connect(_on_game_started)
	EventBus.player_died.connect(_on_player_died)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManagerClass.GameState.PLAYING:
		return
	_scroll_ground(delta)


# === 地板系統 ===


## 依目前可視範圍建立地板，並同步生成 X
func _setup_ground() -> void:
	_refresh_spawn_x()
	_ensure_ground_coverage()


## 確保地板涵蓋 [可視左緣 - 一塊, 可視右緣 + 一塊]，缺則補
func _ensure_ground_coverage() -> void:
	var bounds := _get_visible_bounds_x()
	var needed_left := bounds.x - Constants.GROUND_TILE_WIDTH
	var needed_right := bounds.y + Constants.GROUND_TILE_WIDTH
	if _ground_tiles.is_empty():
		var start_x: float = floor(needed_left / Constants.GROUND_TILE_WIDTH) * Constants.GROUND_TILE_WIDTH
		var x := start_x
		while x <= needed_right:
			_add_ground_tile(x)
			x += Constants.GROUND_TILE_WIDTH
		return
	while _find_rightmost_x() < needed_right:
		_add_ground_tile(_find_rightmost_x() + Constants.GROUND_TILE_WIDTH)
	while _find_leftmost_x() > needed_left:
		_add_ground_tile(_find_leftmost_x() - Constants.GROUND_TILE_WIDTH)


## 在指定 X 新增一塊地板磚塊到池中
func _add_ground_tile(x: float) -> void:
	var tile := _create_ground_tile()
	tile.position = Vector2(x, Constants.GROUND_Y)
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


## 捲動地板，超出可視左側緩衝的磚塊回收到最右側
func _scroll_ground(delta: float) -> void:
	var speed := GameManager.current_speed
	var recycle_threshold := _get_visible_bounds_x().x - Constants.GROUND_TILE_WIDTH
	var rightmost_x := _find_rightmost_x()
	for tile in _ground_tiles:
		tile.position.x -= speed * delta
		if tile.position.x <= recycle_threshold:
			tile.position.x = rightmost_x + Constants.GROUND_TILE_WIDTH
			rightmost_x = tile.position.x


## 找出最右側磚塊的 X 座標
func _find_rightmost_x() -> float:
	var max_x := -INF
	for tile in _ground_tiles:
		if tile.position.x > max_x:
			max_x = tile.position.x
	return max_x


## 找出最左側磚塊的 X 座標
func _find_leftmost_x() -> float:
	var min_x := INF
	for tile in _ground_tiles:
		if tile.position.x < min_x:
			min_x = tile.position.x
	return min_x


## 回傳相機可視的 X 範圍（x=左緣, y=右緣）
func _get_visible_bounds_x() -> Vector2:
	var visible_size := get_viewport().get_visible_rect().size
	var camera := get_viewport().get_camera_2d()
	var camera_x: float = camera.position.x if camera else visible_size.x / 2.0
	var half: float = visible_size.x / 2.0
	return Vector2(camera_x - half, camera_x + half)


## 更新障礙物生成 X 為目前可視右緣 + 緩衝
func _refresh_spawn_x() -> void:
	_spawn_x = _get_visible_bounds_x().y + 100.0


## 視窗尺寸變動時，補足邊界磚塊與生成位置
func _on_viewport_resized() -> void:
	_refresh_spawn_x()
	_ensure_ground_coverage()


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
