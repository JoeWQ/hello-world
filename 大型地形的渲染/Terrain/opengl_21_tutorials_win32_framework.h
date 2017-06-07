// ----------------------------------------------------------------------------------------------------------------------------
//
// Version 2.03
//
// ----------------------------------------------------------------------------------------------------------------------------

#include <windows.h>

#ifndef WM_MOUSWHEEL
	#define WM_MOUSWHEEL 0x020A
#endif

#include "glmath.h"
#include "string.h"

#include <gl/glew.h> // http://glew.sourceforge.net/
#include <gl/wglew.h>

#include <FreeImage/FreeImage.h> // http://freeimage.sourceforge.net/

// ----------------------------------------------------------------------------------------------------------------------------

#pragma comment(lib, "opengl32.lib")
//#pragma comment(lib, "freeglut_static.lib")
#pragma comment(lib, "glew32s.lib")
#pragma comment(lib, "FreeImage.lib")

// ----------------------------------------------------------------------------------------------------------------------------

extern CString ModuleDirectory, ErrorLog;

// ----------------------------------------------------------------------------------------------------------------------------

#define BUFFER_SIZE_INCREMENT 1048576

// ----------------------------------------------------------------------------------------------------------------------------

class CBuffer
{
private:
	BYTE *Buffer;
	int BufferSize;

private:
	int Position;

public:
	CBuffer();
	~CBuffer();

private:
	void SetDefaults();

public:
	void AddData(void *Data, int DataSize);
	void Empty();
	void *GetData();
	int GetDataSize();
};

// ----------------------------------------------------------------------------------------------------------------------------

extern int gl_max_texture_size, gl_max_texture_max_anisotropy_ext;

// ----------------------------------------------------------------------------------------------------------------------------

class CTexture
{
private:
	GLuint Texture;

private:
	int Width, Height;

public:
	CTexture();
	~CTexture();

private:
	void SetDefaults();

public:
	operator GLuint ();

private:
	FIBITMAP *GetBitmap(char *FileName, int &Width, int &Height, int &BPP);

public:
	bool LoadTexture2D(char *FileName);
	bool LoadTextureCubeMap(char **FileNames);
	void Destroy();

public:
	int GetWidth();
	int GetHeight();
};

// ----------------------------------------------------------------------------------------------------------------------------

class CShaderProgram
{
private:
	GLuint VertexShader, FragmentShader;

private:
	GLuint Program;

public:
	GLuint *UniformLocations, *AttribLocations;

public:
	CShaderProgram();
	~CShaderProgram();

private:
	void SetDefaults();

public:
	operator GLuint ();

private:
	GLuint LoadShader(char *FileName, GLenum Type);

public:
	bool Load(char *VertexShaderFileName, char *FragmentShaderFileName);
	void Destroy();
};

// ----------------------------------------------------------------------------------------------------------------------------

class CCamera
{
public:
	vec3 X, Y, Z, Position, Reference;

public:
	mat4x4 ViewMatrix, ViewMatrixInverse, ProjectionMatrix, ProjectionMatrixInverse, ViewProjectionMatrix, ViewProjectionMatrixInverse;

public:
	CCamera();
	~CCamera();

public:
	void Look(const vec3 &Position, const vec3 &Reference, bool RotateAroundReference = false);
	void Move(const vec3 &Movement);
	vec3 OnKeys(BYTE Keys, float FrameTime);
	void OnMouseMove(int dx, int dy);
	void OnMouseWheel(float zDelta);
	void SetPerspective(float fovy, float aspect, float n, float f);

private:
	void CalculateViewMatrix();
};

// ----------------------------------------------------------------------------------------------------------------------------

class CVertex
{
public:
	vec3 Position;
	vec3 Normal;
};

// ----------------------------------------------------------------------------------------------------------------------------

class CTerrain
{
private:
	int Size, SizeP1;
	float SizeD2;

private:
	vec3 Min, Max;

private:
	float *Heights;

private:
	int VerticesCount, IndicesCount;

private:
	GLuint VertexBufferObject, IndexBufferObject;

public:
	CTerrain();
	~CTerrain();

private:
	void SetDefaults();

public:
	bool LoadTexture2D(char *FileName, float Scale = 256.0f, float Offset = -128.0f);
	bool LoadBinary(char *FileName);
	bool SaveBinary(char *FileName);
	void Render();
	void Destroy();

public:
	vec3 GetMin();
	vec3 GetMax();

private:
	int GetIndex(int X, int Z);
	float GetHeight(int X, int Z);

public:
	float GetHeight(float X, float Z);

private:
	float GetHeight(float *Heights, int Size, float X, float Z);
};

// ----------------------------------------------------------------------------------------------------------------------------

class COpenGLRenderer
{
private:
	int LastX, LastY, LastClickedX, LastClickedY;

private:
	int Width, Height;

private:
	CCamera Camera;

private:
	CShaderProgram Shader;

private:
	CTerrain Terrain;

private:
	bool Wireframe;

public:
	CString Text;

public:
	COpenGLRenderer();
	~COpenGLRenderer();

public:
	bool Init();
	void Render();
	void Animate(float FrameTime);
	void Resize(int Width, int Height);
	void Destroy();

private:
	void CheckCameraTerrainPosition(vec3 &Movement);

public:
	void CheckCameraKeys(float FrameTime);

public:
	void OnKeyDown(UINT Key);
	void OnLButtonDown(int X, int Y);
	void OnLButtonUp(int X, int Y);
	void OnMouseMove(int X, int Y);
	void OnMouseWheel(short zDelta);
	void OnRButtonDown(int X, int Y);
	void OnRButtonUp(int X, int Y);
};

// ----------------------------------------------------------------------------------------------------------------------------

class COpenGLView
{
private:
	char *Title;
	int Width, Height, Samples;
	HWND hWnd;
	HGLRC hGLRC;

private:
	COpenGLRenderer OpenGLRenderer;

public:
	COpenGLView();
	~COpenGLView();

public:
	bool Init(HINSTANCE hInstance, char *Title, int Width, int Height, int Samples);
	void Show(bool Maximized = false);
	void MessageLoop();
	void Destroy();

public:
	void OnKeyDown(UINT Key);
	void OnLButtonDown(int X, int Y);
	void OnLButtonUp(int X, int Y);
	void OnMouseMove(int X, int Y);
	void OnMouseWheel(short zDelta);
	void OnPaint();
	void OnRButtonDown(int X, int Y);
	void OnRButtonUp(int X, int Y);
	void OnSize(int Width, int Height);
};

// ----------------------------------------------------------------------------------------------------------------------------

LRESULT CALLBACK WndProc(HWND hWnd, UINT uiMsg, WPARAM wParam, LPARAM lParam);

// ----------------------------------------------------------------------------------------------------------------------------

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR sCmdLine, int iShow);
