
@tool
extends Node
# Script para recorrer todos los archivos y carpetas del proyecto Godot
class_name FileWalker

func _ready():
	print_all_files("res://")

func print_all_files(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("No se pudo abrir el directorio: ", path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		var file_path = path + file_name
		if dir.current_is_dir():
			print_all_files(file_path + "/")
		else:
			print(file_path)
		file_name = dir.get_next()
	dir.list_dir_end()