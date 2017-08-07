#version 330 core
precision highp float;

layout(location=0)out		vec4		outColor;

uniform		sampler2D		g_BaseMap;
uniform		vec4			g_WaterParam;
uniform		vec2			g_MeshSize;

in		vec2	v_fragCoord;

void	main()
{
	float	velocity = 0.0;
	vec2	pixelSize = 1.0/vec2(128.0);//1.0 / textureSize(g_BaseMap,0);
	velocity += texture(g_BaseMap,v_fragCoord + vec2(0.0,-pixelSize.y)).x;//bottom
	velocity += texture(g_BaseMap,v_fragCoord + vec2(pixelSize.x,0.0)).x;//right
	velocity += texture(g_BaseMap,v_fragCoord + vec2(0.0,pixelSize.y)).x;//top
	velocity += texture(g_BaseMap,v_fragCoord + vec2(-pixelSize.x,0.0)).x;//left

	vec2	heightField = texture(g_BaseMap,v_fragCoord).xy;

	heightField.y += velocity * 0.25 - heightField.x;
	heightField.y *= 0.99;
	heightField.x += heightField.y ;
	if(g_WaterParam.w > 0)
	{

		float	S = g_WaterParam.w * max(g_WaterParam.z - length(g_MeshSize * v_fragCoord - g_WaterParam.xy),0.0);
		heightField.x -= S;
	}
	outColor = vec4(heightField,0.0,0.0);
}