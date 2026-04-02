class_name EventBusClass
extends Node

## 遊戲開始
signal game_started()

## 遊戲結束，帶最終分數
signal game_over(final_score: int)

## 分數更新
signal score_changed(new_score: int)

## 玩家死亡
signal player_died()

## 玩家跳躍
signal player_jumped()

## 障礙物生成
signal obstacle_spawned(obstacle: Node)
