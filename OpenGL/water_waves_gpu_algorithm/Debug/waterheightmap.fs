#version 120

uniform sampler2D WaterHeightMap;

uniform float ODWHMR;
uniform vec4 g_WaterParam;

void main()
{
	vec2		v_fragCoord = gl_TexCoord[0].st;
	vec2 vh = texture2D(WaterHeightMap, v_fragCoord).rg;

	float force = 0.0;

	force += texture2D(WaterHeightMap, v_fragCoord - vec2(ODWHMR, ODWHMR)).r ;
	force += texture2D(WaterHeightMap, v_fragCoord - vec2(0.0, ODWHMR)).r - vh.r;
	force += texture2D(WaterHeightMap, v_fragCoord + vec2(ODWHMR, -ODWHMR)).r ;

	force += texture2D(WaterHeightMap, v_fragCoord - vec2(ODWHMR, 0.0)).r ;
	force += texture2D(WaterHeightMap, v_fragCoord + vec2(ODWHMR, 0.0)).r ;

	force += texture2D(WaterHeightMap, v_fragCoord + vec2(-ODWHMR, ODWHMR)).r ;
	force += texture2D(WaterHeightMap, v_fragCoord + vec2(0.0, ODWHMR)).r ;
	force +=  texture2D(WaterHeightMap, v_fragCoord + vec2(ODWHMR, ODWHMR)).r ;

	force = force * 0.125 - vh.r;

	vh.g += force;
	vh.g *= 0.99;
	vh.r += vh.g;

	if(g_WaterParam.w>0.0)
	{
			float d = distance(v_fragCoord, g_WaterParam.xy);
			vh.r -= 4.0 * max(g_WaterParam.z - d, 0.0) * g_WaterParam.w;
	}

	gl_FragColor = vec4(vh, 0.0, 0.0);
}
