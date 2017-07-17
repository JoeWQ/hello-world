#include "opengl_21_tutorials_win32_framework.h"
#include<assert.h>
// ----------------------------------------------------------------------------------------------------------------------------

CBuffer::CBuffer()
{
	SetDefaults();
}

CBuffer::~CBuffer()
{
	Empty();
}

void CBuffer::SetDefaults()
{
	Buffer = NULL;
	BufferSize = 0;

	Position = 0;
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
	if(Buffer != NULL)
	{
		delete [] Buffer;
	}

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

// ----------------------------------------------------------------------------------------------------------------------------

int gl_max_texture_size = 0, gl_max_texture_max_anisotropy_ext = 0;

// ----------------------------------------------------------------------------------------------------------------------------

CTexture::CTexture()
{
	SetDefaults();
}

CTexture::~CTexture()
{
}

void CTexture::SetDefaults()
{
	Texture = 0;

	Width = 0;
	Height = 0;
}

CTexture::operator GLuint ()
{
	return Texture;
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

	this->Width = Width;
	this->Height = Height;

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

	this->Width = Width;
	this->Height = Height;

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
	if(Texture != 0)
	{
		glDeleteTextures(1, &Texture);
	}

	SetDefaults();
}

int CTexture::GetWidth()
{
	return Width;
}

int CTexture::GetHeight()
{
	return Height;
}

// ----------------------------------------------------------------------------------------------------------------------------

CShaderProgram::CShaderProgram()
{
	SetDefaults();
}

CShaderProgram::~CShaderProgram()
{
}

void CShaderProgram::SetDefaults()
{
	VertexShader = 0;
	FragmentShader = 0;

	Program = 0;

	UniformLocations = NULL;
	AttribLocations = NULL;
}

CShaderProgram::operator GLuint ()
{
	return Program;
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
	if(Program != 0)
	{
		if(VertexShader != 0)
		{
			glDetachShader(Program, VertexShader);
		}

		if(FragmentShader != 0)
		{
			glDetachShader(Program, FragmentShader);
		}
	}

	if(VertexShader != 0)
	{
		glDeleteShader(VertexShader);
	}

	if(FragmentShader)
	{
		glDeleteShader(FragmentShader);
	}

	if(Program != 0)
	{
		glDeleteProgram(Program);
	}

	if(UniformLocations != NULL)
	{
		delete [] UniformLocations;
	}

	if(AttribLocations != NULL)
	{
		delete [] AttribLocations;
	}

	SetDefaults();
}

// ----------------------------------------------------------------------------------------------------------------------------

CCamera::CCamera()
{
	X = vec3(1.0f, 0.0f, 0.0f);
	Y = vec3(0.0f, 1.0f, 0.0f);
	Z = vec3(0.0f, 0.0f, 1.0f);

	Position = vec3(0.0f, 0.0f, 5.0f);
	Reference = vec3(0.0f, 0.0f, 0.0f);

	CalculateViewMatrix();
}

CCamera::~CCamera()
{
}

void CCamera::Look(const vec3 &Position, const vec3 &Reference, bool RotateAroundReference)
{
	this->Position = Position;
	this->Reference = Reference;

	Z = normalize(Position - Reference);

	GetXY(Z, X, Y);

	if(!RotateAroundReference)
	{
		this->Reference = this->Position - Z * 0.05f;
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
	//如果产生了加速
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

	vec3 zdirection = Position - Reference;

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
		//为了防止万相角
		if(Y.y < 0.0f)
		{
			assert(Z.y>0.0f);
			Z = vec3(0.0f, Z.y > 0.0f ? 1.0f : -1.0f, 0.0f);
			Y = cross(Z, X);
		}
	}

	Position = Reference + Z * length(zdirection);

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

void CCamera::SetPerspective(float fovy, float aspect, float n, float f)
{
	ProjectionMatrix = perspective(fovy, aspect, n, f);
	ProjectionMatrixInverse = inverse(ProjectionMatrix);
	ViewProjectionMatrix = ProjectionMatrix * ViewMatrix;
	ViewProjectionMatrixInverse = ViewMatrixInverse * ProjectionMatrixInverse;
}

void CCamera::CalculateViewMatrix()
{
	//注意,这里使用的是列矩阵
	ViewMatrix = mat4x4(X.x, Y.x, Z.x, 0.0f, X.y, Y.y, Z.y, 0.0f, X.z, Y.z, Z.z, 0.0f, -dot(X, Position), -dot(Y, Position), -dot(Z, Position), 1.0f);
	ViewMatrixInverse = inverse(ViewMatrix);
	ViewProjectionMatrix = ProjectionMatrix * ViewMatrix;
	ViewProjectionMatrixInverse = ViewMatrixInverse * ProjectionMatrixInverse;
}

// ----------------------------------------------------------------------------------------------------------------------------

CTerrain::CTerrain()
{
	SetDefaults();
}

CTerrain::~CTerrain()
{
}

void CTerrain::SetDefaults()
{
	Size = 0;
	SizeP1 = 0;
	SizeD2 = 0.0f;

	Min = Max = vec3(0.0f);

	Heights = NULL;

	VerticesCount = 0;
	IndicesCount = 0;

	VertexBufferObject = 0;
	IndexBufferObject = 0;
}

bool CTerrain::LoadTexture2D(char *FileName, float Scale, float Offset)
{
	CTexture Texture;

	if(!Texture.LoadTexture2D(FileName))
	{
		return false;
	}

	if(Texture.GetWidth() != Texture.GetHeight())
	{
		ErrorLog.Append("Unsupported texture dimensions (%s)!\r\n", FileName);
		Texture.Destroy();
		return false;
	}

	Destroy();

	Size = Texture.GetWidth();
	SizeP1 = Size + 1;
	SizeD2 = (float)Size / 2.0f;

	VerticesCount = SizeP1 * SizeP1;

	float *TextureHeights = new float[Size * Size];

	glBindTexture(GL_TEXTURE_2D, Texture);
	glGetTexImage(GL_TEXTURE_2D, 0, GL_GREEN, GL_FLOAT, TextureHeights);
	glBindTexture(GL_TEXTURE_2D, 0);

	Texture.Destroy();

	for(int i = 0; i < Size * Size; i++)
	{
		TextureHeights[i] = TextureHeights[i] * Scale + Offset;
	}

	Heights = new float[VerticesCount];

	int i = 0;

	for(int z = 0; z <= Size; z++)
	{
		for(int x = 0; x <= Size; x++)
		{
			Heights[i++] = GetHeight(TextureHeights, Size, (float)x - 0.5f, (float)z - 0.5f);
		}
	}

	delete [] TextureHeights;

	float *SmoothedHeights = new float[VerticesCount];

	i = 0;

	for(int z = 0; z <= Size; z++)
	{
		for(int x = 0; x <= Size; x++)
		{
			SmoothedHeights[i] = 0.0f;

			SmoothedHeights[i] += GetHeight(x - 1, z + 1) + GetHeight(x, z + 1) * 2 + GetHeight(x + 1, z + 1);
			SmoothedHeights[i] += GetHeight(x - 1, z) * 2 + GetHeight(x, z) * 3 + GetHeight(x + 1, z) * 2;
			SmoothedHeights[i] += GetHeight(x - 1, z - 1) + GetHeight(x, z - 1) * 2 + GetHeight(x + 1, z - 1);

			SmoothedHeights[i] /= 15.0f;

			i++;
		}
	}

	delete [] Heights;

	Heights = SmoothedHeights;

	Min.x = Min.z = -SizeD2;
	Max.x = Max.z = SizeD2;

	Min.y = Max.y = Heights[0];
	//计算地形中的最大最小高度值
	for(int i = 1; i < VerticesCount; i++)
	{
		if(Heights[i] < Min.y) Min.y = Heights[i];
		if(Heights[i] > Max.y) Max.y = Heights[i];
	}

	CVertex *Vertices = new CVertex[VerticesCount];

	i = 0;

	for(int z = 0; z <= Size; z++)
	{
		for(int x = 0; x <= Size; x++)
		{
			Vertices[i].Position = vec3((float)x - SizeD2, Heights[i], SizeD2 - (float)z);
			Vertices[i].Normal = normalize(vec3(GetHeight(x - 1, z) - GetHeight(x + 1, z), 2.0f, GetHeight(x, z + 1) - GetHeight(x, z - 1)));

			i++;
		}
	}

	glGenBuffers(1, &VertexBufferObject);

	glBindBuffer(GL_ARRAY_BUFFER, VertexBufferObject);
	glBufferData(GL_ARRAY_BUFFER, VerticesCount * sizeof(CVertex), Vertices, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	delete [] Vertices;
	//建立地面网格,,,,,,,,计算三角形序列
	IndicesCount = Size * Size * 2 * 3;

	int *Indices = new int[IndicesCount];

	i = 0;

	for(int z = 0; z < Size; z++)
	{
		for(int x = 0; x < Size; x++)
		{
			Indices[i++] = GetIndex(x, z);
			Indices[i++] = GetIndex(x + 1, z);
			Indices[i++] = GetIndex(x + 1, z + 1);

			Indices[i++] = GetIndex(x + 1, z + 1);
			Indices[i++] = GetIndex(x, z + 1);
			Indices[i++] = GetIndex(x, z);
		}
	}

	glGenBuffers(1, &IndexBufferObject);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndexBufferObject);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, IndicesCount * sizeof(int), Indices, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	delete [] Indices;

	return true;
}

bool CTerrain::LoadBinary(char *FileName)
{
	CString DirectoryFileName = ModuleDirectory + FileName;

	FILE *File;

	if(fopen_s(&File, DirectoryFileName, "rb") != 0)
	{
		ErrorLog.Append("Error opening file " + DirectoryFileName + "!\r\n");
		return false;
	}

	int Size;

	if(fread(&Size, sizeof(int), 1, File) != 1 || Size <= 0)
	{
		ErrorLog.Append("Error reading file " + DirectoryFileName + "!\r\n");
		fclose(File);
		return false;
	}

	Destroy();

	this->Size = Size;
	SizeP1 = Size + 1;
	SizeD2 = (float)Size / 2.0f;

	VerticesCount = SizeP1 * SizeP1;

	Heights = new float[VerticesCount];

	if(fread(Heights, sizeof(float), VerticesCount, File) != VerticesCount)
	{
		ErrorLog.Append("Error reading file " + DirectoryFileName + "!\r\n");
		fclose(File);
		Destroy();
		return false;
	}

	fclose(File);

	Min.x = Min.z = -SizeD2;
	Max.x = Max.z = SizeD2;

	Min.y = Max.y = Heights[0];

	for(int i = 1; i < VerticesCount; i++)
	{
		if(Heights[i] < Min.y) Min.y = Heights[i];
		if(Heights[i] > Max.y) Max.y = Heights[i];
	}

	CVertex *Vertices = new CVertex[VerticesCount];

	int i = 0;
	//计算地面的高度场,以及法线
	for(int z = 0; z <= Size; z++)
	{
		for(int x = 0; x <= Size; x++)
		{
			Vertices[i].Position = vec3((float)x - SizeD2, Heights[i], SizeD2 - (float)z);
			Vertices[i].Normal = normalize(vec3(GetHeight(x - 1, z) - GetHeight(x + 1, z), 2.0f, GetHeight(x, z + 1) - GetHeight(x, z - 1)));

			i++;
		}
	}

	glGenBuffers(1, &VertexBufferObject);

	glBindBuffer(GL_ARRAY_BUFFER, VertexBufferObject);
	glBufferData(GL_ARRAY_BUFFER, VerticesCount * sizeof(CVertex), Vertices, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	delete [] Vertices;

	IndicesCount = Size * Size * 2 * 3;

	int *Indices = new int[IndicesCount];

	i = 0;
	//三角形扇
	for(int z = 0; z < Size; z++)
	{
		for(int x = 0; x < Size; x++)
		{
			Indices[i++] = GetIndex(x, z);
			Indices[i++] = GetIndex(x + 1, z);
			Indices[i++] = GetIndex(x + 1, z + 1);

			Indices[i++] = GetIndex(x + 1, z + 1);
			Indices[i++] = GetIndex(x, z + 1);
			Indices[i++] = GetIndex(x, z);
		}
	}

	glGenBuffers(1, &IndexBufferObject);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndexBufferObject);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, IndicesCount * sizeof(int), Indices, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	delete [] Indices;

	return true;
}

bool CTerrain::SaveBinary(char *FileName)
{
	CString DirectoryFileName = ModuleDirectory + FileName;

	FILE *File;

	if(fopen_s(&File, DirectoryFileName, "wb+") != 0)
	{
		return false;
	}

	fwrite(&Size, sizeof(int), 1, File);

	fwrite(Heights, sizeof(float), VerticesCount, File);

	fclose(File);

	return true;
}

void CTerrain::Render()
{
	glBindBuffer(GL_ARRAY_BUFFER, VertexBufferObject);

	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, sizeof(CVertex), (void*)(sizeof(vec3) * 0));

	glEnableClientState(GL_NORMAL_ARRAY);
	glNormalPointer(GL_FLOAT, sizeof(CVertex), (void*)(sizeof(vec3) * 1));

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndexBufferObject);

	glDrawElements(GL_TRIANGLES, IndicesCount, GL_UNSIGNED_INT, NULL);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);

	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void CTerrain::Destroy()
{
	if(Heights != NULL)
	{
		delete [] Heights;
	}

	if(VertexBufferObject != 0)
	{
		glDeleteBuffers(1, &VertexBufferObject);
	}

	if(IndexBufferObject != 0)
	{
		glDeleteBuffers(1, &IndexBufferObject);
	}

	SetDefaults();
}

vec3 CTerrain::GetMin()
{
	return Min;
}

vec3 CTerrain::GetMax()
{
	return Max;
}

int CTerrain::GetIndex(int X, int Z)
{
	return SizeP1 * Z + X;
}

float CTerrain::GetHeight(int X, int Z)
{
	return Heights[GetIndex(X < 0 ? 0 : X > Size ? Size : X, Z < 0 ? 0 : Z > Size ? Size : Z)];
}

float CTerrain::GetHeight(float X, float Z)
{
	Z = -Z;

	X += SizeD2;
	Z += SizeD2;

	float Size = (float)this->Size;

	if(X < 0.0f) X = 0.0f;
	if(X > Size) X = Size;
	if(Z < 0.0f) Z = 0.0f;
	if(Z > Size) Z = Size;

	int ix = (int)X, ixp1 = ix + 1;
	int iz = (int)Z, izp1 = iz + 1;

	float fx = X - (float)ix;
	float fz = Z - (float)iz;

	float a = GetHeight(ix, iz);
	float b = GetHeight(ixp1, iz);
	float c = GetHeight(ix, izp1);
	float d = GetHeight(ixp1, izp1);

	float ab = a + (b - a) * fx;
	float cd = c + (d - c) * fx;

	return ab + (cd - ab) * fz;
}

float CTerrain::GetHeight(float *Heights, int Size, float X, float Z)
{
	float SizeM1F = (float)Size - 1.0f;

	if(X < 0.0f) X = 0.0f;
	if(X > SizeM1F) X = SizeM1F;
	if(Z < 0.0f) Z = 0.0f;
	if(Z > SizeM1F) Z = SizeM1F;

	int ix = (int)X, ixp1 = ix + 1;
	int iz = (int)Z, izp1 = iz + 1;

	int SizeM1 = Size - 1;

	if(ixp1 > SizeM1) ixp1 = SizeM1;
	if(izp1 > SizeM1) izp1 = SizeM1;

	float fx = X - (float)ix;
	float fz = Z - (float)iz;

	int izMSize = iz * Size, izp1MSize = izp1 * Size;

	float a = Heights[izMSize + ix];
	float b = Heights[izMSize + ixp1];
	float c = Heights[izp1MSize + ix];
	float d = Heights[izp1MSize + ixp1];

	float ab = a + (b - a) * fx;
	float cd = c + (d - c) * fx;

	return ab + (cd - ab) * fz;
}

// ----------------------------------------------------------------------------------------------------------------------------

COpenGLRenderer::COpenGLRenderer()
{
	Wireframe = false;
}

COpenGLRenderer::~COpenGLRenderer()
{
}

bool COpenGLRenderer::Init()
{
	bool Error = false;

	Error |= !Shader.Load("glsl120shader.vs", "glsl120shader.fs");

	Error |= !Terrain.LoadBinary("terrain1.bin");

	if(Error)
	{
		return false;
	}

	Shader.UniformLocations = new GLuint[1];
	Shader.UniformLocations[0] = glGetUniformLocation(Shader, "CameraPosition");

	float Height = Terrain.GetHeight(0.0f, 0.0f);

	Camera.Look(vec3(0.0f, Height + 1.75f, 0.0f), vec3(0.0f, Height + 1.75f, -1.0f));
	return true;
}

void COpenGLRenderer::Render()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	//glCullFace(GL_BACK);
	//glDepthFunc(GL_LEQUAL);
	glClearDepth(1.0f);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ZERO);

	glMatrixMode(GL_MODELVIEW);
	glLoadMatrixf(&Camera.ViewMatrix);

	if(Wireframe)
	{
		glColor3f(0.0f, 0.0f, 0.0f);

		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

		Terrain.Render();

		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}

	glColor4f(1.0f, 1.0f, 1.0f,1.0f);

	glUseProgram(Shader);
	glUniform3fv(Shader.UniformLocations[0], 1, &Camera.Position);

	Terrain.Render();

	glUseProgram(0);

	//glDisable(GL_CULL_FACE);
	//glDisable(GL_DEPTH_TEST);
}

void COpenGLRenderer::Animate(float FrameTime)
{
}

void COpenGLRenderer::Resize(int Width, int Height)
{
	this->Width = Width;
	this->Height = Height;

	glViewport(0, 0, Width, Height);

	Camera.SetPerspective(45.0f, (float)Width / (float)Height, 0.125f, 1024.0f);

	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(&Camera.ProjectionMatrix);
}

void COpenGLRenderer::Destroy()
{
	Shader.Destroy();

	Terrain.Destroy();
}

void COpenGLRenderer::CheckCameraTerrainPosition(vec3 &Movement)
{
	vec3 CameraPosition = Camera.Reference + Movement, Min = Terrain.GetMin(), Max = Terrain.GetMax();

	if(CameraPosition.x < Min.x) Movement += vec3(Min.x - CameraPosition.x, 0.0f, 0.0f);
	if(CameraPosition.x > Max.x) Movement += vec3(Max.x - CameraPosition.x, 0.0f, 0.0f);
	if(CameraPosition.z < Min.z) Movement += vec3(0.0f, 0.0f, Min.z - CameraPosition.z);
	if(CameraPosition.z > Max.z) Movement += vec3(0.0f, 0.0f, Max.z - CameraPosition.z);

	CameraPosition = Camera.Reference + Movement;

	float Height = Terrain.GetHeight(CameraPosition.x, CameraPosition.z);

	Movement += vec3(0.0f, Height + 1.75f - Camera.Reference.y, 0.0f);
}

void COpenGLRenderer::CheckCameraKeys(float FrameTime)
{
	BYTE Keys = 0x00;

	if(GetKeyState('W') & 0x80) Keys |= 0x01;
	if(GetKeyState('S') & 0x80) Keys |= 0x02;
	if(GetKeyState('A') & 0x80) Keys |= 0x04;
	if(GetKeyState('D') & 0x80) Keys |= 0x08;
	// if(GetKeyState('R') & 0x80) Keys |= 0x10;
	// if(GetKeyState('F') & 0x80) Keys |= 0x20;

	if(GetKeyState(VK_SHIFT) & 0x80) Keys |= 0x40;
	if(GetKeyState(VK_CONTROL) & 0x80) Keys |= 0x80;

	if(Keys & 0x3F)
	{
		vec3 Movement = Camera.OnKeys(Keys, FrameTime * 0.5f);

		CheckCameraTerrainPosition(Movement);

		Camera.Move(Movement);
	}
}

void COpenGLRenderer::OnKeyDown(UINT Key)
{
	switch(Key)
	{
		case VK_F1:
			Wireframe = !Wireframe;
			break;

		case VK_F5:
			Terrain.SaveBinary("terrain-saved.bin");
			break;

		case '1':
			if(Terrain.LoadBinary("terrain1.bin")) { vec3 Movement; CheckCameraTerrainPosition(Movement); Camera.Move(Movement); }
			break;

		case '2':
			if(Terrain.LoadTexture2D("terrain2.jpg", 32.0f, -16.0f)) { vec3 Movement; CheckCameraTerrainPosition(Movement); Camera.Move(Movement); }
			break;

		case '3':
			if(Terrain.LoadTexture2D("terrain3.jpg", 128.0f, -64.0f)) { vec3 Movement; CheckCameraTerrainPosition(Movement); Camera.Move(Movement); }
			break;

		case '4':
			if(Terrain.LoadTexture2D("terrain4.jpg", 128.0f, -64.0f)) { vec3 Movement; CheckCameraTerrainPosition(Movement); Camera.Move(Movement); }
			break;
	}
}

void COpenGLRenderer::OnLButtonDown(int X, int Y)
{
	LastClickedX = X;
	LastClickedY = Y;
}

void COpenGLRenderer::OnLButtonUp(int X, int Y)
{
	if(X == LastClickedX && Y == LastClickedY)
	{
	}
}

void COpenGLRenderer::OnMouseMove(int X, int Y)
{
	if(GetKeyState(VK_RBUTTON) & 0x80)
	{
		Camera.OnMouseMove(LastX - X, LastY - Y);
	}

	LastX = X;
	LastY = Y;
}

void COpenGLRenderer::OnMouseWheel(short zDelta)
{
	Camera.OnMouseWheel(zDelta);
}

void COpenGLRenderer::OnRButtonDown(int X, int Y)
{
	LastClickedX = X;
	LastClickedY = Y;
}

void COpenGLRenderer::OnRButtonUp(int X, int Y)
{
	if(X == LastClickedX && Y == LastClickedY)
	{
	}
}

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
	glewExperimental = GL_TRUE;
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
	OpenGLRenderer.OnKeyDown(Key);
}

void COpenGLView::OnLButtonDown(int X, int Y)
{
	OpenGLRenderer.OnLButtonDown(X, Y);
}

void COpenGLView::OnLButtonUp(int X, int Y)
{
	OpenGLRenderer.OnLButtonUp(X, Y);
}

void COpenGLView::OnMouseMove(int X, int Y)
{
	OpenGLRenderer.OnMouseMove(X, Y);
}

void COpenGLView::OnMouseWheel(short zDelta)
{
	OpenGLRenderer.OnMouseWheel(zDelta);
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

	OpenGLRenderer.CheckCameraKeys(FrameTime);

	OpenGLRenderer.Render();

	OpenGLRenderer.Animate(FrameTime);

	SwapBuffers(hDC);

	EndPaint(hWnd, &ps);

	InvalidateRect(hWnd, NULL, FALSE);
}

void COpenGLView::OnRButtonDown(int X, int Y)
{
	OpenGLRenderer.OnRButtonDown(X, Y);
}

void COpenGLView::OnRButtonUp(int X, int Y)
{
	OpenGLRenderer.OnRButtonUp(X, Y);
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

		case WM_KEYDOWN:
			OpenGLView.OnKeyDown((UINT)wParam);
			break;

		case WM_LBUTTONDOWN:
			OpenGLView.OnLButtonDown(LOWORD(lParam), HIWORD(lParam));
			break;

		case WM_LBUTTONUP:
			OpenGLView.OnLButtonUp(LOWORD(lParam), HIWORD(lParam));
			break;

		case WM_MOUSEMOVE:
			OpenGLView.OnMouseMove(LOWORD(lParam), HIWORD(lParam));
			break;

		case WM_MOUSWHEEL:
			OpenGLView.OnMouseWheel(HIWORD(wParam));
			break;

		case WM_PAINT:
			OpenGLView.OnPaint();
			break;

		case WM_RBUTTONDOWN:
			OpenGLView.OnRButtonDown(LOWORD(lParam), HIWORD(lParam));
			break;

		case WM_RBUTTONUP:
			OpenGLView.OnRButtonUp(LOWORD(lParam), HIWORD(lParam));
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
	char *AppName = "Terrain";

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
