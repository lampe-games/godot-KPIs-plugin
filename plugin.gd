tool
extends EditorPlugin

const KPIs = preload("res://addons/godot-KPIs-plugin/KPIs.tscn")

const SERVER_AUTOLOAD_NAME = "KPIsServer"
const CLIENT_AUTOLOAD_NAME = "KPIsClient"
const SERVER_AUTOLOAD_SCRIPT = "res://addons/godot-KPIs-plugin/KPIsServer.gd"
const CLIENT_AUTOLOAD_SCRIPT = "res://addons/godot-KPIs-plugin/KPIsClient.gd"

var _kpis_node = null
var _kpis_node_added_to_dock = false


func _enter_tree():
	_kpis_node = KPIs.instance()
	add_autoload_singleton(SERVER_AUTOLOAD_NAME, SERVER_AUTOLOAD_SCRIPT)
	add_autoload_singleton(CLIENT_AUTOLOAD_NAME, CLIENT_AUTOLOAD_SCRIPT)


func build():
	"""called once the project/scene is being run"""
	if not _kpis_node_added_to_dock:
		add_control_to_dock(DOCK_SLOT_RIGHT_BL, _kpis_node)
		_kpis_node_added_to_dock = true
	return true


func _process(_delta):
	"""polling necessary to detect project is not being run anymore"""
	if not get_editor_interface().is_playing_scene():
		_try_removing_kpis_node_from_dock()


func _exit_tree():
	_try_removing_kpis_node_from_dock()
	remove_autoload_singleton(CLIENT_AUTOLOAD_NAME)
	remove_autoload_singleton(SERVER_AUTOLOAD_NAME)


func _try_removing_kpis_node_from_dock():
	if _kpis_node_added_to_dock:
		remove_control_from_docks(_kpis_node)
		_kpis_node_added_to_dock = false
