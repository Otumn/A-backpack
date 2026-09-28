shader_type canvas_item;

uniform float white_cursor = 0.0;

void fragment() 
{
	COLOR = texture(TEXTURE, UV);
	COLOR.r = mix(texture(TEXTURE, UV).r, 1.0, white_cursor);
	COLOR.g = mix(texture(TEXTURE, UV).g, 1.0, white_cursor);
	COLOR.b = mix(texture(TEXTURE, UV).b, 1.0, white_cursor);
}
