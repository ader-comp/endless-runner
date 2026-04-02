# Godot Editor 設定說明

## Input Map 設定

在 Godot Editor 中：**Project → Project Settings → Input Map**

新增 action：

| Action 名稱 | 對應輸入 |
|---|---|
| `jump` | Key: Space |
| `jump` | Mouse Button: Left |
| `jump` | Touchscreen Touch |

### 操作步驟

1. 開啟 **Project → Project Settings**
2. 切換到 **Input Map** 分頁
3. 在上方輸入框輸入 `jump`，點擊 **Add**
4. 點擊 `jump` 右側的 **+** 按鈕，分別加入：
   - **Key** → 選擇 **Space**
   - **Mouse Button** → 選擇 **Left Button**
   - **Touchscreen** → 選擇 **Touchscreen Touch**

## AutoLoad 設定

在 **Project → Project Settings → Globals → AutoLoad**：

| 名稱 | 路徑 |
|---|---|
| EventBus | `res://src/core/EventBus.gd` |
| GameManager | `res://src/core/GameManager.gd` |
| SaveSystem | `res://src/core/SaveSystem.gd` |

> 注意：EventBus 需要在 GameManager 之前載入，因為 GameManager 會在 `_ready()` 中連接 EventBus 的 signal。
