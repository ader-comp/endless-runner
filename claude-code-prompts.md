# Claude Code 啟動 Prompt — Step 1

## 使用方式
1. 在本機建立空資料夾 `endless-runner/`
2. 把 CLAUDE.md 放進去
3. 用 Claude Code 開啟這個資料夾（`claude` 指令在此目錄執行）
4. 把下方「=== 貼入 Claude Code ===" 區塊內的文字完整貼入

---

=== 貼入 Claude Code ===

請閱讀 CLAUDE.md，然後幫我完成 Step 1：建立完整的 Godot 4 專案骨架。

具體要做的事：

**1. 建立目錄結構**
依照 CLAUDE.md 裡的目錄結構，建立所有資料夾和空檔案。

**2. 建立這些 GDScript 檔案（含基本內容，可以執行不報錯）**

`src/core/Constants.gd`
```
所有遊戲數值常數：
- INITIAL_SPEED = 300.0
- MAX_SPEED = 800.0
- SPEED_INCREMENT = 30.0
- SPEED_INTERVAL = 10.0（每幾秒加速一次）
- SCORE_MULTIPLIER = 10
- OBSTACLE_SPAWN_MIN_INTERVAL = 1.2
- OBSTACLE_SPAWN_MAX_INTERVAL = 2.5
- GROUND_Y = 500（地板 Y 座標）
```

`src/core/EventBus.gd`（AutoLoad）
```
宣告 CLAUDE.md 裡列出的所有 Signal
```

`src/core/GameManager.gd`（AutoLoad）
```
- enum GameState { MENU, PLAYING, DEAD }
- 狀態機：change_state() 函式
- 追蹤 current_speed，隨時間增加
- 監聽 player_died signal → 切換到 DEAD 狀態
```

`src/core/SaveSystem.gd`（AutoLoad）
```
- save_high_score(score: int)
- load_high_score() -> int
- 用 user://save.json 儲存
- 跨平台：自動處理路徑差異
```

`src/entities/Player.gd`
```
- 繼承 CharacterBody2D
- 重力 + 跳躍（jump_velocity = -600）
- 支援三種輸入：鍵盤空白鍵、滑鼠點擊、觸控
- 死亡時 emit EventBus.player_died
- 不在這裡判斷平台，輸入統一用 Input.is_action_just_pressed("jump")
```

`src/entities/Obstacle.gd`
```
- 繼承 Area2D
- 從右向左移動（速度從 GameManager 取得）
- 離開畫面左側時自動 queue_free()
- 碰到 Player 時 emit EventBus.player_died
```

`src/systems/WorldGenerator.gd`
```
- 繼承 Node
- 用 Timer 定時生成 Obstacle（間隔隨機）
- 生成位置：x = 畫面右側外 + 100，y = 隨機高低兩種
- GameState 不是 PLAYING 時暫停生成
```

`src/systems/ScoreSystem.gd`
```
- 繼承 Node
- PLAYING 狀態下每秒累加分數
- emit EventBus.score_changed(new_score)
- game_over 時呼叫 SaveSystem.save_high_score()
```

`src/ui/HUD.gd`
```
- 顯示目前分數（監聽 score_changed）
- 顯示最高分
- game_over 時顯示結果面板 + 重試按鈕
```

`src/ui/MainMenu.gd`
```
- 開始按鈕 → emit EventBus.game_started
- 顯示最高分
```

**3. 建立 input map 說明**
在 `docs/setup.md` 說明需要在 Godot Editor 的 Input Map 加入：
- action 名稱：`jump`
- 對應按鍵：Space、滑鼠左鍵、觸控

**4. 建立 `docs/platform-notes.md`**
初始內容：各平台待測試項目清單（空的，之後填入踩坑記錄）

**5. 完成後告訴我：**
- 哪些檔案建立完成
- 在 Godot Editor 需要手動做哪些設定（AutoLoad、Input Map、場景建立）
- 下一步（Step 2）的建議切入點

注意事項：
- 所有 GDScript 要有 class_name 宣告
- 遵守 CLAUDE.md 的命名規範
- 每個函式加上簡短的 ## 註解說明用途
- 這個 Step 只建結構，不建 .tscn 場景檔（那是 Step 2 的事）

=== 結束 ===

---

## Step 1 完成後，手動在 Godot Editor 做這些事

```
1. File → New Project → 選 endless-runner/ 資料夾
2. Project → Project Settings → AutoLoad：
   加入 GameManager / EventBus / SaveSystem
3. Project → Project Settings → Input Map：
   新增 "jump" action，加入 Space + Mouse Left + Touch
4. 建立 scenes/main.tscn（空場景，之後 Step 2 填充）
```

## 進入 Step 2 的 Prompt（Step 1 完成後使用）

=== Step 2 Prompt ===

請閱讀 CLAUDE.md，目前 Step 1 已完成。

現在進行 Step 2：無限地板 + 障礙物生成系統。

請在 `scenes/main.tscn` 對應的結構下，
實作 WorldGenerator 的完整邏輯：

1. 地板用多個 ColorRect 或 StaticBody2D 組成，
   循環複用（物件池模式），不要無限新增節點

2. Obstacle 場景（scenes/entities/obstacle.tscn）：
   - 兩種高度變化（低障礙 / 高障礙）
   - 用不同顏色 ColorRect 先代替美術（紅色）

3. WorldGenerator 在 PLAYING 狀態下：
   - 用 Timer 隨機間隔生成 Obstacle
   - 速度從 GameManager.current_speed 取得
   - DEAD 狀態下停止生成並清除現有障礙物

完成後告訴我如何在 Editor 測試，
以及這個系統有哪些之後需要注意的跨平台差異。

=== 結束 ===
