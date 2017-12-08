#version 120

uniform sampler2D WaterHeightMap;

uniform float ODWNMR, WMSDWNMRM2;

void main()
{
	float y[4];

	y[0] = texture2D(WaterHeightMap, gl_TexCoord[0].st + vec2(ODWNMR, 0.0)).r;
	y[1] = texture2D(WaterHeightMap, gl_TexCoord[0].st + vec2(0.0, ODWNMR)).r;
	y[2] = texture2D(WaterHeightMap, gl_TexCoord[0].st - vec2(ODWNMR, 0.0)).r;
	y[3] = texture2D(WaterHeightMap, gl_TexCoord[0].st - vec2(0.0, ODWNMR)).r;

	vec3 Normal = normalize(vec3(y[2] - y[0], WMSDWNMRM2, y[1] - y[3]));

	gl_FragColor = vec4(Normal, 1.0);
}
