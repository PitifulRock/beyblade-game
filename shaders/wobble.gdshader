shader_type spatial;
render_mode blend_mix, cull_disabled, diffuse_toon, specular_toon;

uniform sampler2D displacement_texture : hint_default_white;
uniform float height_scale : hint_range(0.0, 10.0) = 1.0;
uniform float offset : hint_range(0.0, 10.0) = 1.0;
uniform float alpha_scale : hint_range(0.0, 1.0) = 1.0;
uniform float scroll_scale : hint_range(0.0, 6.0) = 1.0;

uniform sampler2D albedo_texture : hint_default_black;
uniform vec4 albedo_color : source_color = vec4(1.0);

void vertex() {
	float displacement = texture(displacement_texture, UV + TIME).r;

	VERTEX.x += offset-displacement * height_scale;
	VERTEX.z += offset-displacement * height_scale;
}

void fragment() {
	vec4 tex_color = texture(albedo_texture, UV+TIME*scroll_scale/10.0) * albedo_color;

	ALBEDO = tex_color.rgb;

	ALPHA = tex_color.a * alpha_scale;
	EMISSION = ALBEDO;
}