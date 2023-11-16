extends Node

var obj_pr = preload("res://tscn/object.tscn")

var skin_path := "placeholder"

var merge_list := []

var high_lvl := 1

func merge(obj, pos, lvl):
	print(9)
	merge_list.append([obj, pos])
	if merge_list.size() >= 2:
		if lvl > high_lvl:
			high_lvl = lvl
		$/root/main/merge.play()
		var spawn_pos = lerp(merge_list[0][1], merge_list[1][1], 0.5)
		var new_obj = obj_pr.instantiate()
		new_obj.position = spawn_pos
		new_obj.init(lvl + 1)
		$/root/main.add_child.call_deferred(new_obj)
		new_obj.drop()
		for i in merge_list:
			if !i[0]:
				pass
			else:
				i[0].queue_free()
		merge_list.clear()
