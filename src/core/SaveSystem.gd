class_name SaveSystemClass
extends Node

const SAVE_PATH: String = "user://save.json"


## 儲存最高分到本地檔案
func save_high_score(score: int) -> void:
	var current_high := load_high_score()
	if score <= current_high:
		return
	var data := {"high_score": score}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


## 從本地檔案讀取最高分
func load_high_score() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return 0
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return 0
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if error != OK:
		return 0
	var data: Variant = json.data
	if data is Dictionary and data.has("high_score"):
		return int(data["high_score"])
	return 0
