class_name Constants
extends RefCounted

## 初始移動速度
const INITIAL_SPEED: float = 300.0

## 最大移動速度
const MAX_SPEED: float = 800.0

## 每次加速的增量
const SPEED_INCREMENT: float = 30.0

## 每幾秒加速一次
const SPEED_INTERVAL: float = 10.0

## 分數倍率（存活秒數 × 此值）
const SCORE_MULTIPLIER: int = 10

## 障礙物生成最短間隔（秒）
const OBSTACLE_SPAWN_MIN_INTERVAL: float = 1.2

## 障礙物生成最長間隔（秒）
const OBSTACLE_SPAWN_MAX_INTERVAL: float = 2.5

## 地板 Y 座標
const GROUND_Y: float = 500.0

## 地板磚塊寬度
const GROUND_TILE_WIDTH: float = 640.0

## 地板厚度
const GROUND_TILE_HEIGHT: float = 120.0

## 地板顏色
const GROUND_COLOR: Color = Color(0.35, 0.25, 0.15)

## 低障礙物尺寸（寬 × 高）
const OBSTACLE_LOW_SIZE: Vector2 = Vector2(40.0, 60.0)

## 高障礙物尺寸（寬 × 高）
const OBSTACLE_HIGH_SIZE: Vector2 = Vector2(60.0, 40.0)

## 障礙物顏色
const OBSTACLE_COLOR: Color = Color(0.85, 0.15, 0.15)

## 高障礙物相對地面的偏移（向上）
const OBSTACLE_HIGH_OFFSET_Y: float = 80.0
