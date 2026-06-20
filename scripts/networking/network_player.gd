extends FreeLookCamera
class_name Player

var steam_id : int
@export var display_name : String:
	set(val):
		display_name = val
var beyblade_node : BeyBlade = null

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	Master.load_avatar(name.to_int())
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	load_avatar()
	
	if !is_multiplayer_authority(): return
	for i in Master.game_manager.current_scene.player_path.get_children():
		Master.player_list[i.name.to_int()] = i
	%Model.visible = false
	display_name = Steam.getPersonaName()
	current = true
	Master.local_player = self
	$Label3D.text = display_name



func load_avatar():
	var id = name.to_int() if name.to_int() != 1 else Master.get_host_id()
	Steam.getPlayerAvatar(3, id)
	Steam.requestUserInformation(id, false)
	Console._print("Player Caching:  ", id)

func _on_avatar_loaded(avatar_id: int, size_: int, data: Array):
	var avatar_image: Image = Image.create_from_data(size_, size_, false, Image.FORMAT_RGBA8, data)
	if size_ > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)

	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	
	$Sprite3D.texture = avatar_texture
	Console._print(avatar_id, "cached")
