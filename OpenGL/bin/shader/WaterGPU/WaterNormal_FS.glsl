#version 330 core
precision highp float;

layout(location=0)out	vec4	outColor;

uniform		sampler2D	g_BaseMap;
uniform		float		g_MeshInterval;
in		vec2	v_fragCoord;

void	main()
{
	vec2	pixelSize = 1.0/vec2(128.0);//textureSize(g_BaseMap,0);
	float	y = texture(g_BaseMap,v_fragCoord).x;

	outColor = vec4(
				y - texture(g_BaseMap,v_fragCoord - vec2(pixelSize.x,0.0)).x,
				g_MeshInterval,
				y - texture(g_BaseMap,v_fragCoord - vec2(0.0,pixelSize.y)).x,
				0.0
			);
}