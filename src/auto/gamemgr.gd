extends Node

# 失敗シグナル
signal fail
# オブジェクトのプリロード
var obj_pr = preload("res://tscn/object.tscn")
# ロードするスキンファイル
var skin_path := "placeholder"
# マージ待機列
var merge_list := []
# ラウンドの最高レベル
var high_lvl := 1
# ネクストに入っているオブジェクト
var next_obj := 1
# スコア
var score := 0:
	set(v):
		score = v
		$/root/main/ui/score/cur.text = str(v)
# ハイスコア
var high_score := 0:
	set(v):
		high_score = v
		$/root/main/ui/score/best.text = str(v)
# ランキング
var score_ranking : Array
# 統計スコア
var total_score := 0
# プレイ時間
var playtime := 0
# 統計マージ回数(lvlごと)
var merge_status : Array
# 何ゲーム目か
var game_index := 0:
	set(v):
		game_index = v
		$/root/main/ui/info/cur.text = str(v) + "ゲーム目"
# 最高レベル
const MAX_LVL := 11
# ランキングサイズ
const RANKING_SIZE := 3

var engine_info := {
	"name": "Suika Engine",
	"version": "1.0"
}

var mod_info := {
	"name": "スイカゲーム",
	"version": "1.0"
}

func _ready():
	skin_path = File.f_read("res://asset/image_path.txt")
	var info = File.f_read("res://asset/mod_info.txt").replace("\r", "").split("\n")
	mod_info.name = info[0]
	mod_info.version = info[1]
	print(info)
	get_window().title = engine_info.name + " " + engine_info.version + " - " + mod_info.name
	merge_status.resize(MAX_LVL)
	merge_status.fill(0)
	score_ranking.resize(RANKING_SIZE)
	score_ranking.fill([0, 0])
	if !FileAccess.file_exists("user://suika_engine_data.json"):
		save_(true)
	load_()
	$/root/main/ui/score/best.text = str(high_score)
	var count := 0
	for i in score_ranking:
		var score_lbl = get_node("/root/main/ui/ranking/Panel/MarginContainer2/Panel/MarginContainer/VBoxContainer/" + str(count) + "/score")
		score_lbl.text = str(i[0])
		count += 1
	while true:
		await get_tree().create_timer(1).timeout
		playtime += 1

func merge(obj, pos, lvl):
	merge_list.append([obj, pos])
	if merge_list.size() >= 2:
		barrel(lvl)
		if lvl > high_lvl:
			high_lvl = lvl
		$/root/main/merge.play()
		score_add(lvl ** 2)
		merge_add(lvl)
		var spawn_pos = lerp(merge_list[0][1], merge_list[1][1], 0.5)
		var new_obj = obj_pr.instantiate()
		new_obj.position = spawn_pos
		new_obj.init(lvl + 1)
		$/root/main/objects.add_child.call_deferred(new_obj)
		new_obj.drop()
		for i in merge_list:
			if !i[0]:
				pass
			else:
				i[0].queue_free()
		merge_list.clear()

var barrel_value := 0.0
@onready var rect = $/root/main/shader/barrel
@onready var rect2 = $/root/main/shader2/sobel

func barrel(v):
	barrel_value -= v / 100.0

func _process(delta):
	if barrel_value >= 0.0:
		barrel_value = 0
	else:
		barrel_value += delta * 0.1
	rect.material.set("shader_parameter/barrel", barrel_value)
	rect.material.set("shader_parameter/zoom", barrel_value / 4.0 + 1)
	rect2.material.set("shader_parameter/strength", barrel_value)

func score_add(v):
	for i in range(v):
		score += 1
		total_score += 1
		$/root/main/ui/score/cur.text = str(score)
		await get_tree().create_timer(0).timeout
		
		# ハイスコアチェック
		if score >= high_score:
			high_score = score
			$/root/main/ui/score/best.text = str(high_score)
		
		# ランキングチェック
		var append_f := true
		for index in score_ranking:
			if index[1] == game_index:
				append_f = false
				index[0] = score
				break
		if append_f and score_ranking[0][0] < score:
			score_ranking.append([score, game_index])
			score_ranking.pop_front()
		score_ranking.sort_custom(ranking_sort)
	var count := 0
	for i in score_ranking:
		var score_lbl = get_node("/root/main/ui/ranking/Panel/MarginContainer2/Panel/MarginContainer/VBoxContainer/" + str(count) + "/score")
		score_lbl.text = str(i[0])
		count += 1
	print(score_ranking)

func ranking_sort(a, b):
	if b[0] > a[0]:
		return true
	return false

func merge_add(v):
	merge_status[v] += 1

func load_():
	var dict: Dictionary = File.f_read("user://suika_engine_data.json")
	if !dict.has(mod_info.name):
		dict = save_()
	for i in dict[mod_info.name].keys():
		Game[i] = dict[mod_info.name][i]
	print(dict)

func save_(init = false):
	var dict: Dictionary
	var read: Dictionary
	if !init:
		dict = {
			"high_score": high_score,
			"total_score": total_score,
			"merge_status": merge_status,
			"playtime": playtime,
			"score_ranking": score_ranking,
			"game_index": game_index
		}
		read = File.f_read("user://suika_engine_data.json")
	read[mod_info.name] = dict
	File.f_save("user://suika_engine_data.json", read)
	print("saved: ", read)
	return read

func reset():
	merge_list.clear()
	high_lvl = 1
	next_obj = 1
	score = 0

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("closed")
		save_()
