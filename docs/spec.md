# Endless Runner — 技術規格書 (DEV)

## 技術棧

- **Engine**: Godot 4.x
- **語言**: GDScript
- **目標平台**: Web / Android / Steam (PC) / iOS
- **最低解析度**: 1280 x 720

## 給 C#/TS 開發者的 Godot 入門

### GDScript vs C#/TypeScript 語法對照

```gdscript
# === 變數宣告 ===
# TS: let speed: number = 300.0
# C#: float speed = 300.0f;
var speed: float = 300.0

# TS: const MAX: number = 800
# C#: const float MAX = 800f;
const MAX_SPEED: float = 800.0

# === 函式 ===
# TS: function jump(): void { }
# C#: void Jump() { }
func jump() -> void:
    pass

# === 型別檢查 ===
# TS: if (body instanceof Player)
# C#: if (body is Player)
if body is Player:
    pass

# === 字串格式化 ===
# TS: `Score: ${score}`
# C#: $"Score: {score}"
"Score: " + str(score)

# === 陣列 ===
# TS: let items: number[] = [1, 2, 3]
# C#: var items = new List<int> { 1, 2, 3 };
var items: Array[int] = [1, 2, 3]

# === 字典 ===
# TS: let data: Record<string, any> = { key: "value" }
# C#: var data = new Dictionary<string, object>();
var data: Dictionary = {"key": "value"}

# === 列舉 ===
# TS: enum State { Menu, Playing, Dead }
# C#: enum State { Menu, Playing, Dead }
enum State { MENU, PLAYING, DEAD }

# === null 檢查 ===
# TS: if (obj !== null)
# C#: if (obj != null)
if obj != null:
    pass
```

> 參考：[GDScript 官方文件](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)

### Godot 核心概念（對照 C#/TS 思維）

#### Node（節點）= 元件 (Component)

Godot 的一切都是 Node。Node 組成樹狀結構，類似 DOM tree 或 Unity 的 GameObject + Component。

```text
主場景 (Node2D)          ← 類似 HTML 的 <body> 或 Unity 的空 GameObject
├── Player (CharacterBody2D)  ← 有物理的角色
│   ├── CollisionShape2D      ← 碰撞範圍（像 CSS box model）
│   └── Sprite2D              ← 外觀（像 <img>）
├── WorldGenerator (Node)     ← 純邏輯節點（像 service class）
└── HUD (CanvasLayer)         ← UI 層（像 position: fixed 的 div）
```

> 參考：[Node 概念](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html)

#### Scene（場景）= Prefab / Reusable Component

一個 `.tscn` 檔案就是一個 Node 樹的模板，可以被實例化（instantiate）多次。

```gdscript
# 類似 TS: const enemy = new Enemy(); container.appendChild(enemy)
# 類似 C#: var enemy = Instantiate(enemyPrefab); enemy.transform.SetParent(container)
var obstacle = obstacle_scene.instantiate()
add_child(obstacle)
```

> 參考：[Scene 概念](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html#scenes)

#### Signal（信號）= Event / EventEmitter

Signal 是 Godot 的觀察者模式，類似 C# 的 `event` 或 TS 的 `EventEmitter`。

```gdscript
# --- 宣告 signal（類似 C# 的 event Action<int>）---
signal score_changed(new_score: int)

# --- 發送 signal（類似 C# 的 ScoreChanged?.Invoke(100)）---
score_changed.emit(100)

# --- 監聽 signal（類似 C# 的 obj.ScoreChanged += OnScoreChanged）---
EventBus.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
    label.text = str(new_score)
```

> 參考：[Signal 教學](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)

#### AutoLoad = 全域 Singleton

AutoLoad 的腳本會在遊戲啟動時自動載入，全域可用，類似 C# 的 `static` service 或 TS 的全域 module。

```gdscript
# 在任何腳本中直接使用，不需 import
GameManager.current_speed
EventBus.player_died.emit()
SaveSystem.save_high_score(100)
```

設定方式：Editor → Project → Project Settings → Globals → AutoLoad

> 參考：[AutoLoad 說明](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)

#### 生命週期函式（對照 Unity / React）

| GDScript | Unity 等價 | React 等價 | 何時呼叫 |
|---|---|---|---|
| `_ready()` | `Start()` | `useEffect(() => {}, [])` | 節點加入場景樹時，執行一次 |
| `_process(delta)` | `Update()` | `requestAnimationFrame` | 每一幀，用於遊戲邏輯與渲染 |
| `_physics_process(delta)` | `FixedUpdate()` | 無對應 | 固定物理幀率（預設 60fps），用於物理計算 |
| `_input(event)` | `OnGUI` 部分 | `addEventListener` | 有輸入事件時 |

> 參考：[Node 生命週期](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html)

#### @onready = 延遲初始化

```gdscript
# 類似 TS: this.label = document.querySelector('#score-label')
# 類似 C#: [SerializeField] Label label; (在 Awake 時自動綁定)
# @onready 會在 _ready() 之前自動取得子節點引用
@onready var score_label: Label = $ScoreLabel
```

`$ScoreLabel` 是 `get_node("ScoreLabel")` 的語法糖，透過節點名稱取得子節點。

> 參考：[@onready 說明](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#onready-annotation)

#### @export = Inspector 可編輯屬性

```gdscript
# 類似 C#: [SerializeField] PackedScene obstacleScene;
# 在 Godot Editor 的 Inspector 面板可以拖放指定
@export var obstacle_scene: PackedScene
```

> 參考：[@export 說明](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html)

### 常用 Node 類型速查

| Node 類型 | 用途 | 類比 |
|---|---|---|
| Node2D | 2D 基礎節點，有 position/rotation | HTML `<div>` with transform |
| CharacterBody2D | 有物理的可控制角色 | Unity CharacterController |
| StaticBody2D | 不會動的物理物體（地板、牆壁） | Unity BoxCollider (static) |
| Area2D | 偵測重疊但不阻擋移動（觸發器） | Unity Trigger Collider |
| CollisionShape2D | 定義碰撞範圍，搭配上述使用 | Unity Collider 的 shape |
| ColorRect | 純色矩形，常用於佔位 | HTML `<div>` with background-color |
| Label | 文字顯示 | HTML `<span>` |
| Button | 按鈕 | HTML `<button>` |
| CanvasLayer | 獨立渲染層，不受 Camera 影響 | CSS `position: fixed` 的容器 |
| Timer | 計時器，到時間觸發 signal | `setTimeout` / `setInterval` |
| Camera2D | 2D 攝影機 | 視口控制 |

> 參考：[Node 類型列表](https://docs.godotengine.org/en/stable/classes/index.html)

---

## 架構概述

```text
EventBus (AutoLoad)        ← 全域 Signal 中心
GameManager (AutoLoad)     ← 遊戲狀態機 + 速度管理
SaveSystem (AutoLoad)      ← 最高分持久化

Player (CharacterBody2D)   ← 重力 + 跳躍
Obstacle (Area2D)          ← 移動 + 碰撞
WorldGenerator (Node)      ← 地板循環 + 障礙物生成
ScoreSystem (Node)         ← 分數計算
HUD (CanvasLayer)          ← UI 顯示
MainMenu (CanvasLayer)     ← 開始畫面
```

### 通訊規則

```text
✅ 正確：透過 EventBus signal 通訊
  ScoreSystem → EventBus.score_changed.emit(100) → HUD 收到更新

❌ 錯誤：直接引用其他場景的節點
  var player = get_node("/root/Main/Player")  # 禁止！耦合太強
```

- 系統間通訊**必須**透過 EventBus signal
- 禁止跨 Scene 使用 `get_node()`
- UI 只監聽 signal，不主動查詢遊戲狀態
- 唯一例外：讀取 `GameManager.current_speed`（因為是每幀高頻讀取，用 signal 反而浪費效能）

## 核心常數 (Constants.gd)

| 常數 | 型別 | 值 | 說明 |
|---|---|---|---|
| INITIAL_SPEED | float | 300.0 | 初始移動速度 (px/s) |
| MAX_SPEED | float | 800.0 | 最大移動速度 (px/s) |
| SPEED_INCREMENT | float | 30.0 | 每次加速增量 (px/s) |
| SPEED_INTERVAL | float | 10.0 | 加速間隔 (秒) |
| SCORE_MULTIPLIER | int | 10 | 分數倍率 |
| OBSTACLE_SPAWN_MIN_INTERVAL | float | 1.2 | 障礙物最短生成間隔 (秒) |
| OBSTACLE_SPAWN_MAX_INTERVAL | float | 2.5 | 障礙物最長生成間隔 (秒) |
| GROUND_Y | float | 500.0 | 地板 Y 座標 (px) |

使用方式（任何腳本中直接引用）：

```gdscript
var speed = Constants.INITIAL_SPEED
```

## Signal 清單 (EventBus.gd)

```gdscript
signal game_started()                    # 遊戲開始（從選單或重試）
signal game_over(final_score: int)       # 遊戲結束，帶最終分數
signal score_changed(new_score: int)     # 分數更新
signal player_died()                     # 玩家死亡
signal player_jumped()                   # 玩家跳躍（音效/動畫用）
signal obstacle_spawned(obstacle: Node)  # 障礙物生成
```

Signal 流向圖：

```text
Player.die()
  → EventBus.player_died
    → GameManager.change_state(DEAD)
    → WorldGenerator.stop_spawning()
    → ScoreSystem._on_player_died()
      → EventBus.game_over(score)
        → HUD._on_game_over(score)
        → SaveSystem.save_high_score(score)
```

---

## 各 Step 技術實作細節

### Step 1：專案骨架建立

**狀態**：已完成

**檔案清單**：

| 檔案 | class_name | 繼承 | AutoLoad |
|---|---|---|---|
| src/core/Constants.gd | Constants | RefCounted | 否 |
| src/core/EventBus.gd | EventBusClass | Node | 是 |
| src/core/GameManager.gd | GameManagerClass | Node | 是 |
| src/core/SaveSystem.gd | SaveSystemClass | Node | 是 |
| src/entities/Player.gd | Player | CharacterBody2D | 否 |
| src/entities/Obstacle.gd | Obstacle | Area2D | 否 |
| src/systems/WorldGenerator.gd | WorldGenerator | Node | 否 |
| src/systems/ScoreSystem.gd | ScoreSystem | Node | 否 |
| src/ui/HUD.gd | HUD | CanvasLayer | 否 |
| src/ui/MainMenu.gd | MainMenu | CanvasLayer | 否 |

**Godot Editor 手動設定**：

AutoLoad 設定（**順序重要，EventBus 必須第一個**）：

1. Editor → Project → Project Settings → Globals → AutoLoad
2. 依序加入：

| 名稱 | 路徑 | 說明 |
|---|---|---|
| EventBus | `res://src/core/EventBus.gd` | 必須第一個，其他 AutoLoad 的 `_ready()` 會連接它 |
| GameManager | `res://src/core/GameManager.gd` | 第二個 |
| SaveSystem | `res://src/core/SaveSystem.gd` | 第三個 |

Input Map 設定：

1. Editor → Project → Project Settings → Input Map
2. 新增 `jump` action，加入以下輸入：

| 輸入類型 | 值 | 說明 |
|---|---|---|
| Key | Space | 鍵盤空白鍵 |
| Mouse Button | Left Button | 滑鼠左鍵 |
| Touchscreen | Touch | 手機觸控 |

> 參考：[Input Map 設定教學](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html#inputmap)

---

### Step 2：場景建立 + 地板捲動 + Web export

#### 2-1. 建立主場景

在 Editor 中：Scene → New Scene → 選 Node2D 為根節點 → 存為 `scenes/main.tscn`

**節點結構**：

```text
Main (Node2D)
├── Camera2D                  ← 攝影機，讓畫面固定
├── Ground (Node2D)           ← 地板容器
│   ├── GroundTile0 (StaticBody2D)  ← 地板塊 0
│   │   ├── CollisionShape2D        ← 碰撞範圍
│   │   └── ColorRect               ← 視覺外觀（綠色/棕色）
│   ├── GroundTile1 (StaticBody2D)  ← 地板塊 1
│   │   ├── CollisionShape2D
│   │   └── ColorRect
│   └── GroundTile2 (StaticBody2D)  ← 地板塊 2
│       ├── CollisionShape2D
│       └── ColorRect
├── WorldGenerator (Node)     ← 掛 WorldGenerator.gd
└── ScoreSystem (Node)        ← 掛 ScoreSystem.gd
```

#### 2-2. 地板物件池實作

地板由 3 塊 StaticBody2D 組成，循環複用（不會無限新增節點）。

**概念**（類似 TS 的虛擬滾動 / virtual scroll）：

```text
畫面寬度 1280px，每塊地板寬 1300px（加 buffer 防縫隙）

初始位置：
[Tile0: x=0] [Tile1: x=1300] [Tile2: x=2600]

每幀向左移動 speed * delta：
[Tile0: x=-50] [Tile1: x=1250] [Tile2: x=2550]

當 Tile0 完全離開左側（x < -1300）→ 搬到最右邊：
[Tile1: x=1250] [Tile2: x=2550] [Tile0: x=3850]
```

**程式碼範例**：

```gdscript
# 在 WorldGenerator.gd 或獨立的 GroundManager.gd 中

var ground_tiles: Array[StaticBody2D] = []
var tile_width: float = 1300.0

func _ready() -> void:
    # 取得所有地板塊的引用
    for i in range(3):
        var tile = get_node("../Ground/GroundTile" + str(i))
        tile.position.x = i * tile_width
        ground_tiles.append(tile)

func _process(delta: float) -> void:
    if GameManager.current_state != GameManagerClass.GameState.PLAYING:
        return
    for tile in ground_tiles:
        tile.position.x -= GameManager.current_speed * delta
        # 離開左側 → 搬到最右邊
        if tile.position.x < -tile_width:
            tile.position.x += tile_width * ground_tiles.size()
```

> 參考：[StaticBody2D](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html)

#### 2-3. Web export 設定

**步驟**：

1. 下載 Web export template：Editor → Editor → Manage Export Templates → Download
2. 新增 export preset：Editor → Project → Export → Add → Web
3. 設定：

| 設定項 | 值 | 說明 |
|---|---|---|
| Export Path | `build/web/index.html` | 輸出路徑 |
| VRAM Texture Compression | ETC2 | 相容性最好 |
| Head Include | 見下方 | COOP/COEP headers |

4. 點 Export Project 按鈕

**COOP/COEP headers**（Web 必需）：

Godot 4 的 Web export 需要 `SharedArrayBuffer`，瀏覽器要求以下 headers：

```text
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

**本地測試**（不能直接開 index.html，需要 HTTP server）：

```bash
# 方法 1：Python（最簡單，但沒有 COOP/COEP headers）
cd build/web && python -m http.server 8080

# 方法 2：npx serve（推薦，自帶正確 headers）
npx serve build/web --cors

# 方法 3：Godot 內建（Editor → Run → Run in Browser）
# 會自動啟動帶正確 headers 的 server
```

**部署至 GitHub Pages**：

```bash
# 建立 gh-pages branch，放入 build 檔案
git checkout --orphan gh-pages
git rm -rf .
# 複製 build/web/* 到根目錄
git add . && git commit -m "Deploy web build"
git push origin gh-pages
```

然後到 repo Settings → Pages → Source 選 `gh-pages` branch。

> 參考：[Godot Web Export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)

---

### Step 3：角色顯示 + 跳躍

#### 3-1. 建立玩家場景

Editor 中：Scene → New Scene → 選 Other Node → CharacterBody2D → 存為 `scenes/entities/player.tscn`

**節點結構**：

```text
Player (CharacterBody2D)        ← 掛 Player.gd
├── CollisionShape2D            ← Shape: RectangleShape2D (size: 40x60)
└── PlayerSprite (ColorRect)    ← Size: 40x60, Color: 藍色 #4444FF
```

**建立步驟**：

1. 選 Player 節點 → 在 Inspector 掛上 `src/entities/Player.gd`
2. 新增子節點 CollisionShape2D → Inspector → Shape → New RectangleShape2D → Size 設 `(40, 60)`
3. 新增子節點 ColorRect → 命名 `PlayerSprite` → Size 設 `(40, 60)` → Color 設藍色
4. 調整 ColorRect 的 position 讓它跟 CollisionShape2D 對齊（通常 `(-20, -60)`）

**注意**：ColorRect 的座標原點在左上角，CharacterBody2D 的座標原點在中心。需要用 offset 對齊。

#### 3-2. 物理與跳躍程式碼

```gdscript
# src/entities/Player.gd
class_name Player
extends CharacterBody2D

const JUMP_VELOCITY: float = -600.0  # 負值 = 向上（Godot Y 軸向下）

# 從 Project Settings 取得重力值（預設 980）
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
    # 施加重力（不在地板上時才加）
    if not is_on_floor():
        velocity.y += gravity * delta

    # 跳躍（在地板上 + 按下跳躍鍵）
    if is_on_floor() and Input.is_action_just_pressed("jump"):
        velocity.y = JUMP_VELOCITY
        EventBus.player_jumped.emit()

    # CharacterBody2D 內建函式，處理移動 + 碰撞
    move_and_slide()
```

**重要概念**：

- `_physics_process` vs `_process`：物理相關的邏輯（移動、碰撞）放 `_physics_process`，固定 60fps 執行。視覺相關的放 `_process`
- `move_and_slide()`：CharacterBody2D 的核心函式，自動處理碰撞滑動。呼叫後 `is_on_floor()` 才會更新
- Godot 的 Y 軸向下為正，所以跳躍用負值

> 參考：[CharacterBody2D 教學](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html)

#### 3-3. 將 Player 加入主場景

回到 `scenes/main.tscn`，把 `player.tscn` 拖進場景樹，或用右鍵 → Instantiate Child Scene。

設定 Player 的位置：`position = Vector2(200, GROUND_Y)`（地板左側偏上）。

---

### Step 4：障礙物生成 + 移動

#### 4-1. 建立障礙物場景

Editor 中：Scene → New Scene → 選 Other Node → Area2D → 存為 `scenes/entities/obstacle.tscn`

**節點結構**：

```text
Obstacle (Area2D)               ← 掛 Obstacle.gd
├── CollisionShape2D            ← Shape: RectangleShape2D (size: 30x50)
└── ObstacleSprite (ColorRect)  ← Size: 30x50, Color: 紅色 #FF4444
```

**為什麼用 Area2D 而不是 StaticBody2D？**

- Area2D 可以偵測重疊但不會阻擋移動
- 我們要的是「碰到就死」，不是「碰到被擋住」
- 類似 Unity 的 Trigger Collider

#### 4-2. 障礙物移動程式碼

```gdscript
# src/entities/Obstacle.gd
class_name Obstacle
extends Area2D

func _ready() -> void:
    # 連接碰撞 signal（Area2D 偵測到 CharacterBody2D 進入時觸發）
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    # 從右向左移動，速度從 GameManager 取得
    position.x -= GameManager.current_speed * delta

    # 離開畫面左側時自動回收（防止節點無限累積）
    if position.x < -100.0:
        queue_free()  # 類似 C# 的 Destroy(gameObject)

func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        EventBus.player_died.emit()
```

#### 4-3. WorldGenerator 生成邏輯

```gdscript
# src/systems/WorldGenerator.gd（重點部分）

@export var obstacle_scene: PackedScene  # 在 Inspector 拖入 obstacle.tscn

var _spawn_timer: Timer

func _ready() -> void:
    _spawn_timer = Timer.new()       # 程式碼建立 Timer（也可以在 Editor 建）
    _spawn_timer.one_shot = true     # 觸發一次就停，手動重啟（模擬隨機間隔）
    _spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    add_child(_spawn_timer)          # Timer 要加入場景樹才會運作

func start_spawning() -> void:
    var interval = randf_range(      # 類似 TS: Math.random() * (max - min) + min
        Constants.OBSTACLE_SPAWN_MIN_INTERVAL,
        Constants.OBSTACLE_SPAWN_MAX_INTERVAL
    )
    _spawn_timer.start(interval)

func _spawn_obstacle() -> void:
    var obstacle = obstacle_scene.instantiate()  # 從 .tscn 建立實例
    var viewport_w = get_viewport().get_visible_rect().size.x
    # 隨機高低兩種位置
    var y_positions = [Constants.GROUND_Y, Constants.GROUND_Y - 80.0]
    obstacle.position = Vector2(viewport_w + 100, y_positions.pick_random())
    add_child(obstacle)  # 加入場景樹才會顯示和運作
    EventBus.obstacle_spawned.emit(obstacle)

func _on_spawn_timer_timeout() -> void:
    if GameManager.current_state == GameManagerClass.GameState.PLAYING:
        _spawn_obstacle()
        start_spawning()  # 重新啟動（下一次隨機間隔）
```

**在 Editor 中設定 obstacle_scene**：

1. 選 WorldGenerator 節點
2. Inspector → Obstacle Scene → 拖入 `scenes/entities/obstacle.tscn`

> 參考：[Timer](https://docs.godotengine.org/en/stable/classes/class_timer.html)
> 參考：[Instantiating scenes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/instancing.html)

---

### Step 5：碰撞 + 死亡判定

#### 5-1. 碰撞層設定

Godot 的碰撞用 Layer（我在哪層）和 Mask（我偵測哪層）：

```text
# 類似概念：CSS z-index，但用於碰撞分組

Layer 1 = 玩家層
Layer 2 = 障礙物層（可選，目前用 Layer 1 即可）
```

| 節點 | collision_layer | collision_mask | 說明 |
|---|---|---|---|
| Player (CharacterBody2D) | 1 | 1 | 我在第 1 層，我偵測第 1 層 |
| Ground (StaticBody2D) | 1 | — | 我在第 1 層（讓 Player 踩到） |
| Obstacle (Area2D) | — | 1 | 我偵測第 1 層（偵測 Player） |

在 Editor 中設定：選節點 → Inspector → Collision → Layer / Mask 勾選對應的位元。

> 參考：[碰撞層與遮罩](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#collision-layers-and-masks)

#### 5-2. 死亡流程（Signal 連鎖）

```text
碰撞發生
  → Obstacle._on_body_entered(Player)
    → EventBus.player_died.emit()
      ├→ GameManager._on_player_died()     # 狀態切為 DEAD
      ├→ WorldGenerator._on_player_died()  # 停止生成 + 清除障礙物
      ├→ ScoreSystem._on_player_died()     # 發送 game_over + 存檔
      │   → EventBus.game_over.emit(score)
      │     └→ HUD._on_game_over(score)    # 顯示結果面板
      └→ Player 不再接受輸入（GameManager.current_state != PLAYING）
```

#### 5-3. 防止重複死亡觸發

```gdscript
# Obstacle.gd 中加入旗標
var _has_hit: bool = false

func _on_body_entered(body: Node2D) -> void:
    if _has_hit:
        return
    if body is Player:
        _has_hit = true
        EventBus.player_died.emit()
```

---

### Step 6：分數系統

#### 6-1. ScoreSystem 完整程式碼

```gdscript
# src/systems/ScoreSystem.gd
class_name ScoreSystem
extends Node

var _score: int = 0
var _elapsed: float = 0.0

func _ready() -> void:
    EventBus.game_started.connect(_on_game_started)
    EventBus.player_died.connect(_on_player_died)

func _process(delta: float) -> void:
    if GameManager.current_state != GameManagerClass.GameState.PLAYING:
        return
    _elapsed += delta
    var new_score: int = int(_elapsed) * Constants.SCORE_MULTIPLIER
    if new_score != _score:
        _score = new_score
        EventBus.score_changed.emit(_score)

func _on_game_started() -> void:
    _score = 0
    _elapsed = 0.0

func _on_player_died() -> void:
    EventBus.game_over.emit(_score)
    SaveSystem.save_high_score(_score)
```

#### 6-2. HUD 分數顯示

```gdscript
# src/ui/HUD.gd（分數相關部分）

# $ScoreLabel 是 get_node("ScoreLabel") 的語法糖
@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
    EventBus.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int) -> void:
    score_label.text = str(new_score)  # int → string 轉換
```

**HUD 節點結構**：

```text
HUD (CanvasLayer)             ← 掛 HUD.gd
├── ScoreLabel (Label)        ← 右上角，顯示即時分數
├── HighScoreLabel (Label)    ← 右上角，顯示最高分
└── GameOverPanel (Control)   ← 死亡後顯示的面板
    ├── FinalScoreLabel (Label)
    ├── RetryButton (Button)
    └── BackToMenuButton (Button)
```

> 參考：[CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html)
> 參考：[UI 教學](https://docs.godotengine.org/en/stable/tutorials/ui/index.html)

---

### Step 7：最高分存檔

#### 7-1. 檔案讀寫（對照 Node.js fs 模組）

```gdscript
# 類似 TS:
#   import fs from 'fs'
#   fs.writeFileSync('save.json', JSON.stringify(data))
#   const data = JSON.parse(fs.readFileSync('save.json', 'utf-8'))

# Godot 寫入
func save_high_score(score: int) -> void:
    var data = {"high_score": score}
    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
    # file 離開作用域自動關閉（類似 C# using）

# Godot 讀取
func load_high_score() -> int:
    if not FileAccess.file_exists("user://save.json"):
        return 0
    var file = FileAccess.open("user://save.json", FileAccess.READ)
    if not file:
        return 0
    var json = JSON.new()
    var error = json.parse(file.get_as_text())
    if error != OK:
        return 0
    var data = json.data
    if data is Dictionary and data.has("high_score"):
        return int(data["high_score"])
    return 0
```

#### 7-2. `user://` 路徑說明

`user://` 是 Godot 的虛擬路徑，自動對應各平台的 app 資料目錄：

| 平台 | 實際路徑 |
|---|---|
| Windows | `%APPDATA%/Godot/app_userdata/EndlessRunner/` |
| macOS | `~/Library/Application Support/Godot/app_userdata/EndlessRunner/` |
| Linux | `~/.local/share/godot/app_userdata/EndlessRunner/` |
| Android | 內部儲存空間 (app-specific) |
| iOS | Documents/ (app sandbox) |
| Web | IndexedDB（瀏覽器自動處理，重新整理不會遺失） |

**Debug 技巧**：Editor → Project → Open User Data Folder 可以看到實際路徑。

> 參考：[File paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)
> 參考：[FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html)

---

### Step 8：主選單 + 重試流程

#### 8-1. 場景結構

不使用 `change_scene()`，改用同一場景內切換 CanvasLayer 可見性。原因：避免場景切換時的狀態管理複雜度。

```text
Main (Node2D)
├── Camera2D
├── Ground
├── Player
├── WorldGenerator
├── ScoreSystem
├── MainMenu (CanvasLayer)     ← 遊戲開始前可見
│   ├── VBoxContainer
│   │   ├── TitleLabel
│   │   ├── StartButton
│   │   └── HighScoreLabel
└── HUD (CanvasLayer)          ← 遊戲中可見
    ├── ScoreLabel
    ├── HighScoreLabel
    └── GameOverPanel (Control) ← 死亡後可見
        ├── FinalScoreLabel
        ├── RetryButton
        └── BackToMenuButton
```

#### 8-2. 狀態切換邏輯

```gdscript
# 類似 TS 的 router 或 React 的條件渲染
# 根據 GameState 控制哪些 UI 可見

# GameManager.gd 中
func change_state(new_state: GameState) -> void:
    current_state = new_state
    match new_state:       # 類似 C# switch / TS switch
        GameState.MENU:
            _reset()
        GameState.PLAYING:
            _reset()
        GameState.DEAD:
            pass

# MainMenu.gd 中
func _on_start_pressed() -> void:
    EventBus.game_started.emit()
    # GameManager 收到後切為 PLAYING
    # MainMenu 自己隱藏，HUD 顯示
```

#### 8-3. 重試時需要重置的項目

```text
重試 (game_started emit) 時：
  GameManager: current_speed → INITIAL_SPEED, _speed_timer → 0
  ScoreSystem: _score → 0, _elapsed → 0
  WorldGenerator: 清除所有障礙物, 重新開始生成
  Player: position 重置到初始位置, velocity 歸零
  HUD: 分數歸零, GameOverPanel 隱藏
  地板: 重新開始捲動
```

---

### Step 9：速度遞增 + 難度曲線

#### 9-1. GameManager 速度更新

```gdscript
# src/core/GameManager.gd（速度相關部分）

func _process(delta: float) -> void:
    if current_state != GameState.PLAYING:
        return
    _speed_timer += delta
    if _speed_timer >= Constants.SPEED_INTERVAL:
        _speed_timer = 0.0
        # minf = float 版的 min()，確保不超過上限
        current_speed = minf(
            current_speed + Constants.SPEED_INCREMENT,
            Constants.MAX_SPEED
        )
```

#### 9-2. 障礙物生成間隔隨速度調整

```gdscript
# WorldGenerator.gd 中修改 start_spawning

func _start_next_timer() -> void:
    # 速度越快 → 間隔越短 → 障礙物越密集
    var speed_ratio = GameManager.current_speed / Constants.MAX_SPEED
    # lerp(a, b, t): 線性插值，t=0 回傳 a，t=1 回傳 b
    # 速度慢時用 MAX_INTERVAL（間隔長），速度快時用 MIN_INTERVAL（間隔短）
    var adjusted_min = lerpf(
        Constants.OBSTACLE_SPAWN_MAX_INTERVAL,
        Constants.OBSTACLE_SPAWN_MIN_INTERVAL,
        speed_ratio
    )
    var adjusted_max = adjusted_min + 0.3
    _spawn_timer.start(randf_range(adjusted_min, adjusted_max))
```

#### 9-3. 速度影響範圍

所有讀取 `GameManager.current_speed` 的地方會自動受影響：

- 地板捲動速度
- 障礙物移動速度
- 障礙物生成間隔（需額外實作，如上）

不需要額外 signal 或事件。

> 參考：[lerp 說明](https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#class-globalscope-method-lerpf)

---

### Step 10：Android export

#### 10-1. 前置環境安裝

| 工具 | 版本 | 下載 |
|---|---|---|
| Android SDK | API 33+ | [Android Studio](https://developer.android.com/studio) 安裝後自帶 |
| JDK | 17 | [Adoptium](https://adoptium.net/) |
| debug.keystore | — | Godot 可自動生成，或用 `keytool` 指令 |

#### 10-2. Godot 設定

1. Editor → Editor Settings → Export → Android：設定 SDK 路徑和 JDK 路徑
2. Project → Export → Add → Android

| 設定項 | 值 |
|---|---|
| Min SDK | 24 |
| Target SDK | 33+ |
| VRAM Texture Compression | ETC2 |
| Screen Orientation | Landscape |
| Package Unique Name | `com.adercomp.endlessrunner` |

3. Export → 產出 `.apk` 檔案

#### 10-3. 注意事項

- **觸控**：Input Map 已包含 Touchscreen Touch，不需額外處理
- **螢幕比例**：Project Settings → Display → Window → Stretch → Mode 設為 `canvas_items`，Aspect 設為 `keep`
- **效能**：手機 GPU 較弱，同時存在的障礙物建議不超過 10 個

> 參考：[Android Export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)

---

### Step 11：Steam build (PC)

#### 11-1. Export 設定

1. Project → Export → Add → Windows Desktop

| 設定項 | 值 |
|---|---|
| Architecture | x86_64 |
| Embed PCK | 是（單一 .exe 檔案） |

2. Export → 產出 `.exe` 檔案

#### 11-2. Steam 整合（選用）

如果要加入 Steam 功能（成就、排行榜）：

| 方案 | 連結 |
|---|---|
| GodotSteam (GDExtension) | [github.com/GodotSteam/GodotSteam](https://github.com/GodotSteam/GodotSteam) |
| 官方文件 | [Steamworks 文件](https://partner.steamgames.com/doc/home) |

非必要功能，學習用途可跳過。

> 參考：[Windows Export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html)

---

### Step 12：iOS export

#### 12-1. 前置需求

| 工具 | 版本 | 說明 |
|---|---|---|
| Mac | — | **必須**，iOS build 只能在 macOS 上執行 |
| Xcode | 15+ | App Store 免費下載 |
| Apple Developer Program | — | $99/年，需要才能上機測試和上架 |
| Provisioning Profile | — | 在 Apple Developer Portal 建立 |

#### 12-2. Export 設定

1. Project → Export → Add → iOS

| 設定項 | 值 |
|---|---|
| Bundle Identifier | `com.adercomp.endlessrunner` |
| Min iOS Version | 15.0 |
| VRAM Texture Compression | ASTC |

2. Export → 產出 Xcode 專案 → 在 Xcode 開啟 → Build 到實機

#### 12-3. 注意事項

- **Safe Area**：iPhone 的 notch / Dynamic Island 會遮擋上方區域，UI 需避開
- **觸控**：同 Android，透過 Input Map
- **測試分發**：透過 TestFlight 給 QA 測試

> 參考：[iOS Export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)

---

## 推薦學習資源

### 官方文件（最重要）

| 資源 | 網址 |
|---|---|
| GDScript 語法 | [docs.godotengine.org/en/stable/tutorials/scripting/gdscript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) |
| Your First 2D Game | [docs.godotengine.org/en/stable/getting_started/first_2d_game](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html) |
| 節點與場景 | [docs.godotengine.org/en/stable/getting_started/step_by_step](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html) |
| Signal 教學 | [docs.godotengine.org/en/stable/getting_started/step_by_step/signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html) |
| 2D 物理 | [docs.godotengine.org/en/stable/tutorials/physics](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) |
| Export 總覽 | [docs.godotengine.org/en/stable/tutorials/export](https://docs.godotengine.org/en/stable/tutorials/export/index.html) |

### YouTube 教學

| 頻道 | 推薦原因 |
|---|---|
| Brackeys | Godot 4 入門系列，節奏快品質高 |
| GDQuest | Godot 專門頻道，有系統化教學 |
| HeartBeast | 2D 遊戲開發教學，適合本專案類型 |

### 從 C#/TS 轉 GDScript 特別注意

| 踩坑點 | 說明 |
|---|---|
| 沒有 `null safety` | GDScript 沒有 TS 的 strictNullChecks，注意 null 檢查 |
| 縮排語法 | 類似 Python，用 tab 縮排，不能混用 space |
| 沒有 `interface` | 用 `class_name` + 鴨子型別（duck typing）替代 |
| 沒有 `async/await` | 用 Signal + `await` 關鍵字替代（跟 TS 的 await 不同） |
| `self` vs `this` | GDScript 用 `self`（通常可省略，跟 Python 一樣） |
| 陣列方法不同 | 沒有 `.map()` `.filter()`，用 `for` 迴圈替代 |
| 型別是可選的 | 建議加上型別註記（`: int`, `: String`）方便 IDE 提示 |
