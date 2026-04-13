# Endless Runner — Claude Code 專案說明

## 專案目標
這是一個「跨平台踩坑學習專案」，目的是熟悉 Godot 4 在 Web / iOS / Android / Steam 四平台的開發流程與技術差異。銷售不是重點，學習才是。

## 技術棧
- Engine: Godot 4.x (GDScript)
- 目標平台: Web / iOS / Android / Steam (PC)
- 測試框架: Godot 內建 + Web 用瀏覽器 DevTools

## 目錄結構
```
endless-runner/
├── CLAUDE.md                  ← 你現在讀的這個檔案
├── project.godot
├── src/
│   ├── core/
│   │   ├── GameManager.gd     ← AutoLoad，管理遊戲狀態
│   │   ├── EventBus.gd        ← AutoLoad，全域事件
│   │   └── SaveSystem.gd      ← AutoLoad，存最高分
│   ├── entities/
│   │   ├── Player.gd          ← 玩家角色
│   │   └── Obstacle.gd        ← 障礙物基底類別
│   ├── systems/
│   │   ├── WorldGenerator.gd  ← 無限地板 + 障礙物生成
│   │   └── ScoreSystem.gd     ← 分數計算
│   └── ui/
│       ├── HUD.gd             ← 分數顯示、血量
│       └── MainMenu.gd        ← 開始畫面
├── scenes/
│   ├── main.tscn              ← 主場景
│   ├── entities/
│   │   ├── player.tscn
│   │   └── obstacle.tscn
│   └── ui/
│       ├── hud.tscn
│       └── main_menu.tscn
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── docs/
    ├── platform-notes.md      ← 各平台踩坑記錄（隨時更新）
    └── progress.md            ← 開發進度
```

## 架構原則（每次修改都要遵守）
1. **EventBus 優先**：系統間通訊走 EventBus，不直接互相引用
2. **單一職責**：每個 .gd 檔案只做一件事，超過 150 行考慮拆分
3. **Resource 資料驅動**：數值（速度、間距、分數）放常數或 Resource，不硬編碼
4. **平台差異集中**：所有 `OS.has_feature()` 的判斷集中在 PlatformBridge.gd，不散落各處

## 命名規範
- 類別名：PascalCase（`WorldGenerator`）
- 函式 / 變數：snake_case（`get_current_score`）
- 常數：SCREAMING_SNAKE_CASE（`MAX_SPEED`）
- Signal：snake_case 過去式動詞（`player_died`、`score_changed`）
- 場景檔：snake_case（`main_menu.tscn`）
- 節點名稱：PascalCase（`PlayerSprite`、`ObstacleSpawner`）

## 核心 Signal 清單（EventBus）
```gdscript
signal game_started()
signal game_over(final_score: int)
signal score_changed(new_score: int)
signal player_died()
signal player_jumped()
signal obstacle_spawned(obstacle: Node)
```

## 遊戲設計規格
- 視角：2D 橫向捲軸
- 操作：單鍵跳躍（空白鍵 / 螢幕點擊 / 觸控）
- 速度：隨時間逐漸加快（初速 300，每 10 秒 +30，上限 800）
- 障礙物：隨機高低組合，從右側生成，向左移動
- 死亡條件：碰到障礙物
- 分數：存活時間（秒 × 10）
- 存檔：只存最高分（`user://` 路徑，跨平台）

## 平台處理原則
```gdscript
# 所有平台差異統一在 PlatformBridge.gd 處理
# 其他檔案不直接寫 OS.has_feature()

func handle_input_by_platform():
    if OS.has_feature("mobile") or OS.has_feature("web"):
        # 觸控 / 點擊跳躍
        pass
    else:
        # 鍵盤空白鍵
        pass
```

## 禁止事項
- 禁止在 `_process()` 裡做字串操作或大量計算
- 禁止跨 Scene 直接 `get_node()`，改用 EventBus 或 GameManager
- 禁止硬編碼數值，統一放 `src/core/Constants.gd`
- 禁止在同一個函式同時處理邏輯和 UI 更新

## AutoLoad 設定（project.godot 需要加入）
```
GameManager  →  res://src/core/GameManager.gd
EventBus     →  res://src/core/EventBus.gd
SaveSystem   →  res://src/core/SaveSystem.gd
```

## 目前進度（每天更新這個區塊）

> 標記說明：✅ 完成且已串接、🟡 邏輯完成但場景未串接（執行時不會生效或會 crash）、⬜ 未開始

- [x] **Step 1**：專案骨架建立 ✅
- [x] **Step 2**：場景 + 地板捲動 + Web export ✅（含 GitHub Pages 自動部署）
- [x] **Step 3**：角色顯示 + 跳躍 ✅
- [x] **Step 4**：障礙物生成 + 移動 ✅
- [x] **Step 5**：碰撞 + 死亡判定 ✅
- [x] **Step 6**：分數系統 ✅
- [x] **Step 7**：最高分存檔 ✅
- [x] **Step 8**：主選單 + 重試流程 ✅（內部測試用最小可用版本）
- [x] **Step 9**：速度遞增 + 難度曲線 ✅
- [ ] **Step 10**：Android export ⬜
- [ ] **Step 11**：Steam build (PC) ⬜
- [ ] **Step 12**：iOS export ⬜（待設備到位）

### 已知尚未做的小事項
- 障礙物生成間隔目前固定，plan.md Step 9 提到的「間隔隨速度縮短」尚未實作
- 還沒有 PlatformBridge.gd（目前未出現需要分平台處理的程式碼）
- `.github/workflows/deploy-web.yml` 的 `GODOT_VERSION` 鎖定 `4.6.2`（與本機一致）；本機升降版本時需同步更新

---

## 已完成項目實作說明

### Step 1：專案骨架建立
- 建立 `src/{core,entities,systems,ui}` 與 `scenes/{entities,ui}` 目錄
- 一次提交 10 支 GDScript（含完整邏輯，並非純骨架）
- `project.godot` 註冊 3 個 AutoLoad：`EventBus` / `GameManager` / `SaveSystem`
- 註冊 Input Map `jump` action：綁定 **空白鍵（physical_keycode=32）** + **滑鼠左鍵** + **觸控**，讓平台輸入差異交給 Godot 自動處理

### Step 2：場景 + 地板捲動 + Web export

#### 場景與地板（執行面）
**檔案**：`scenes/main.tscn`、`src/systems/WorldGenerator.gd`

**作業步驟**：
1. `main.tscn` 以 `Node2D` 為根，掛上 `Main.gd`，並 instance `WorldGenerator`、`Player`，加一個固定 `Camera2D`
2. `WorldGenerator._ready()` 讀 `display/window/size/viewport_width`，計算需要的地板磚塊數量：`ceili(viewport_width / GROUND_TILE_WIDTH) + 2`（多 2 塊作為左右緩衝）
3. `_setup_ground()` 用迴圈程式化生成磚塊：每塊是一個 `StaticBody2D` + 矩形 `CollisionShape2D` + 棕色 `ColorRect`，水平排列在 `GROUND_Y = 500`
4. `_process()` 每幀呼叫 `_scroll_ground()`，但僅在 `GameManager.current_state == PLAYING` 時才捲動
5. **物件池循環**：`_scroll_ground()` 把每塊磚塊往左推 `current_speed * delta`，磚塊位置 `<= -GROUND_TILE_WIDTH`（完全離開畫面）時，呼叫 `_find_rightmost_x()` 找最右側磚塊，將該磚塊重新定位到最右側 + 一塊寬度的位置 — 達成「無限地板」而不需動態 new/free

#### Web export + GitHub Pages 自動部署
**檔案**：`export_presets.cfg`、`.github/workflows/deploy-web.yml`、`docs/web-deploy.md`、`.gitignore`

**關鍵設計決策**：
- **`variant/thread_support=false`**：Godot 4.3+ 的單執行緒 Web build。原因：GitHub Pages 不允許設定 COOP/COEP headers，沒有 `SharedArrayBuffer`，所以多執行緒 build 會直接 fail。單執行緒 build 不需要 SAB，能直接放任何靜態主機
- **`export_presets.cfg` 進版控**：`.gitignore` 移除原本的排除（Godot 預設會忽略），讓 CI 能讀到同一份設定
- **GitHub Actions 流程**：`Checkout → 下載 Godot CLI → 下載 export templates → headless import → headless export → 上傳 artifact → deploy-pages@v4`
- **觸發條件**：push 到 `master` 或手動 `workflow_dispatch`
- **`GODOT_VERSION` 必須與本機一致**，目前鎖定 `4.6.2`（對應本機 4.6.2-stable），對齊方式寫在 `docs/web-deploy.md`

**一次性設定**：repo Settings → Pages → Source 選 `GitHub Actions`（不是 branch deploy）

部署網址格式：`https://<github-username>.github.io/endless-runner/`

詳細步驟、踩坑排查見 `docs/web-deploy.md`。

### Step 3：角色顯示 + 跳躍
**檔案**：`scenes/entities/player.tscn`、`src/entities/Player.gd`

**作業步驟**：
1. `player.tscn` 以 `CharacterBody2D` 為根，子節點：`CollisionShape2D`（30×50 矩形，offset Y=-25 讓 origin 在腳底）+ `PlayerSprite`（藍色 ColorRect 佔位）
2. 在 `main.tscn` 將 Player instance 放在 `Vector2(200, 500)` —— 剛好站在 `GROUND_Y` 上
3. `Player._physics_process(delta)` 每物理幀做三件事：
   - `_apply_gravity(delta)`：若 `is_on_floor()` 為 false，`velocity.y += gravity * delta`（gravity 從 ProjectSettings 讀）
   - `_handle_jump()`：偵測 `Input.is_action_just_pressed("jump")` **且** `is_on_floor()` 才允許跳躍 → 把 `velocity.y = -600`（負值向上）→ emit `EventBus.player_jumped`
   - `move_and_slide()`：套用速度與碰撞解算
4. **事件流向**：玩家按下空白鍵/點擊/觸控 → Godot Input Map 統一轉為 `jump` action → `Player._handle_jump()` 設定向上速度並 emit `player_jumped` signal → 任何訂閱者（將來音效、動畫）可以監聽

### Step 4：障礙物生成 + 移動
**檔案**：`scenes/entities/obstacle.tscn`、`src/entities/Obstacle.gd`、`WorldGenerator.gd`

**作業步驟**：
1. `obstacle.tscn` 是空的 `Area2D` + 掛 `Obstacle.gd`（視覺與碰撞都用程式建立，方便依 type 切換尺寸）
2. `Obstacle._ready()` 依 `obstacle_type`（`LOW` / `HIGH`）：
   - `_setup_visual()`：建立 `ColorRect`（紅色 `OBSTACLE_COLOR`），origin 在底部中心
   - `_setup_collision()`：建立對應大小的 `RectangleShape2D` + `CollisionShape2D`
3. `WorldGenerator._setup_timer()` 建立一個 `one_shot = true` 的 `Timer` 加為子節點
4. 收到 `EventBus.game_started` → `_on_game_started()` → `start_spawning()` → `_start_next_timer()`，以 `randf_range(1.2, 2.5)` 秒為間隔啟動 Timer
5. Timer `timeout` → `_spawn_obstacle()`：
   - `randf() > 0.5` 決定 LOW / HIGH
   - `_spawn_x = viewport_width + 100`（在畫面右側外）
   - HIGH 類型 Y = `GROUND_Y - OBSTACLE_HIGH_OFFSET_Y`（80px 高度，要跳過去）；LOW 類型 Y = `GROUND_Y`
   - emit `EventBus.obstacle_spawned`
   - 接著再 `_start_next_timer()` 排下一個
6. 每個 `Obstacle._process(delta)` 自己往左移：`position.x -= GameManager.current_speed * delta`（速度跟地板同步）
7. `_check_off_screen()`：`position.x < -100` 就 `queue_free()` 自動回收

### Step 5：碰撞 + 死亡判定
**檔案**：`Obstacle.gd`、`Player.gd`、`GameManager.gd`、`WorldGenerator.gd`

**作業步驟**：
1. Obstacle 是 `Area2D`，`_ready()` 連 `body_entered` signal 到 `_on_body_entered`
2. Player 是 `CharacterBody2D`，本身是 PhysicsBody → 走進 Obstacle 區域時觸發
3. `_on_body_entered(body)` 檢查 `body is Player` → emit `EventBus.player_died`
4. **多端聽到 `player_died` 事件後各自反應**：
   - `GameManager._on_player_died()` → `change_state(DEAD)` → `_process()` 不再加速
   - `WorldGenerator._on_player_died()` → `stop_spawning()`：停止 Timer，並 `queue_free()` 所有現存 Obstacle
   - 同時因為 `Obstacle._process()` / `WorldGenerator._scroll_ground()` 都會檢查 `current_state == PLAYING`，狀態一變 DEAD 後地板與障礙物自動停下
   - `ScoreSystem._on_player_died()` → emit `EventBus.game_over(_score)` → `SaveSystem.save_high_score()`（**注意：目前 ScoreSystem 還沒進場景，這條鏈未實際運作**）

### Step 6：分數系統
**檔案**：`src/systems/ScoreSystem.gd`、`scenes/main.tscn`

**作業步驟**：
1. `main.tscn` 中加入 `ScoreSystem` 節點（純 `Node` + 腳本）
2. `_ready()` 訂閱 `EventBus.game_started`（重置）與 `player_died`（結算）
3. `_process(delta)` 僅在 `PLAYING` 狀態累計 `_elapsed += delta`，計算 `int(_elapsed) * SCORE_MULTIPLIER` (= 10)
4. 分數有變動才 emit `EventBus.score_changed(_score)`，避免每幀都打事件
5. HUD 訂閱 `score_changed` 即時更新 `ScoreLabel`

### Step 7：最高分存檔
**檔案**：`src/core/SaveSystem.gd`、`src/systems/ScoreSystem.gd`、`src/ui/HUD.gd`、`src/ui/MainMenu.gd`

**作業步驟**：
1. `SaveSystem` 是 AutoLoad，將最高分存到 `user://save.json`（Web 平台會自動使用 IndexedDB）
2. `save_high_score(score)` 先讀現有最高分，僅在 `score > current_high` 時才覆寫
3. `ScoreSystem._on_player_died()`：先 emit `EventBus.game_over(_score)`，接著 `SaveSystem.save_high_score(_score)`
4. `HUD._on_game_over()` 收到事件 → `_update_high_score()` 重新讀取顯示最新最高分
5. `MainMenu._update_high_score()` 在 `_ready()` 時讀一次，顯示在主選單上

### Step 8：主選單 + 重試流程
**檔案**：`scenes/ui/main_menu.tscn`、`scenes/ui/hud.tscn`、`scenes/main.tscn`、`src/ui/MainMenu.gd`、`src/ui/HUD.gd`、`src/Main.gd`、`src/entities/Player.gd`

**設計（內部測試用最小流程）**：
```
進入遊戲 → MainMenu 顯示 → 點 Start → 遊玩 → 死亡 → GameOverPanel → 點 Retry → 遊玩
```

**作業步驟**：
1. `main_menu.tscn` 改為 `CanvasLayer` 為根（原本是 `Control`，與 `MainMenu.gd extends CanvasLayer` 不符會 crash），`layer = 10` 確保覆蓋 HUD；子節點：半透明 `Background` ColorRect、`TitleLabel`、`HighScoreLabel`、`StartButton`、`HintLabel`
2. `hud.tscn` 補上 `HighScoreLabel`（右上）與 `GameOverPanel`（Control，含 `Background` 半透明遮罩 + `GameOverLabel` + `FinalScoreLabel` + `RetryButton`）
3. `main.tscn` 加入 `ScoreSystem` 節點、instance `HUD` 與 `MainMenu`（之前完全沒掛上去）
4. `Main.gd` 移除 `_ready()` 裡的 `EventBus.game_started.emit()`，改由 MainMenu 的 Start 按鈕推動流程
5. `MainMenu.gd` 訂閱 `EventBus.game_started` → `visible = false` 自動隱藏（首次開始與 Retry 都會觸發）
6. `HUD.gd` 新增 `final_score_label` 引用，`_on_game_over()` 顯示 `SCORE: <分數>`；既有的 `_on_game_started` 已負責隱藏 `GameOverPanel`，所以 Retry 流程自動處理
7. `Player.gd`：
   - 新增 `_spawn_position`，`_ready()` 記錄場景初始位置
   - 訂閱 `game_started`，在 `_on_game_started()` 把 `position` 復歸並 `velocity = Vector2.ZERO`
   - `_handle_jump()` 加上 `current_state == PLAYING` gate，避免在菜單或 Game Over 時誤跳
8. **Retry 連鎖反應**（按下 RetryButton 後）：
   - `HUD._on_retry_pressed()` → emit `EventBus.game_started`
   - `GameManager` → 狀態切 `PLAYING`、`_reset()` 速度
   - `WorldGenerator` → `stop_spawning()`（清除舊障礙物）+ `start_spawning()`
   - `ScoreSystem` → `_reset()` 分數歸零
   - `Player` → 位置 / 速度復歸
   - `HUD` → 隱藏 `GameOverPanel`、Score 歸 0
   - `MainMenu` → 維持隱藏

**為何菜單時 Player 不會掉下去**：地板是 `StaticBody2D` 永遠存在，重力會讓 Player 立刻落到地板上靜止。`WorldGenerator._scroll_ground()` 與 `Obstacle._process()` 都有 `current_state == PLAYING` 的 gate，所以菜單期間世界完全靜止。

### Step 9：速度遞增 + 難度曲線
**檔案**：`src/core/GameManager.gd`、`src/core/Constants.gd`

**作業步驟**：
1. `Constants` 定義 `INITIAL_SPEED = 300`、`MAX_SPEED = 800`、`SPEED_INCREMENT = 30`、`SPEED_INTERVAL = 10`
2. `GameManager` 是 AutoLoad，不需要場景就會啟動
3. `_ready()` 訂閱 `game_started` / `player_died`，狀態切到 `PLAYING` 時 `_reset()` 清空 `current_speed` 與 `_speed_timer`
4. `_process(delta)` 僅在 `PLAYING` 時呼叫 `_update_speed(delta)`：累計時間，每滿 10 秒就 `current_speed = minf(current_speed + 30, 800)`
5. `WorldGenerator._scroll_ground()` 與 `Obstacle._move()` 都直接讀 `GameManager.current_speed`，**不需要額外通知**就會跟著加速

> 註：障礙物生成間隔目前為固定 `randf_range(1.2, 2.5)`，plan.md Step 9 提到的「生成間隔隨速度縮短」尚未實作。

## 已知問題 / 踩坑記錄
（開發過程中隨時在這裡記錄，下次開對話 Claude Code 會讀到）
