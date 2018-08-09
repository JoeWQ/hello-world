#version 330 core
layout(location=0)out	vec2	outColor;
uniform		vec3	g_LightPosition;
in			vec3	v_position;

void	main()
{
	float   length_l = length(v_position - g_LightPosition);
	outColor = vec2(length_l,length_l * length_l);
}