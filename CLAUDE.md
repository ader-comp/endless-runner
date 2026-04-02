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
- [x] Step 1：專案骨架建立
- [ ] Step 2：場景 + 地板捲動 + Web export（QA 開始參與）
- [ ] Step 3：角色顯示 + 跳躍
- [ ] Step 4：障礙物生成 + 移動
- [ ] Step 5：碰撞 + 死亡判定
- [ ] Step 6：分數系統
- [ ] Step 7：最高分存檔
- [ ] Step 8：主選單 + 重試流程
- [ ] Step 9：速度遞增 + 難度曲線
- [ ] Step 10：Android export
- [ ] Step 11：Steam build (PC)
- [ ] Step 12：iOS export（待設備到位）

## 已知問題 / 踩坑記錄
（開發過程中隨時在這裡記錄，下次開對話 Claude Code 會讀到）
