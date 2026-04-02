# Endless Runner — 技術規格書 (DEV)

## 技術棧

- **Engine**: Godot 4.x
- **語言**: GDScript
- **目標平台**: Web / Android / Steam (PC) / iOS
- **最低解析度**: 1280 x 720

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

- 系統間通訊**必須**透過 EventBus signal
- 禁止跨 Scene 使用 `get_node()`
- UI 只監聽 signal，不主動查詢遊戲狀態

## 核心常數 (Constants.gd)

| 常數 | 值 | 說明 |
|---|---|---|
| INITIAL_SPEED | 300.0 | 初始移動速度 (px/s) |
| MAX_SPEED | 800.0 | 最大移動速度 (px/s) |
| SPEED_INCREMENT | 30.0 | 每次加速增量 (px/s) |
| SPEED_INTERVAL | 10.0 | 加速間隔 (秒) |
| SCORE_MULTIPLIER | 10 | 分數倍率 |
| OBSTACLE_SPAWN_MIN_INTERVAL | 1.2 | 障礙物最短生成間隔 (秒) |
| OBSTACLE_SPAWN_MAX_INTERVAL | 2.5 | 障礙物最長生成間隔 (秒) |
| GROUND_Y | 500.0 | 地板 Y 座標 (px) |

## Signal 清單 (EventBus.gd)

```gdscript
signal game_started()
signal game_over(final_score: int)
signal score_changed(new_score: int)
signal player_died()
signal player_jumped()
signal obstacle_spawned(obstacle: Node)
```

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

- AutoLoad 順序：EventBus → GameManager → SaveSystem
- Input Map：`jump` action → Space + Mouse Left + Touchscreen Touch

---

### Step 2：場景建立 + 地板捲動 + Web export

**建立場景**：

- `scenes/main.tscn`：根節點 Node2D，包含 Camera2D、WorldGenerator、ScoreSystem

**地板實作**：

```text
方式：物件池（3-4 個 ColorRect + StaticBody2D）
尺寸：每塊寬度 = viewport_width + buffer
流程：
  1. 初始化時並排放置覆蓋畫面
  2. _process() 中每塊向左移動 current_speed * delta
  3. 當某塊完全離開左側 → 移到最右側銜接
Y 座標：Constants.GROUND_Y
```

**Web export 設定**：

```text
1. Editor → Project → Export → Add Preset → Web
2. 設定 Export Path
3. VRAM Texture Compression: ETC2
4. Export 產出: index.html + .wasm + .pck
5. 部署至 GitHub Pages 或靜態伺服器
```

**部署方式（擇一）**：

- GitHub Pages：將 build 推到 `gh-pages` branch
- 本地測試：`python -m http.server`（需 COOP/COEP headers）
- CI 自動部署：GitHub Actions export + deploy

---

### Step 3：角色顯示 + 跳躍

**建立場景**：

- `scenes/entities/player.tscn`：CharacterBody2D → CollisionShape2D + ColorRect

**物理參數**：

```text
gravity: ProjectSettings physics/2d/default_gravity (預設 980)
jump_velocity: -600.0
地板判定: is_on_floor()
```

**輸入處理**：

```gdscript
# 統一使用 Input Map，不直接判斷平台
if is_on_floor() and Input.is_action_just_pressed("jump"):
    velocity.y = JUMP_VELOCITY
```

**節點結構**：

```text
Player (CharacterBody2D)
├── CollisionShape2D (RectangleShape2D)
└── PlayerSprite (ColorRect, 藍色, 暫代)
```

---

### Step 4：障礙物生成 + 移動

**建立場景**：

- `scenes/entities/obstacle.tscn`：Area2D → CollisionShape2D + ColorRect

**兩種高度**：

| 類型 | Y 座標 | 用途 |
|---|---|---|
| 低障礙 | GROUND_Y | 地面障礙，需跳躍閃避 |
| 高障礙 | GROUND_Y - 80 | 高處障礙，需注意時機 |

**生成邏輯 (WorldGenerator.gd)**：

```text
生成 X：viewport_width + 100
間隔：randf_range(SPAWN_MIN, SPAWN_MAX)
Timer：one_shot 模式，timeout 後生成 + 重啟
回收：position.x < -100 時 queue_free()
```

**節點結構**：

```text
Obstacle (Area2D)
├── CollisionShape2D (RectangleShape2D)
└── ObstacleSprite (ColorRect, 紅色, 暫代)
```

---

### Step 5：碰撞 + 死亡判定

**碰撞設定**：

```text
Player: collision_layer = 1 (玩家層)
Obstacle: collision_mask = 1 (偵測玩家層)
觸發方式: Obstacle 的 body_entered signal
```

**死亡流程**：

```text
1. Obstacle.body_entered → 檢查是否為 Player
2. → EventBus.player_died.emit()
3. → GameManager.change_state(DEAD)
4. → WorldGenerator.stop_spawning()
5. → 地板停止捲動
6. → 畫面顯示 "Game Over"
```

**注意事項**：

- 死亡 signal 只 emit 一次，避免重複觸發
- DEAD 狀態下 Player 停止接受輸入

---

### Step 6：分數系統

**計算邏輯 (ScoreSystem.gd)**：

```text
PLAYING 狀態下：
  _elapsed += delta
  score = int(_elapsed) * SCORE_MULTIPLIER
  每當 score 變化 → EventBus.score_changed.emit(score)
```

**HUD 顯示**：

```text
監聽 score_changed → 更新 ScoreLabel.text
死亡時顯示最終分數
位置：畫面右上角
```

---

### Step 7：最高分存檔

**儲存格式**：

```json
{
  "high_score": 1250
}
```

**檔案路徑**：`user://save.json`

**各平台實際路徑**：

| 平台 | 路徑 |
|---|---|
| Windows | %APPDATA%/Godot/app_userdata/EndlessRunner/ |
| macOS | ~/Library/Application Support/Godot/app_userdata/EndlessRunner/ |
| Linux | ~/.local/share/godot/app_userdata/EndlessRunner/ |
| Android | 內部儲存空間 (app-specific) |
| iOS | Documents/ (app sandbox) |
| Web | IndexedDB |

**讀寫流程**：

```text
儲存: score > current_high → FileAccess.WRITE → JSON.stringify
讀取: FileAccess.READ → JSON.parse → 回傳 high_score，失敗回傳 0
```

---

### Step 8：主選單 + 重試流程

**建立場景**：

- `scenes/ui/main_menu.tscn`：CanvasLayer → VBoxContainer → StartButton + HighScoreLabel
- `scenes/ui/hud.tscn`：CanvasLayer → ScoreLabel + HighScoreLabel + GameOverPanel

**狀態流程**：

```text
MENU ──(game_started)──→ PLAYING ──(player_died)──→ DEAD
  ↑                                                   │
  └──────────(back_to_menu)────────────────────────────┘
                          ↓
                  (game_started = 重試)
```

**場景切換方式**：

```text
方式: 同場景內切換 CanvasLayer 可見性，不用 change_scene
MENU: MainMenu visible, HUD hidden
PLAYING: MainMenu hidden, HUD visible
DEAD: MainMenu hidden, HUD visible, GameOverPanel visible
```

**重試時清理**：

- 清除所有障礙物（WorldGenerator.stop_spawning 已處理）
- 重置 Player 位置
- 重置分數與速度

---

### Step 9：速度遞增 + 難度曲線

**速度公式**：

```text
每 SPEED_INTERVAL 秒: current_speed += SPEED_INCREMENT
上限: MAX_SPEED
影響範圍: 地板捲動、障礙物移動、生成間隔
```

**生成間隔隨速度調整**：

```text
speed_ratio = current_speed / MAX_SPEED
adjusted_min = lerp(SPAWN_MAX_INTERVAL, SPAWN_MIN_INTERVAL, speed_ratio)
adjusted_max = adjusted_min + 0.3
```

**速度同步**：

- 障礙物在 `_process()` 中讀取 `GameManager.current_speed`
- 地板捲動速度同樣讀取 `GameManager.current_speed`
- 不需額外 signal，直接讀取即可（唯一允許直接引用 GameManager 的地方）

---

### Step 10：Android export

**前置需求**：

- Android SDK (API 33+)
- JDK 17
- debug.keystore（Godot 可自動生成）

**Export 設定**：

```text
Preset: Android
Min SDK: 24
Target SDK: 33+
VRAM Texture Compression: ETC2
Screen Orientation: Landscape
```

**注意事項**：

- 觸控輸入已透過 Input Map 支援
- 測試不同螢幕比例（16:9, 18:9, 20:9）
- 注意效能：低階裝置可能需限制同時存在的障礙物數量

---

### Step 11：Steam build (PC)

**Export 設定**：

```text
Preset: Windows Desktop
Architecture: x86_64
Embed PCK: 是
```

**Steam 整合（選用）**：

```text
GodotSteam plugin 或 官方 Steamworks GDExtension
功能: 成就、排行榜（非必要，學習用途）
```

---

### Step 12：iOS export

**前置需求**：

- Mac + Xcode 15+
- Apple Developer Program 帳號
- Provisioning Profile + Signing Certificate

**Export 設定**：

```text
Preset: iOS
Bundle Identifier: com.adercomp.endlessrunner
Min iOS Version: 15.0
VRAM Texture Compression: ASTC
```

**注意事項**：

- Safe Area：避免 UI 被 notch / Dynamic Island 遮擋
- 觸控輸入：同 Android，透過 Input Map
- TestFlight：可用於內部測試分發
