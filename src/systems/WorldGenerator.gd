class_name WorldGenerator
extends Node

## 障礙物場景（Step 2 時指定）
@export var obstacle_scene: PackedScene

## 生成位置 X（畫面右側外）
var _spawn_x: float = 0.0

## 生成計時器
var _spawn_timer: Timer


func _ready() -> void:
	_spawn_x = ProjectSettings.get_setting("display/window/size/viewport_width") + 100.0
	_setup_timer()
	EventBus.game_started.connect(_on_game_started)
	EventBus.player_died.connect(_on_player_died)


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
	var obstacle: Node = obstacle_scene.instantiate()
	## 隨機高低兩種位置
	var low_y: float = Constants.GROUND_Y
	var high_y: float = Constants.GROUND_Y - 80.0
	obstacle.position = Vector2(_spawn_x, [low_y, high_y].pick_random())
	add_child(obstacle)
	EventBus.obstacle_spawned.emit(obstacle)


func _on_spawn_timer_timeout() -> void:
	if GameManager.current_state == GameManagerClass.GameState.PLAYING:
		_spawn_obstacle()
		_start_next_timer()


func _on_game_started() -> void:
	start_spawning()


func _on_player_died() -> void:
	stop_spawning()
