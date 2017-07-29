#version 120

#define MAX_WAVES 16

struct CWave
{
	float StartTime, Speed, MaxY, FrequencyMPIM2;
	vec2 Position;
};

uniform float Time, WaterLevel, WMSDWMR, WMSDWMRM2;
uniform mat3x3 NormalMatrix;
uniform CWave Waves[MAX_WAVES];

varying vec3 Position, Normal;

void main()
{
	vec3 Vertices[5];

	Vertices[0] = vec3(gl_Vertex.x + WMSDWMR, WaterLevel, gl_Vertex.y);
	Vertices[1] = vec3(gl_Vertex.x, WaterLevel, gl_Vertex.y - WMSDWMR);
	Vertices[2] = vec3(gl_Vertex.x - WMSDWMR, WaterLevel, gl_Vertex.y);
	Vertices[3] = vec3(gl_Vertex.x, WaterLevel, gl_Vertex.y + WMSDWMR);

	Vertices[4] = vec3(gl_Vertex.x, WaterLevel, gl_Vertex.y);

	for(int wi = 0; wi < MAX_WAVES; wi++)
	{
		for(int vi = 0; vi < 5; vi++)
		{
			float d = distance(Waves[wi].Position, Vertices[vi].xz);
			float t = Time - Waves[wi].StartTime - d / Waves[wi].Speed;

			if(t > 0.0)
			{
				float maxy = Waves[wi].MaxY/(1.0+t);//Waves[wi].MaxY - Waves[wi].MaxY * t;
				Vertices[vi].y -= sin(t * Waves[wi].FrequencyMPIM2) * maxy / (1.0 + d);
			}
		}
	}

	Position = Vertices[4];

	Normal = NormalMatrix * vec3(Vertices[2].y - Vertices[0].y, WMSDWMRM2, Vertices[1].y - Vertices[3].y);

	gl_TexCoord[0] = gl_ModelViewProjectionMatrix * vec4(Position, 1.0);
	gl_Position = gl_TexCoord[0];
}
