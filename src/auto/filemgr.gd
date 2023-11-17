extends Node

func f_save(savepath: String, content):
	var file
	var filepath = savepath
	var type = savepath.get_extension()
	file = FileAccess.open(filepath, FileAccess.WRITE)
	
	if type == "json":
		var jsoncontent
		if content is String:
			jsoncontent = JSON.parse_string(content)
			jsoncontent = JSON.stringify(jsoncontent, "\t", false)
		else:
			jsoncontent = JSON.stringify(content, "\t", false)
		file.store_string(jsoncontent)
	else:
		var txtcontent
		txtcontent = str(content)
		file.store_string(txtcontent)
	file.close()

func f_read(path: String):
	var file
	var filepath = path
	var data
	var type = path.get_extension()
	print("load path: ", filepath)
	file = FileAccess.open(filepath, FileAccess.READ)
	if type == "json":
		var content = file.get_as_text()
		content = JSON.parse_string(content)
		data = content
	else:
		var content = file.get_as_text()
		data = content
	file.close()
	return data
