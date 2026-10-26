shader_type canvas_item;

uniform float scanline_count : hint_range(100.0, 1000.0) = 400.0;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4;
uniform vec4 scanline_color : source_color = vec4(0.0, 0.94, 1.0, 0.04);

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// Scanlines effect
	float scanline = sin(uv.y * scanline_count * 3.14159) * 0.5 + 0.5;
	vec4 scanline_result = scanline_color * scanline;
	
	// Vignette effect
	vec2 center_uv = uv - vec2(0.5);
	float dist = length(center_uv);
	float vignette = smoothstep(0.3, 0.8, dist) * vignette_intensity;
	vec4 vignette_color = vec4(0.0, 0.0, 0.05, vignette);
	
	COLOR = scanline_result + vignette_color;
}
