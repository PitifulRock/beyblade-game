extends Control

var player_pfp : ImageTexture:
	set(val):
		player_pfp = val
		%Image.texture = val
var player_name : String:
	set(val):
		player_name = val
		%Name.text = val
