# Endless Runner — 專案開發計畫 (PM)

## 專案概述

以 Godot 4 開發 2D 橫向捲軸 Endless Runner 遊戲，目標是透過實作熟悉 Web / Android / Steam / iOS 四平台的開發流程與技術差異。

## 開發流程

- 每個 Step 完成後開 Pull Request
- Step 2 起包含 Web build，QA 用瀏覽器驗收
- QA 通過後由 PM approve 合併至 master
- iOS 因開發環境採購中，安排在最後階段

## Step 總覽

| Step | 名稱 | 前置依賴 | QA 驗收方式 |
|---|---|---|---|
| 1 | 專案骨架建立 | 無 | DEV 自驗 |
| 2 | 場景 + 地板捲動 + Web export | Step 1 | 瀏覽器：看到地板捲動 |
| 3 | 角色顯示 + 跳躍 | Step 2 | 瀏覽器：點擊/空白鍵跳躍 |
| 4 | 障礙物生成 + 移動 | Step 2 | 瀏覽器：障礙物持續出現 |
| 5 | 碰撞 + 死亡判定 | Step 3, 4 | 瀏覽器：撞到停止 + Game Over |
| 6 | 分數系統 | Step 5 | 瀏覽器：分數持續增長 |
| 7 | 最高分存檔 | Step 6 | 瀏覽器：重新整理後最高分仍在 |
| 8 | 主選單 + 重試流程 | Step 7 | 瀏覽器：完整遊戲循環 |
| 9 | 速度遞增 + 難度曲線 | Step 8 | 瀏覽器：體感變難 |
| 10 | Android export | Step 9 | Android 手機安裝 APK |
| 11 | Steam build (PC) | Step 9 | Windows 執行 .exe |
| 12 | iOS export | Step 9 | iPhone 上機測試 |

## 各 Step 詳細說明

### Step 1：專案骨架建立

**狀態**：已完成

**目標**：建立完整的目錄結構與所有 GDScript 檔案骨架。

**產出**：

- 10 個 GDScript 檔案（Constants, EventBus, GameManager, SaveSystem, Player, Obstacle, WorldGenerator, ScoreSystem, HUD, MainMenu）
- docs 文件（setup.md, platform-notes.md）

**里程碑**：專案可在 Godot Editor 開啟，無語法錯誤。

---

### Step 2：場景建立 + 地板捲動 + Web export

**目標**：建立主場景與地板，實作無限捲動，同時設定 Web export 讓 QA 可用瀏覽器測試。

**產出**：

- `scenes/main.tscn` 主場景
- 地板用 ColorRect + StaticBody2D，物件池模式循環複用
- Web export preset 設定完成
- 可部署的 HTML5 build（index.html + .wasm + .pck）

**里程碑**：QA 打開瀏覽器網址，看到地板持續捲動。此後每個 Step 的 PR 都附帶 Web build 供 QA 測試。

---

### Step 3：角色顯示 + 跳躍

**目標**：建立玩家角色場景，實作重力與跳躍。

**產出**：

- `scenes/entities/player.tscn` 玩家場景
- 角色（ColorRect 佔位）站在地板上
- 按空白鍵 / 滑鼠左鍵 / 觸控可跳躍，有重力回落

**里程碑**：QA 在瀏覽器中可操作角色跳躍。

---

### Step 4：障礙物生成 + 移動

**目標**：建立障礙物場景，實作隨機生成與移動。

**產出**：

- `scenes/entities/obstacle.tscn` 障礙物場景（紅色 ColorRect）
- 兩種高度變化（低障礙 / 高障礙）
- WorldGenerator 以隨機間隔生成障礙物
- 障礙物離開畫面自動回收

**里程碑**：QA 在瀏覽器中看到障礙物持續從右側出現。

---

### Step 5：碰撞 + 死亡判定

**目標**：實作玩家與障礙物的碰撞檢測，觸發死亡流程。

**產出**：

- 碰撞觸發 `player_died` signal
- GameManager 切換至 DEAD 狀態
- 障礙物停止生成，地板停止捲動
- 顯示 Game Over 文字

**里程碑**：QA 在瀏覽器中碰撞障礙物，確認遊戲正確停止。

---

### Step 6：分數系統

**目標**：實作即時分數計算與顯示。

**產出**：

- HUD 顯示即時分數（存活秒數 x 10）
- 死亡時顯示最終分數

**里程碑**：QA 在瀏覽器中看到分數持續增長。

---

### Step 7：最高分存檔

**目標**：實作分數持久化儲存。

**產出**：

- 死亡時自動儲存最高分（Web 使用 IndexedDB）
- 畫面顯示歷史最高分
- 重新整理頁面後最高分仍在

**里程碑**：QA 重新整理瀏覽器頁面，確認最高分仍存在。

---

### Step 8：主選單 + 重試流程

**目標**：實作完整的遊戲流程循環。

**產出**：

- `scenes/ui/main_menu.tscn` 主選單場景
- 完整流程：主選單 → 開始 → 遊玩 → 死亡 → 重試 / 回主選單
- 各狀態轉換正確，無殘留節點

**里程碑**：QA 在瀏覽器中跑完完整遊戲循環 3 次以上。

---

### Step 9：速度遞增 + 難度曲線

**目標**：實作遊戲難度隨時間提升。

**產出**：

- 每 10 秒速度增加 30，上限 800
- 地板與障礙物速度同步加快
- 障礙物生成間隔隨速度縮短

**里程碑**：QA 在瀏覽器中體感遊戲隨時間變難。

---

### Step 10：Android export

**目標**：將遊戲匯出為 Android APK。

**產出**：

- Android export 設定
- 可安裝的 debug APK
- 觸控跳躍正常運作

**里程碑**：QA 在 Android 手機上遊玩完整流程。

**踩坑重點**：觸控延遲、螢幕比例適配、效能差異。

---

### Step 11：Steam build (PC)

**目標**：匯出 Windows 執行檔。

**產出**：

- Windows export 設定
- 可執行的 .exe 檔案

**里程碑**：QA 在 Windows PC 上遊玩完整流程。

**踩坑重點**：Steamworks SDK 整合（選用）。

---

### Step 12：iOS export

**前置條件**：Mac + Xcode + Apple Developer 帳號（開發環境採購中）。

**目標**：匯出至 iOS，透過 Xcode 上機測試。

**產出**：

- iOS export 設定
- Xcode 專案，可 build 到實機

**里程碑**：QA 在 iPhone 上遊玩完整流程。

**踩坑重點**：notch 安全區域、App Store 審核規範。

## 風險與注意事項

1. **iOS 開發環境**：Mac 設備採購中，Step 12 開始時間取決於設備到位
2. **Web build 部署**：每個 PR 需提供 Web build 給 QA，建議搭配 GitHub Pages 或 CI 自動部署
3. **跨平台輸入差異**：統一透過 Input Map 的 `jump` action，平台特殊處理集中在 PlatformBridge.gd
4. **效能差異**：Mobile 平台可能需要降低粒子效果或調整生成頻率
