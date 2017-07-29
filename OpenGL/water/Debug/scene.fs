#version 120

uniform int ClipType, Texturing;
uniform float WaterLevel;
uniform sampler2D Texture;

varying vec3 Position, Normal;

void main()
{
	if(ClipType == 1) if(Position.y < WaterLevel) discard;
	if(ClipType == 2) if(Position.y > WaterLevel) discard;

	vec3 LightDirection = gl_LightSource[0].position.xyz - Position;

	float LightDistance2 = dot(LightDirection, LightDirection);
	float LightDistance = sqrt(LightDistance2);

	LightDirection /= LightDistance;

	float NdotLD = max(0.0, dot(Normal, LightDirection));

	float att = gl_LightSource[0].constantAttenuation;
	att += gl_LightSource[0].linearAttenuation * LightDistance;
	att += gl_LightSource[0].quadraticAttenuation * LightDistance2;

	vec3 Light = (gl_LightSource[0].ambient.rgb + gl_LightSource[0].diffuse.rgb * NdotLD) / att;

	gl_FragColor = gl_Color;
	if(Texturing == 1) gl_FragColor.rgb *= texture2D(Texture, gl_TexCoord[0].st).rgb;
	gl_FragColor.rgb *= Light;
}
