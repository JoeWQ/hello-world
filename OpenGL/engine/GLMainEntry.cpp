// GLMainEntry.cpp
// OpenGL Program Entry
//#include<GLtools.h>
//Version 3.0:修正了main函数在程序退出时不能调用析构函数的bug(手工修改freeglut_static.lib解决)
//Version 4.0:引入了glfw,并使用一个宏控制这中间的切换
//#define    __USE_GLFW_MM__    1
#define GLEW_STATIC
#include<GL/glew.h>
//#ifdef __APPLE__
//      #ifndef __USE_GLFW__
//          #include <glut/glut.h>          // OS X version of GLUT
//      #else
//          #include<GLFW/glfw3.h>
//      #endif
//#else
#ifdef   __USE_GLFW_MM__
          #include<GLFW/glfw3.h>
#else
         #include <GL/freeglut.h>            // Windows FreeGlut equivalent
#endif
//#endif
#include<engine/GLContext.h>
#ifdef  _WIN32
#include<Windows.h>
#else
#include<sys/time.h>
#endif
#include<stdio.h>
#include "engine/GLCacheManager.h"
#include "engine/event//EventManager.h"
#include "engine/event/KeyCode.h"
#include<map>
///////////////////////////////////////////////////////////////////
//declare function
void   Init(glk::GLContext   *);
void   Draw(glk::GLContext *);
void   Update(glk::GLContext *, float);
void   ShutDown(glk::GLContext *);
//////////////////////////////////////////////////////////////////
__NS_GLK_BEGIN
//glut中的键盘按键编码与引擎中的按键编码之间的转换
static  std::map<int, KeyCodeType> _staticKeyCodeMap;

static void   _staicKeyCodeTranslate()
{
	_staticKeyCodeMap['w'] = KeyCode_W;
	_staticKeyCodeMap['W'] = KeyCode_W;
	_staticKeyCodeMap['s'] = KeyCode_S;
	_staticKeyCodeMap['S'] = KeyCode_S;
	_staticKeyCodeMap['a'] = KeyCode_A;
	_staticKeyCodeMap['A'] = KeyCode_A;
	_staticKeyCodeMap['d'] = KeyCode_D;
	_staticKeyCodeMap['D'] = KeyCode_D;
	_staticKeyCodeMap[GLUT_KEY_CTRL_L+256] = KeyCode_CTRL;
	_staticKeyCodeMap[GLUT_KEY_CTRL_R+256] = KeyCode_CTRL;
	_staticKeyCodeMap[GLUT_KEY_SHIFT_L+256] = KeyCode_SHIFT;
	_staticKeyCodeMap[GLUT_KEY_SHIFT_R+256] = KeyCode_SHIFT;
	_staticKeyCodeMap[' '] = KeyCode_SPACE;
}

//callback for event window size changed
static     void          __onChangeSize(int w, int h)
{
	         glViewport(0, 0, w, h);
}
///////////////////////////////////////////////////////////////////////////////
// This function does any needed initialization on the rendering context. 
// This is the first opportunity to do any OpenGL related tasks.

//draw screen,default frame/second is 30
static    void         __OnDraw__()
{
	glk::GLContext    *_context = glk::GLContext::getInstance();
	if (_context->draw)
	{
		       _context->draw(_context);
#ifdef __USE_GLFW_MM__

#else
			   glutSwapBuffers();
#endif
	}
}
static   void         __OnUpdate__(int   _tag)
{
		glk::GLContext		*_context = glk::GLContext::getInstance();
		int                     _newTickCount = 0;
#ifdef _WINDOWS_
		_newTickCount = GetTickCount();
#else
		struct     timeval     val;
		gettimeofday(&val, NULL);
		_newTickCount = (val.tv_sec - _context->baseTickCount) * 1000 + val.tv_usec / 1000;
#endif
		if (_context->update)
		{
#ifdef _WINDOWS_
			_context->update(_context, (_newTickCount - _context->lastTickCount) / 1000.0f);
			_context->lastTickCount = _newTickCount;
#else
			_context->update(_context,(_newTickCount-_context->lastTickCount)/1000.0f);
			_context->lastTickCount = _newTickCount;
#endif
		}
#ifdef __USE_GLFW_MM__

#else
		glutPostRedisplay();
#endif
		int       _time = 0;
#ifdef  _WINDOWS_
		_time = GetTickCount() - _newTickCount;
#else
		struct    timeval     _val;
		gettimeofday(&_val,NULL);
		_time = (_val.tv_sec - _context->baseTickCount) * 1000 + _val.tv_usec / 1000 - _newTickCount;
#endif
//如果执行回调函数的时间大于33.3毫秒
		int        _delayTime = 34 - _time;
		if (_delayTime <= 20)//修正时间,不至于让间隔变得太小
			          _delayTime = 20;
#ifdef __USE_GLFW_MM__

#else
		glutTimerFunc(_delayTime, __OnUpdate__, 0);
#endif
}

#ifdef __USE_GLFW_MM__
void key_callback(GLFWwindow* window, int key, int scancode, int action, int mode)
{
//	std::cout << key << std::endl;
//	if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
//		glfwSetWindowShouldClose(window, GL_TRUE);
}
#else
//键盘处理事件
static void  _static_keyPressCallback(unsigned char keyCode,int x,int y)
{
	//目前暂时不支持组合按键,此功能以后将会添加
	//int modify = glutGetModifiers();
	std::map<int, KeyCodeType>::iterator it = _staticKeyCodeMap.find(keyCode);
	if (it == _staticKeyCodeMap.end())
		return;
	KeyCodeType keyType = _staticKeyCodeMap[keyCode];
	EventManager::getInstance()->dispatchKeyEvent(keyType,KeyCodeState_Pressed);
}
static void _static_keySpecialPressCallback(int keyCode, int x, int y)
{
	std::map<int, KeyCodeType>::iterator it = _staticKeyCodeMap.find(keyCode+256);
	if (it == _staticKeyCodeMap.end())
		return;
	KeyCodeType keyType = _staticKeyCodeMap[keyCode+256];
	EventManager::getInstance()->dispatchKeyEvent(keyType,KeyCodeState_Pressed);
}

static void _static_keyReleaseCallback(unsigned char keyCode, int x, int y)
{
	//目前暂时不支持组合按键,此功能以后将会添加
	//int modify = glutGetModifiers();
	std::map<int, KeyCodeType>::iterator it = _staticKeyCodeMap.find(keyCode);
	if (it == _staticKeyCodeMap.end())
		return;
	KeyCodeType keyType = _staticKeyCodeMap[keyCode];
	EventManager::getInstance()->dispatchKeyEvent(keyType, KeyCodeState_Released);
}

static void _static_keySpecialReleaseCallback(int keyCode, int x, int y)
{
	std::map<int, KeyCodeType>::iterator it = _staticKeyCodeMap.find(keyCode+256);
	if (it == _staticKeyCodeMap.end())
		return;
	KeyCodeType keyType = _staticKeyCodeMap[keyCode+256];
	EventManager::getInstance()->dispatchKeyEvent(keyType, KeyCodeState_Released);
}

static glk::MouseType __static_mouseButtonType;
//鼠按下释放事件标事件
static void _static_mousePressCallback(int button, int buttonState, int x, int y)
{
	glk::GLContext   *context = glk::GLContext::getInstance();
	auto &winSize = context->getWinSize();
	__static_mouseButtonType = glk::MouseType::MouseType_None;
	glk::GLVector2  mouseClickPosition(x, winSize.height - y);
	//鼠标的左键按下
	MouseType mouseType = MouseType_None;
	MouseState mouseState = MouseState_None;
	switch (button)
	{
	case GLUT_LEFT_BUTTON:
		mouseType = MouseType_Left;
		if (buttonState == GLUT_DOWN)
			mouseState = MouseState_Pressed;
		else if(buttonState == GLUT_UP)
			mouseState = MouseState_Released;
		break;
	case GLUT_RIGHT_BUTTON:			
		mouseType = MouseType_Right;
		if (buttonState == GLUT_DOWN)
			mouseState = MouseState_Pressed;
		else if (buttonState == GLUT_UP)
			mouseState = MouseState_Released;
		break;
	}
	if (mouseType != MouseType_None)
		glk::EventManager::getInstance()->dispatchMouseEvent(mouseType,mouseState,mouseClickPosition);
	__static_mouseButtonType = mouseType;
}
//
static void _static_mouseMotionCallback(int x,int y)
{
	glk::GLVector2 mouseMotionPosition(x,glk::GLContext::getInstance()->getWinSize().height-y);
	glk::EventManager::getInstance()->dispatchMouseEvent(__static_mouseButtonType, MouseState_Moved, mouseMotionPosition);
}
#endif

///////////////////////////////////////////////////////////////////////////////
// Main entry point for GLUT based programs
void      GLMainEntrySetting(glk::GLContext    *_context)
{
	_context->userObject = NULL;
#ifdef __USE_GLFW_MM__
//	_context->setDisplayMode();
#else
	_context->setDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH | GLUT_STENCIL);
#endif
	_context->setWinSize(glk::Size(960, 640));
	_context->setShadowSize(glk::Size(1024,1024));
	_context->setWinPosition(glk::GLVector2(200, 100));
	_context->registerInitFunc(Init);
	_context->registerUpdateFunc(Update);
	_context->registerDrawFunc(Draw);
	_context->registerShutDownFunc(ShutDown);
	//按键转换函数
	_staicKeyCodeTranslate();
}

__NS_GLK_END
int      main(int argc, char* argv[])
{
//	gltSetWorkingDirectory(argv[0]);
#ifdef  __USE_GLFW_MM__
#else
	glutInit(&argc, argv);
#endif
	glk::GLContext	 *_context = glk::GLContext::getInstance();
	GLMainEntrySetting(_context);
#ifdef __USE_GLFW_MM__
	glfwInit();
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

	Size    _size = _context->getWinSize();
	GLFWwindow* window = glfwCreateWindow(_size.width, _size.height, "Learn-OpenGL", nullptr, nullptr);
	if ( ! window )
	{
		printf("Failed to create GLFW window\n");
		glfwTerminate();
		return -1;
	}
	glfwMakeContextCurrent(window);
	glfwSetKeyCallback(window, key_callback);
	int width, height;
	glfwGetFramebufferSize(window, &width, &height);
#else
	glutInitDisplayMode(_context->displayMode);
	glutInitWindowSize((int)_context->winSize.width,(int)_context->winSize.height);
	glutInitWindowPosition((int)_context->winPosition.x,(int)_context->winPosition.y);
	glutCreateWindow(_context->winTitle);
	glutReshapeFunc(glk::__onChangeSize);
	glutDisplayFunc(glk::__OnDraw__);
	//鼠标按下释放事件
	glutMouseFunc(glk::_static_mousePressCallback);
	glutMotionFunc(glk::_static_mouseMotionCallback);
	//键盘事件
	glutKeyboardFunc(glk::_static_keyPressCallback);
	glutKeyboardUpFunc(glk::_static_keyReleaseCallback);
	glutSpecialFunc(glk::_static_keySpecialPressCallback);
	glutSpecialUpFunc(glk::_static_keySpecialReleaseCallback);
#endif
	glewExperimental = GL_TRUE;
	GLenum err = glewInit();
	if (GLEW_OK != err) {
		fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
		return 1;
	}
#ifdef __USE_GLFW_MM__
	glViewport(0, 0, width, height);
#endif
//init函数必须实现,必须调用初始化函数
	_context->init(_context);
#ifdef __USE_GLFW_MM__
	float            _origin_time = glfwGetTime();
	glBindVertexArray(0);
	while (!glfwWindowShouldClose(window))
	{
		float      _now_time = glfwGetTime();
		float      _elapse_time = _now_time - _origin_time;
		_origin_time = _now_time;
		glfwPollEvents();
		_context->update(_context,_elapse_time);
		_context->draw(_context);
		glfwSwapBuffers(window);
	}
#else
	glutTimerFunc(34, glk::__OnUpdate__, 0);

	glutMainLoop();
#endif
	if (_context->finalize)//程序退出时的清理
		       _context->finalize(_context);
	if (_context->userObject)//释放申请的内存
		      free(_context->userObject);
	glk::GLCacheManager::getInstance()->~GLCacheManager();
	glk::EventManager::getInstance()->~EventManager();
#ifdef __USE_GLFW_MM__
	glfwTerminate();
	return 0;
#endif
	return 0;
}
