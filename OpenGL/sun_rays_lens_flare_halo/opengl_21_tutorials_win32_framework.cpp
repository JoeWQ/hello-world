#include "opengl_21_tutorials_win32_framework.h"

// ----------------------------------------------------------------------------------------------------------------------------

CBuffer::CBuffer()
{
	SetDefaults();
}

CBuffer::~CBuffer()
{
	Empty();
}

void CBuffer::AddData(void *Data, int DataSize)
{
	int Remaining = BufferSize - Position;

	if(DataSize > Remaining)
	{
		BYTE *OldBuffer = Buffer;
		int OldBufferSize = BufferSize;

		int Needed = DataSize - Remaining;

		BufferSize += Needed > BUFFER_SIZE_INCREMENT ? Needed : BUFFER_SIZE_INCREMENT;

		Buffer = new BYTE[BufferSize];

		memcpy(Buffer, OldBuffer, OldBufferSize);

		delete [] OldBuffer;
	}

	memcpy(Buffer + Position, Data, DataSize);

	Position += DataSize;
}

void CBuffer::Empty()
{
	delete [] Buffer;

	SetDefaults();
}

void *CBuffer::GetData()
{
	return Buffer;
}

int CBuffer::GetDataSize()
{
	return Position;
}

void CBuffer::SetDefaults()
{
	Buffer = NULL;

	BufferSize = 0;
	Position = 0;
}

// ----------------------------------------------------------------------------------------------------------------------------

int gl_max_texture_size = 0, gl_max_texture_max_anisotropy_ext = 0;

// ----------------------------------------------------------------------------------------------------------------------------

CTexture::CTexture()
{
	Texture = 0;
}

CTexture::~CTexture()
{
}

CTexture::operator GLuint ()
{
	return Texture;
}

bool CTexture::LoadTexture2D(char *FileName)
{
	CString DirectoryFileName = ModuleDirectory + FileName;

	int Width, Height, BPP;

	FIBITMAP *dib = GetBitmap(DirectoryFileName, Width, Height, BPP);

	if(dib == NULL)
	{
		ErrorLog.Append("Error loading texture " + DirectoryFileName + "!\r\n");
		return false;
	}

	GLenum Format = 0;

	if(BPP == 32) Format = GL_BGRA;
	if(BPP == 24) Format = GL_BGR;

	if(Format == 0)
	{
		ErrorLog.Append("Unsupported texture format (%s)!\r\n", FileName);
		FreeImage_Unload(dib);
		return false;
	}

	Destroy();

	glGenTextures(1, &Texture);

	glBindTexture(GL_TEXTURE_2D, Texture);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	if(GLEW_EXT_texture_filter_anisotropic)
	{
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, gl_max_texture_max_anisotropy_ext);
	}

	glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, Format, GL_UNSIGNED_BYTE, FreeImage_GetBits(dib));

	glBindTexture(GL_TEXTURE_2D, 0);

	FreeImage_Unload(dib);

	return true;
}

bool CTexture::LoadTextureCubeMap(char **FileNames)
{
	int Width, Height, BPP;

	FIBITMAP *dib[6];

	bool Error = false;
	
	for(int i = 0; i < 6; i++)
	{
		CString DirectoryFileName = ModuleDirectory + FileNames[i];

		dib[i] = GetBitmap(DirectoryFileName, Width, Height, BPP);

		if(dib[i] == NULL)
		{
			ErrorLog.Append("Error loading texture " + DirectoryFileName + "!\r\n");
			Error = true;
		}
	}

	if(Error)
	{
		for(int i = 0; i < 6; i++)
		{
			FreeImage_Unload(dib[i]);
		}

		return false;
	}

	GLenum Format = 0;
	
	if(BPP == 32) Format = GL_BGRA;
	if(BPP == 24) Format = GL_BGR;

	if(Format == 0)
	{
		ErrorLog.Append("Unsupported texture format (%s)!\r\n", FileNames[5]);

		for(int i = 0; i < 6; i++)
		{
			FreeImage_Unload(dib[i]);
		}

		return false;
	}

	Destroy();

	glGenTextures(1, &Texture);

	glBindTexture(GL_TEXTURE_CUBE_MAP, Texture);

	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	if(GLEW_EXT_texture_filter_anisotropic)
	{
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAX_ANISOTROPY_EXT, gl_max_texture_max_anisotropy_ext);
	}

	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_GENERATE_MIPMAP, GL_TRUE);

	for(int i = 0; i < 6; i++)
	{
		glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGBA8, Width, Height, 0, Format, GL_UNSIGNED_BYTE, FreeImage_GetBits(dib[i]));
	}

	glBindTexture(GL_TEXTURE_CUBE_MAP, 0);

	for(int i = 0; i < 6; i++)
	{
		FreeImage_Unload(dib[i]);
	}

	return true;
}

void CTexture::Destroy()
{
	glDeleteTextures(1, &Texture);
	Texture = 0;
}

FIBITMAP *CTexture::GetBitmap(char *FileName, int &Width, int &Height, int &BPP)
{
	FREE_IMAGE_FORMAT fif = FreeImage_GetFileType(FileName);

	if(fif == FIF_UNKNOWN)
	{
		fif = FreeImage_GetFIFFromFilename(FileName);
	}

	if(fif == FIF_UNKNOWN)
	{
		return NULL;
	}

	FIBITMAP *dib = NULL;

	if(FreeImage_FIFSupportsReading(fif))
	{
		dib = FreeImage_Load(fif, FileName);
	}

	if(dib != NULL)
	{
		int OriginalWidth = FreeImage_GetWidth(dib);
		int OriginalHeight = FreeImage_GetHeight(dib);

		Width = OriginalWidth;
		Height = OriginalHeight;

		if(Width == 0 || Height == 0)
		{
			FreeImage_Unload(dib);
			return NULL;
		}

		BPP = FreeImage_GetBPP(dib);

		if(Width > gl_max_texture_size) Width = gl_max_texture_size;
		if(Height > gl_max_texture_size) Height = gl_max_texture_size;

		if(!GLEW_ARB_texture_non_power_of_two)
		{
			Width = 1 << (int)floor((log((float)Width) / log(2.0f)) + 0.5f); 
			Height = 1 << (int)floor((log((float)Height) / log(2.0f)) + 0.5f);
		}

		if(Width != OriginalWidth || Height != OriginalHeight)
		{
			FIBITMAP *rdib = FreeImage_Rescale(dib, Width, Height, FILTER_BICUBIC);
			FreeImage_Unload(dib);
			dib = rdib;
		}
	}

	return dib;
}

// ----------------------------------------------------------------------------------------------------------------------------

CShaderProgram::CShaderProgram()
{
	SetDefaults();
}

CShaderProgram::~CShaderProgram()
{
}

CShaderProgram::operator GLuint ()
{
	return Program;
}

bool CShaderProgram::Load(char *VertexShaderFileName, char *FragmentShaderFileName)
{
	bool Error = false;

	Destroy();

	Error |= ((VertexShader = LoadShader(VertexShaderFileName, GL_VERTEX_SHADER)) == 0);
	Error |= ((FragmentShader = LoadShader(FragmentShaderFileName, GL_FRAGMENT_SHADER)) == 0);

	if(Error)
	{
		Destroy();
		return false;
	}

	Program = glCreateProgram();
	glAttachShader(Program, VertexShader);
	glAttachShader(Program, FragmentShader);
	glLinkProgram(Program);

	int LinkStatus;
	glGetProgramiv(Program, GL_LINK_STATUS, &LinkStatus);

	if(LinkStatus == GL_FALSE)
	{
		ErrorLog.Append("Error linking program (%s, %s)!\r\n", VertexShaderFileName, FragmentShaderFileName);

		int InfoLogLength = 0;
		glGetProgramiv(Program, GL_INFO_LOG_LENGTH, &InfoLogLength);
	
		if(InfoLogLength > 0)
		{
			char *InfoLog = new char[InfoLogLength];
			int CharsWritten  = 0;
			glGetProgramInfoLog(Program, InfoLogLength, &CharsWritten, InfoLog);
			ErrorLog.Append(InfoLog);
			delete [] InfoLog;
		}

		Destroy();

		return false;
	}

	return true;
}

void CShaderProgram::Destroy()
{
	glDetachShader(Program, VertexShader);
	glDetachShader(Program, FragmentShader);

	glDeleteShader(VertexShader);
	glDeleteShader(FragmentShader);

	glDeleteProgram(Program);

	delete [] UniformLocations;
	delete [] AttribLocations;

	SetDefaults();
}

GLuint CShaderProgram::LoadShader(char *FileName, GLenum Type)
{
	CString DirectoryFileName = ModuleDirectory + FileName;

	FILE *File;

	if(fopen_s(&File, DirectoryFileName, "rb") != 0)
	{
		ErrorLog.Append("Error loading file " + DirectoryFileName + "!\r\n");
		return 0;
	}

	fseek(File, 0, SEEK_END);
	long Size = ftell(File);
	fseek(File, 0, SEEK_SET);
	char *Source = new char[Size + 1];
	fread(Source, 1, Size, File);
	fclose(File);
	Source[Size] = 0;

	GLuint Shader = glCreateShader(Type);

	glShaderSource(Shader, 1, (const char**)&Source, NULL);
	delete [] Source;
	glCompileShader(Shader);

	int CompileStatus;
	glGetShaderiv(Shader, GL_COMPILE_STATUS, &CompileStatus);

	if(CompileStatus == GL_FALSE)
	{
		ErrorLog.Append("Error compiling shader %s!\r\n", FileName);

		int InfoLogLength = 0;
		glGetShaderiv(Shader, GL_INFO_LOG_LENGTH, &InfoLogLength);
	
		if(InfoLogLength > 0)
		{
			char *InfoLog = new char[InfoLogLength];
			int CharsWritten  = 0;
			glGetShaderInfoLog(Shader, InfoLogLength, &CharsWritten, InfoLog);
			ErrorLog.Append(InfoLog);
			delete [] InfoLog;
		}

		glDeleteShader(Shader);

		return 0;
	}

	return Shader;
}

void CShaderProgram::SetDefaults()
{
	VertexShader = 0;
	FragmentShader = 0;

	Program = 0;

	UniformLocations = NULL;
	AttribLocations = NULL;
}

// ----------------------------------------------------------------------------------------------------------------------------

CCamera::CCamera()
{
	ViewMatrix = NULL;
	ViewMatrixInverse = NULL;

	X = vec3(1.0f, 0.0f, 0.0f);
	Y = vec3(0.0f, 1.0f, 0.0f);
	Z = vec3(0.0f, 0.0f, 1.0f);

	Position = vec3(0.0f, 0.0f, 5.0f);
	Reference = vec3(0.0f, 0.0f, 0.0f);
}

CCamera::~CCamera()
{
}

void CCamera::Look(const vec3 &Position, const vec3 &Reference, bool RotateAroundReference)
{
	this->Position = Position;
	this->Reference = Reference;

	Z = normalize(Position - Reference);
	X = normalize(cross(vec3(0.0f, 1.0f, 0.0f), Z));
	Y = cross(Z, X);

	if(!RotateAroundReference)
	{
		this->Reference = this->Position;
		this->Position += Z * 0.05f;
	}

	CalculateViewMatrix();
}

void CCamera::Move(const vec3 &Movement)
{
	Position += Movement;
	Reference += Movement;

	CalculateViewMatrix();
}

vec3 CCamera::OnKeys(BYTE Keys, float FrameTime)
{
	float Speed = 5.0f;

	if(Keys & 0x40) Speed *= 2.0f;
	if(Keys & 0x80) Speed *= 0.5f;

	float Distance = Speed * FrameTime;

	vec3 Up(0.0f, 1.0f, 0.0f);
	vec3 Right = X;
	vec3 Forward = cross(Up, Right);

	Up *= Distance;
	Right *= Distance;
	Forward *= Distance;

	vec3 Movement;

	if(Keys & 0x01) Movement += Forward;
	if(Keys & 0x02) Movement -= Forward;
	if(Keys & 0x04) Movement -= Right;
	if(Keys & 0x08) Movement += Right;
	if(Keys & 0x10) Movement += Up;
	if(Keys & 0x20) Movement -= Up;

	return Movement;
}

void CCamera::OnMouseMove(int dx, int dy)
{
	float Sensitivity = 0.25f;

	Position -= Reference;

	if(dx != 0)
	{
		float DeltaX = (float)dx * Sensitivity;

		X = rotate(X, DeltaX, vec3(0.0f, 1.0f, 0.0f));
		Y = rotate(Y, DeltaX, vec3(0.0f, 1.0f, 0.0f));
		Z = rotate(Z, DeltaX, vec3(0.0f, 1.0f, 0.0f));
	}

	if(dy != 0)
	{
		float DeltaY = (float)dy * Sensitivity;

		Y = rotate(Y, DeltaY, X);
		Z = rotate(Z, DeltaY, X);

		if(Y.y < 0.0f)
		{
			Z = vec3(0.0f, Z.y > 0.0f ? 1.0f : -1.0f, 0.0f);
			Y = cross(Z, X);
		}
	}

	Position = Reference + Z * length(Position);

	CalculateViewMatrix();
}

void CCamera::OnMouseWheel(float zDelta)
{
	Position -= Reference;

	if(zDelta < 0 && length(Position) < 500.0f)
	{
		Position += Position * 0.1f;
	}

	if(zDelta > 0 && length(Position) > 0.05f)
	{
		Position -= Position * 0.1f;
	}

	Position += Reference;

	CalculateViewMatrix();
}

void CCamera::SetViewMatrixPointer(float *ViewMatrix, float *ViewMatrixInverse)
{
	this->ViewMatrix = (mat4x4*)ViewMatrix;
	this->ViewMatrixInverse = (mat4x4*)ViewMatrixInverse;

	CalculateViewMatrix();
}

void CCamera::CalculateViewMatrix()
{
	if(ViewMatrix != NULL)
	{
		*ViewMatrix = mat4x4(X.x, Y.x, Z.x, 0.0f, X.y, Y.y, Z.y, 0.0f, X.z, Y.z, Z.z, 0.0f, -dot(X, Position), -dot(Y, Position), -dot(Z, Position), 1.0f);

		if(ViewMatrixInverse != NULL)
		{
			*ViewMatrixInverse = inverse(*ViewMatrix);
		}
	}
}

// ----------------------------------------------------------------------------------------------------------------------------

CCamera Camera;

// ----------------------------------------------------------------------------------------------------------------------------

COpenGLRenderer::COpenGLRenderer()
{
	Camera.SetViewMatrixPointer(&ViewMatrix);
}

COpenGLRenderer::~COpenGLRenderer()
{
}

bool COpenGLRenderer::Init()
{
	bool Error = false;

	if(!GLEW_ARB_texture_non_power_of_two)
	{
		ErrorLog.Append("GL_ARB_texture_non_power_of_two not supported!\r\n");
		Error = true;
	}

	if(!GLEW_ARB_depth_texture)
	{
		ErrorLog.Append("GL_ARB_depth_texture not supported!\r\n");
		Error = true;
	}

	if(!GLEW_EXT_framebuffer_object)
	{
		ErrorLog.Append("GL_EXT_framebuffer_object not supported!\r\n");
		Error = true;
	}

	Error |= !DirtTexture.LoadTexture2D("lensdirt_lowc.jpg");

	Error |= !SunDepthTest.Load("sundepthtest.vs", "sundepthtest.fs");
	Error |= !BlurH.Load("blur.vs", "blurh.fs");
	Error |= !BlurV.Load("blur.vs", "blurv.fs");
	Error |= !SunRaysLensFlareHalo.Load("sunrayslensflarehalo.vs", "sunrayslensflarehalo.fs");

	if(Error)
	{
		return false;
	}

	glUseProgram(SunDepthTest);
	glUniform1i(glGetUniformLocation(SunDepthTest, "SunTexture"), 0);
	glUniform1i(glGetUniformLocation(SunDepthTest, "SunDepthTexture"), 1);
	glUniform1i(glGetUniformLocation(SunDepthTest, "DepthTexture"), 2);
	glUseProgram(0);

	glUseProgram(SunRaysLensFlareHalo);
	glUniform1i(glGetUniformLocation(SunRaysLensFlareHalo, "LowBlurredSunTexture"), 0);
	glUniform1i(glGetUniformLocation(SunRaysLensFlareHalo, "HighBlurredSunTexture"), 1);
	glUniform1i(glGetUniformLocation(SunRaysLensFlareHalo, "DirtTexture"), 2);
	glUniform1f(glGetUniformLocation(SunRaysLensFlareHalo, "Dispersal"), 0.1875f);// 3/16
	glUniform1f(glGetUniformLocation(SunRaysLensFlareHalo, "HaloWidth"), 0.45f);
	glUniform1f(glGetUniformLocation(SunRaysLensFlareHalo, "Intensity"), 1.5f);
	glUniform3f(glGetUniformLocation(SunRaysLensFlareHalo, "Distortion"), 0.94f, 0.97f, 1.00f);//扭曲
	glUseProgram(0);

	//glGenTextures(1, &ScreenTexture);
	glGenTextures(1, &DepthTexture);
	glGenTextures(5, SunTextures);

	glGenFramebuffersEXT(1, &FBO);

	Camera.Look(vec3(0.5f, 0.25f, 2.5f) * 2.5f, vec3(0.0f, 0.0f, 0.0f), true);

	GLfloat LightModelAmbient[] = {0.0f, 0.0f, 0.0f, 1.0f};
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, LightModelAmbient);

	GLfloat LightAmbient[] = {0.25f, 0.25f, 0.25f, 1.0f};
	glLightfv(GL_LIGHT0, GL_AMBIENT, LightAmbient);

	GLfloat LightDiffuse[] = {0.75f, 0.75f, 0.75f, 1.0f};
	glLightfv(GL_LIGHT0, GL_DIFFUSE, LightDiffuse);

	GLfloat MaterialAmbient[] = {1.0f, 1.0f, 1.0f, 1.0f};
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, MaterialAmbient);

	GLfloat MaterialDiffuse[] = {1.0f, 1.0f, 1.0f, 1.0f};
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, MaterialDiffuse);

	glEnable(GL_LIGHT0);
	glEnable(GL_COLOR_MATERIAL);

	return true;
}

void COpenGLRenderer::Render(float FrameTime)
{
	const float SunR = 3.75f;
	vec3 SunPos = /*Camera.Position +*/ vec3(0.0f, 0.0f, -100.0f);

	glViewport(0, 0, Width, Height);
	
	//glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
	//glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, ScreenTexture, 0);
	//glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, DepthTexture, 0);

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(&ProjectionMatrix);

	//glMatrixMode(GL_MODELVIEW);
	//glLoadMatrixf(&ViewMatrix);

	//glLightfv(GL_LIGHT0, GL_POSITION, &vec4(SunPos, 1.0f));

	//glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	//glEnable(GL_LIGHTING);

	//glColor3f(1.0f, 1.0f, 1.0f);
	//
	//GLUquadric *obj = gluNewQuadric();

	//for(int z = -2; z <= 2; z += 1)
	//{
	//	for(int x = -2; x <= 2; x += 1)
	//	{
	//		glMatrixMode(GL_MODELVIEW);
	//		glLoadMatrixf(&ViewMatrix);
	//		glTranslatef((float)x, -0.5f, (float)z);
	//		gluSphere(obj, 0.25f, 32, 32);
	//	}
	//}

	//gluDeleteQuadric(obj);

	//glDisable(GL_LIGHTING);
	//glDisable(GL_CULL_FACE);
	//glDisable(GL_DEPTH_TEST);

	//glBindTexture(GL_TEXTURE_2D, DepthTexture);
	//glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, Width, Height);
	//glBindTexture(GL_TEXTURE_2D, 0);

	//glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

	bool CalculateSunRaysLensFlareHalo = false;
	int Test = 0, Tests = 16;
	float Angle = 0.0f, AngleInc = 360.0f / Tests;
	//偏置矩阵,将规范化后的坐标转换到屏幕坐标
	mat4x4 VPB = BiasMatrix * ProjectionMatrix * ViewMatrix;
	//此段代码的意思是,散发的辉光如果有一块部分处于屏幕空间之内,就渲染Shader,否则如果没有任何的辉光处于屏幕范围之内,就没有必要渲染了
	while(Test < Tests && !CalculateSunRaysLensFlareHalo)
	{
		vec4 SunPosProj = VPB * vec4(SunPos + rotate(Camera.X, Angle, Camera.Z) * SunR, 1.0f);
		SunPosProj /= SunPosProj.w;

		CalculateSunRaysLensFlareHalo |= (SunPosProj.x >= 0.0f && SunPosProj.x <= 1.0f && SunPosProj.y >= 0.0f && SunPosProj.y <= 1.0f && 
					SunPosProj.z >= 0.0f && SunPosProj.z <= 1.0f);//深度值处于偏置之后的NDC

		Angle += AngleInc;
		Test++;
	}
	//如果确定了要渲染辉光
	if(CalculateSunRaysLensFlareHalo)
	{
		//计算太阳的屏幕空间坐标
		vec4 SunPosProj = VPB * vec4(SunPos, 1.0f);
		SunPosProj /= SunPosProj.w;

		glViewport(0, 0, SunTextureWidth, SunTextureHeight);

		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, SunTextures[1], 0);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, SunTextures[4], 0);

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		glMatrixMode(GL_MODELVIEW);
		glLoadMatrixf(&ViewMatrix);
		glTranslatef(SunPos.x, SunPos.y, SunPos.z);
		glColor3f(1.0f, 0.90f, 0.80f);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		GLUquadric *obj = gluNewQuadric();
		gluSphere(obj, SunR, 16, 16);
		gluDeleteQuadric(obj);
		glDisable(GL_CULL_FACE);
		glDisable(GL_DEPTH_TEST);

		//glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
		//glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, SunTextures[0], 0);
		//glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
		////以同一个视角比较太阳光与物体的渲染深度
		//glActiveTexture(GL_TEXTURE0); glBindTexture(GL_TEXTURE_2D, SunTextures[1]);
		//glActiveTexture(GL_TEXTURE1); glBindTexture(GL_TEXTURE_2D, SunTextures[4]);
		//glActiveTexture(GL_TEXTURE2); glBindTexture(GL_TEXTURE_2D, DepthTexture);
		//glUseProgram(SunDepthTest);
		//glBegin(GL_QUADS);
		//	glVertex2f(0.0f, 0.0f);
		//	glVertex2f(1.0f, 0.0f);
		//	glVertex2f(1.0f, 1.0f);
		//	glVertex2f(0.0f, 1.0f);
		//glEnd();
		//glUseProgram(0);
		//glActiveTexture(GL_TEXTURE2); glBindTexture(GL_TEXTURE_2D, 0);
		//glActiveTexture(GL_TEXTURE1); glBindTexture(GL_TEXTURE_2D, 0);
		//glActiveTexture(GL_TEXTURE0); glBindTexture(GL_TEXTURE_2D, 0);

		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, SunTextures[2], 0);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);

		glBindTexture(GL_TEXTURE_2D, SunTextures[1]);// SunTextures[0]);
		glUseProgram(BlurH);
		glUniform1i(glGetUniformLocation(BlurH, "Width"), 1);
		glBegin(GL_QUADS);
			glVertex2f(0.0f, 0.0f);
			glVertex2f(1.0f, 0.0f);
			glVertex2f(1.0f, 1.0f);
			glVertex2f(0.0f, 1.0f);
		glEnd();
		glUseProgram(0);
		glBindTexture(GL_TEXTURE_2D, 0);

		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, SunTextures[3],0);// SunTextures[1], 0);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, 0, 0);

		glBindTexture(GL_TEXTURE_2D, SunTextures[2]);
		glUseProgram(BlurV);
		glUniform1i(glGetUniformLocation(BlurV, "Width"), 1);
		glBegin(GL_QUADS);
			glVertex2f(0.0f, 0.0f);
			glVertex2f(1.0f, 0.0f);
			glVertex2f(1.0f, 1.0f);
			glVertex2f(0.0f, 1.0f);
		glEnd();
		glUseProgram(0);
		glBindTexture(GL_TEXTURE_2D, 0);

		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, SunTextures[0],0);// SunTextures[3], 0);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, 0, 0);

		glBindTexture(GL_TEXTURE_2D, SunTextures[1]);// SunTextures[0]);
		glUseProgram(BlurH);
		glUniform1i(glGetUniformLocation(BlurH, "Width"), 10);
		glBegin(GL_QUADS);
			glVertex2f(0.0f, 0.0f);
			glVertex2f(1.0f, 0.0f);
			glVertex2f(1.0f, 1.0f);
			glVertex2f(0.0f, 1.0f);
		glEnd();
		glUseProgram(0);
		glBindTexture(GL_TEXTURE_2D, 0);

		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, SunTextures[2], 0);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, 0, 0);

		glBindTexture(GL_TEXTURE_2D, SunTextures[0]);// SunTextures[3]);
		glUseProgram(BlurV);
		glUniform1i(glGetUniformLocation(BlurV, "Width"), 10);
		glBegin(GL_QUADS);
			glVertex2f(0.0f, 0.0f);
			glVertex2f(1.0f, 0.0f);
			glVertex2f(1.0f, 1.0f);
			glVertex2f(0.0f, 1.0f);
		glEnd();
		glUseProgram(0);
		glBindTexture(GL_TEXTURE_2D, 0);

		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, SunTextures[0],0);// SunTextures[3], 0);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, 0, 0);

		glActiveTexture(GL_TEXTURE0); glBindTexture(GL_TEXTURE_2D, SunTextures[3]);// SunTextures[1]);//0
		glActiveTexture(GL_TEXTURE1); glBindTexture(GL_TEXTURE_2D, SunTextures[2]);//1
		glActiveTexture(GL_TEXTURE2); glBindTexture(GL_TEXTURE_2D, DirtTexture);//2
		glUseProgram(SunRaysLensFlareHalo);
		glUniform2fv(glGetUniformLocation(SunRaysLensFlareHalo, "SunPosProj"), 1, &SunPosProj);
		glBegin(GL_QUADS);
			glVertex2f(0.0f, 0.0f);
			glVertex2f(1.0f, 0.0f);
			glVertex2f(1.0f, 1.0f);
			glVertex2f(0.0f, 1.0f);
		glEnd();
		glUseProgram(0);
		glActiveTexture(GL_TEXTURE2); glBindTexture(GL_TEXTURE_2D, 0);
		glActiveTexture(GL_TEXTURE1); glBindTexture(GL_TEXTURE_2D, 0);
		glActiveTexture(GL_TEXTURE0); glBindTexture(GL_TEXTURE_2D, 0);

		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

		glViewport(0, 0, Width, Height);
	}

	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(&ortho(0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f));

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	/*glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, ScreenTexture);
	glColor3f(1.0f, 1.0f, 1.0f);
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f);
		glTexCoord2f(1.0f, 0.0f); glVertex2f(1.0f, 0.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex2f(1.0f, 1.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, 1.0f);
	glEnd();
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisable(GL_TEXTURE_2D);*/

	if (CalculateSunRaysLensFlareHalo)
	{
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, SunTextures[0]);// SunTextures[3]);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
		glEnable(GL_BLEND);
		glColor3f(1.0f, 1.0f, 1.0f);
		glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f);
		glTexCoord2f(1.0f, 0.0f); glVertex2f(1.0f, 0.0f);
		glTexCoord2f(1.0f, 1.0f); glVertex2f(1.0f, 1.0f);
		glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, 1.0f);
		glEnd();
		glDisable(GL_BLEND);
		glBindTexture(GL_TEXTURE_2D, 0);
		glDisable(GL_TEXTURE_2D);
	}
}

void COpenGLRenderer::Resize(int Width, int Height)
{
	this->Width = Width;
	this->Height = Height;

	ProjectionMatrix = perspective(60.0f, (float)Width / (float)Height, 0.125f, 512.0f);

	/*glBindTexture(GL_TEXTURE_2D, ScreenTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	glBindTexture(GL_TEXTURE_2D, 0);*/

	glBindTexture(GL_TEXTURE_2D, DepthTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT24, Width, Height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
	glBindTexture(GL_TEXTURE_2D, 0);

	SunTextureWidth = Width / 2;
	SunTextureHeight = Height / 2;

	for(int i = 0; i < 4; i++)
	{
		glBindTexture(GL_TEXTURE_2D, SunTextures[i]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, SunTextureWidth, SunTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	glBindTexture(GL_TEXTURE_2D, SunTextures[4]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT24, SunTextureWidth, SunTextureHeight, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
	glBindTexture(GL_TEXTURE_2D, 0);

	glUseProgram(BlurH);
	glUniform1f(glGetUniformLocation(BlurH, "odw"), 1.0f / (float)SunTextureWidth);
	glUseProgram(BlurV);
	glUniform1f(glGetUniformLocation(BlurV, "odh"), 1.0f / (float)SunTextureHeight);
	glUseProgram(0);
}

void COpenGLRenderer::Destroy()
{
	DirtTexture.Destroy();

	//glDeleteTextures(1, &ScreenTexture);
	glDeleteTextures(1, &DepthTexture);
	glDeleteTextures(5, SunTextures);

	SunDepthTest.Destroy();
	BlurH.Destroy();
	BlurV.Destroy();
	SunRaysLensFlareHalo.Destroy();

	if(GLEW_EXT_framebuffer_object)
	{
		glDeleteFramebuffersEXT(1, &FBO);
	}
}

// ----------------------------------------------------------------------------------------------------------------------------

COpenGLRenderer OpenGLRenderer;

// ----------------------------------------------------------------------------------------------------------------------------

CString ModuleDirectory, ErrorLog;

// ----------------------------------------------------------------------------------------------------------------------------

void GetModuleDirectory()
{
	char *moduledirectory = new char[256];
	GetModuleFileName(GetModuleHandle(NULL), moduledirectory, 256);
	*(strrchr(moduledirectory, '\\') + 1) = 0;
	ModuleDirectory = moduledirectory;
	delete [] moduledirectory;
}

// ----------------------------------------------------------------------------------------------------------------------------

COpenGLView::COpenGLView()
{
}

COpenGLView::~COpenGLView()
{
}

bool COpenGLView::Init(HINSTANCE hInstance, char *Title, int Width, int Height, int Samples)
{
	this->Title = Title;
	this->Width = Width;
	this->Height = Height;

	WNDCLASSEX WndClassEx;

	memset(&WndClassEx, 0, sizeof(WNDCLASSEX));

	WndClassEx.cbSize = sizeof(WNDCLASSEX);
	WndClassEx.style = CS_OWNDC | CS_HREDRAW | CS_VREDRAW;
	WndClassEx.lpfnWndProc = WndProc;
	WndClassEx.hInstance = hInstance;
	WndClassEx.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	WndClassEx.hIconSm = LoadIcon(NULL, IDI_APPLICATION);
	WndClassEx.hCursor = LoadCursor(NULL, IDC_ARROW);
	WndClassEx.lpszClassName = "Win32OpenGLWindowClass";

	if(RegisterClassEx(&WndClassEx) == 0)
	{
		ErrorLog.Set("RegisterClassEx failed!");
		return false;
	}

	DWORD Style = WS_OVERLAPPEDWINDOW | WS_CLIPSIBLINGS | WS_CLIPCHILDREN;

	hWnd = CreateWindowEx(WS_EX_APPWINDOW, WndClassEx.lpszClassName, Title, Style, 0, 0, Width, Height, NULL, NULL, hInstance, NULL);

	if(hWnd == NULL)
	{
		ErrorLog.Set("CreateWindowEx failed!");
		return false;
	}

	HDC hDC = GetDC(hWnd);

	if(hDC == NULL)
	{
		ErrorLog.Set("GetDC failed!");
		return false;
	}

	PIXELFORMATDESCRIPTOR pfd;

	memset(&pfd, 0, sizeof(PIXELFORMATDESCRIPTOR));

	pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
	pfd.nVersion = 1;
	pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	pfd.iPixelType = PFD_TYPE_RGBA;
	pfd.cColorBits = 32;
	pfd.cDepthBits = 24;
	pfd.iLayerType = PFD_MAIN_PLANE;

	int PixelFormat = ChoosePixelFormat(hDC, &pfd);

	if(PixelFormat == 0)
	{
		ErrorLog.Set("ChoosePixelFormat failed!");
		return false;
	}

	static int MSAAPixelFormat = 0;

	if(SetPixelFormat(hDC, MSAAPixelFormat == 0 ? PixelFormat : MSAAPixelFormat, &pfd) == FALSE)
	{
		ErrorLog.Set("SetPixelFormat failed!");
		return false;
	}

	hGLRC = wglCreateContext(hDC);

	if(hGLRC == NULL)
	{
		ErrorLog.Set("wglCreateContext failed!");
		return false;
	}

	if(wglMakeCurrent(hDC, hGLRC) == FALSE)
	{
		ErrorLog.Set("wglMakeCurrent failed!");
		return false;
	}

	if(glewInit() != GLEW_OK)
	{
		ErrorLog.Set("glewInit failed!");
		return false;
	}

	if(!GLEW_VERSION_2_1)
	{
		ErrorLog.Set("OpenGL 2.1 not supported!");
		return false;
	}

	if(MSAAPixelFormat == 0 && Samples > 0)
	{
		if(GLEW_ARB_multisample && WGLEW_ARB_pixel_format)
		{
			while(Samples > 0)
			{
				UINT NumFormats = 0;

				int PFAttribs[] =
				{
					WGL_DRAW_TO_WINDOW_ARB, GL_TRUE,
					WGL_SUPPORT_OPENGL_ARB, GL_TRUE,
					WGL_DOUBLE_BUFFER_ARB, GL_TRUE,
					WGL_PIXEL_TYPE_ARB, WGL_TYPE_RGBA_ARB,
					WGL_COLOR_BITS_ARB, 32,
					WGL_DEPTH_BITS_ARB, 24,
					WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB,
					WGL_SAMPLE_BUFFERS_ARB, GL_TRUE,
					WGL_SAMPLES_ARB, Samples,
					0
				};

				if(wglChoosePixelFormatARB(hDC, PFAttribs, NULL, 1, &MSAAPixelFormat, &NumFormats) == TRUE && NumFormats > 0) break;

				Samples--;
			}

			wglDeleteContext(hGLRC);
			DestroyWindow(hWnd);
			UnregisterClass(WndClassEx.lpszClassName, hInstance);

			return Init(hInstance, Title, Width, Height, Samples);
		}
		else
		{
			Samples = 0;
		}
	}

	this->Samples = Samples;

	GetModuleDirectory();

	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &gl_max_texture_size);

	if(GLEW_EXT_texture_filter_anisotropic)
	{
		glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &gl_max_texture_max_anisotropy_ext);
	}

	if(WGLEW_EXT_swap_control)
	{
		wglSwapIntervalEXT(0);
	}

	return OpenGLRenderer.Init();
}

void COpenGLView::Show(bool Maximized)
{
	RECT dRect, wRect, cRect;

	GetWindowRect(GetDesktopWindow(), &dRect);
	GetWindowRect(hWnd, &wRect);
	GetClientRect(hWnd, &cRect);

	wRect.right += Width - cRect.right;
	wRect.bottom += Height - cRect.bottom;
	wRect.right -= wRect.left;
	wRect.bottom -= wRect.top;
	wRect.left = dRect.right / 2 - wRect.right / 2;
	wRect.top = dRect.bottom / 2 - wRect.bottom / 2;

	MoveWindow(hWnd, wRect.left, wRect.top, wRect.right, wRect.bottom, FALSE);

	ShowWindow(hWnd, Maximized ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL);
}

void COpenGLView::MessageLoop()
{
	MSG Msg;

	while(GetMessage(&Msg, NULL, 0, 0) > 0)
	{
		TranslateMessage(&Msg);
		DispatchMessage(&Msg);
	}
}

void COpenGLView::Destroy()
{
	if(GLEW_VERSION_2_1)
	{
		OpenGLRenderer.Destroy();
	}

	wglDeleteContext(hGLRC);
	DestroyWindow(hWnd);
}

void COpenGLView::OnKeyDown(UINT Key)
{
	/*switch(Key)
	{
		case VK_F1:
			break;

		case VK_SPACE:
			break;
	}*/
}

void COpenGLView::OnMouseMove(int X, int Y)
{
	if(GetKeyState(VK_RBUTTON) & 0x80)
	{
		Camera.OnMouseMove(LastX - X, LastY - Y);

		LastX = X;
		LastY = Y;
	}
}

void COpenGLView::OnMouseWheel(short zDelta)
{
	Camera.OnMouseWheel(zDelta);
}

void COpenGLView::OnPaint()
{
	static DWORD LastFPSTime = GetTickCount(), LastFrameTime = LastFPSTime, FPS = 0;

	PAINTSTRUCT ps;

	HDC hDC = BeginPaint(hWnd, &ps);

	DWORD Time = GetTickCount();

	float FrameTime = (Time - LastFrameTime) * 0.001f;

	LastFrameTime = Time;

	if(Time - LastFPSTime > 1000)
	{
		CString Text = Title;

		if(OpenGLRenderer.Text[0] != 0)
		{
			Text.Append(" - " + OpenGLRenderer.Text);
		}

		Text.Append(" - %dx%d", Width, Height);
		Text.Append(", ATF %dx", gl_max_texture_max_anisotropy_ext);
		Text.Append(", MSAA %dx", Samples);
		Text.Append(", FPS: %d", FPS);
		Text.Append(" - %s", glGetString(GL_RENDERER));
		
		SetWindowText(hWnd, Text);

		LastFPSTime = Time;
		FPS = 0;
	}
	else
	{
		FPS++;
	}

	BYTE Keys = 0x00;

	if(GetKeyState('W') & 0x80) Keys |= 0x01;
	if(GetKeyState('S') & 0x80) Keys |= 0x02;
	if(GetKeyState('A') & 0x80) Keys |= 0x04;
	if(GetKeyState('D') & 0x80) Keys |= 0x08;
	if(GetKeyState('R') & 0x80) Keys |= 0x10;
	if(GetKeyState('F') & 0x80) Keys |= 0x20;

	if(GetKeyState(VK_SHIFT) & 0x80) Keys |= 0x40;
	if(GetKeyState(VK_CONTROL) & 0x80) Keys |= 0x80;

	if(Keys & 0x3F)
	{
		Camera.Move(Camera.OnKeys(Keys, FrameTime));
	}

	OpenGLRenderer.Render(FrameTime);

	SwapBuffers(hDC);

	EndPaint(hWnd, &ps);

	InvalidateRect(hWnd, NULL, FALSE);
}

void COpenGLView::OnRButtonDown(int X, int Y)
{
	LastX = X;
	LastY = Y;
}

void COpenGLView::OnSize(int Width, int Height)
{
	this->Width = Width;
	this->Height = Height;

	OpenGLRenderer.Resize(Width, Height);
}

// ----------------------------------------------------------------------------------------------------------------------------

COpenGLView OpenGLView;

// ----------------------------------------------------------------------------------------------------------------------------

LRESULT CALLBACK WndProc(HWND hWnd, UINT uiMsg, WPARAM wParam, LPARAM lParam)
{
	switch(uiMsg)
	{
		case WM_CLOSE:
			PostQuitMessage(0);
			break;

		case WM_MOUSEMOVE:
			OpenGLView.OnMouseMove(LOWORD(lParam), HIWORD(lParam));
			break;

		case 0x020A: // WM_MOUSWHEEL
			OpenGLView.OnMouseWheel(HIWORD(wParam));
			break;

		case WM_KEYDOWN:
			OpenGLView.OnKeyDown((UINT)wParam);
			break;

		case WM_PAINT:
			OpenGLView.OnPaint();
			break;

		case WM_RBUTTONDOWN:
			OpenGLView.OnRButtonDown(LOWORD(lParam), HIWORD(lParam));
			break;

		case WM_SIZE:
			OpenGLView.OnSize(LOWORD(lParam), HIWORD(lParam));
			break;

		default:
			return DefWindowProc(hWnd, uiMsg, wParam, lParam);
	}

	return 0;
}

// ----------------------------------------------------------------------------------------------------------------------------

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR sCmdLine, int iShow)
{
	char *AppName = "Sun rays, lens flare, halo";

	if(OpenGLView.Init(hInstance, AppName, 800, 600, 4))
	{
		OpenGLView.Show();
		OpenGLView.MessageLoop();
	}
	else
	{
		MessageBox(NULL, ErrorLog, AppName, MB_OK | MB_ICONERROR);
	}

	OpenGLView.Destroy();

	return 0;
}
