extends Node2D

## 主場景根節點。實際的遊戲流程由 MainMenu 的 Start 按鈕與 HUD 的 Retry 按鈕透過
## EventBus.game_started 推動，這裡不主動啟動遊戲。
