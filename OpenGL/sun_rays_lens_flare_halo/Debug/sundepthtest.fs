#version 120

uniform sampler2D SunTexture;//0
uniform sampler2D SunDepthTexture;//1
uniform sampler2D DepthTexture;//2

void main()
{
	if(texture2D(DepthTexture, gl_TexCoord[0].st).r < texture2D(SunDepthTexture, gl_TexCoord[0].st).r)
	{
		gl_FragColor = vec4(vec3(0.0), 1.0);
	}
	else
	{
		gl_FragColor = vec4(texture2D(SunTexture, gl_TexCoord[0].st).rgb, 1.0);
	}
}
