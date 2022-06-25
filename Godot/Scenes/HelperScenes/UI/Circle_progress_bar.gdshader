shader_type canvas_item;

uniform float value: hint_range(0, 100); // %
uniform float thickness: hint_range(0, 100) = 30.; // % thickness
uniform sampler2D fg: hint_albedo;
uniform sampler2D bg: hint_black_albedo;
uniform float offset: hint_range(0, 100); // %
uniform float smoothing: hint_range(0, 100) = 5.;

void fragment() {
	vec2 point = UV - vec2(0.5);
	float PI = 3.14159265358979323846;
	float ang = (1. - atan(point.x, point.y) / PI) * 50. - offset;
	if (ang < 0.)
		ang += 100.;
	float s = smoothing / 1000.;
	float k = PI / 2. / s;
	float r1 = .5 - thickness / 200.;
	float r2 = .5;
	float r = length(point);
	float uy = (r2 - r) / (r2 - r1);
	if (r > r2 || r < r1)
		COLOR.a = 0.;
	else {
		if (ang <= value) 
			COLOR = texture(fg, vec2(ang / 100., uy));
		else
			COLOR = texture(bg, vec2(ang / 100., uy));
		if ((r2 - r) < s)
			COLOR.a = sin((r2 - r) * k);
		if ((r - r1) < s)
			COLOR.a = sin((r - r1) * k);
	}
}