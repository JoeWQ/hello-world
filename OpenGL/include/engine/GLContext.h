	/*
	*@aim:OpenGL基本环境参数封装
	*version2.0,加入对纹理缓存和着色器缓存的支持
	//Version 3.0:引入了对随机数,全局投影矩阵的支持
	//Version 4.0:引入了对事件的管理
	&2016-4-30
	*/
	#ifndef  __ENTRY_H__
	#define __ENTYY_H__
	#include<engine/Geometry.h>
	//OpenGL下下文渲染环境,以及继承了一些用处比较频繁的函数
	struct   GLContext
	{
	friend         void         __OnDraw__();
	friend         void         __OnUpdate__(int);
	friend         int           main(int, char  **);
	//用户私有数据
	void      *userObject;
	public:
	//定时回调函数
	void(*update)(GLContext *, float  deltaTime);//
	void(*draw)(GLContext *);

	void(*init)(GLContext *);//    初始化函数
	void(*finalize)(GLContext *);//程序关闭时回调

	int          lastTickCount;//上次获取的开机毫秒数
	//非windows系统使用
	#ifndef  _WIN32
	int          baseTickCount;
	#endif
	//屏幕尺寸,单位像素
	Size                winSize;
	Size                _shadowSize;//阴影的宽高,两者必须等长
	GLVector2     winPosition;
	//窗口缓冲区的类型
	int         displayMode;
	//窗口的名字
	char      *winTitle;
	//全局标志,具体含义请参见GLState.h中tDrawFlagType
	unsigned          _globleFlag;
	//一下是关于全局着色的数据
	GLVector2       _near_far_plane;//近远平面的距离
	Matrix             _projMatrix;        //全局投影矩阵
	//随机数种子
	unsigned          _rand_seed;
	private:
	GLContext(GLContext &);
	GLContext();
	static        GLContext     _singleGLContext;
	public:
	static     GLContext         *getInstance();
	//注册接口
	void      registerUpdateFunc(void(*update)(GLContext*, float));
	void      registerDrawFunc(void(*draw)(GLContext *));
	void      registerInitFunc(void(*init)(GLContext *));
	void      registerShutDownFunc(void(*finalize)(GLContext *));
	//返回窗口的大小
	Size      &getWinSize();
	//设置窗口的大小
	void      setWinSize(Size &);
//设置阴影窗口的宽高
	void      setShadowSize(Size   &sSize){ _shadowSize = sSize; };
	Size      &getShadowSize(){ return _shadowSize; };
	//设置窗口缓冲区的类型
	void      setDisplayMode(int flag);
	int        getDisplayMode();
	void      setWindowTitle(char   *);
	char     *getWindowTitle();
	void       setWinPosition(GLVector2 &);
	//设置近平面元平面的距离
	void           setNearFarPlane(GLVector2   &);
	GLVector2     &getNearFarPlane();
	//设置全局投影矩阵
	void                  setProjMatrix(Matrix   &);
	Matrix            &getProjMatrix();
	//设置随机数种子
	void           initSeed(unsigned seed){ _rand_seed = seed; };
	float           randomValue();//返回[0.0--1.0]之间的浮点数
	//返回单位顶点缓冲区对象,主要在延迟着色,SSAO中使用
	unsigned        loadBufferIdentity();
	void                setGlobleFlag(unsigned  flag){ _globleFlag = flag; };
	unsigned        getGlobleFlag(){ return _globleFlag; };
	};
	//注册将设定好的参数注册进窗口程序,注意这里不能调用OpenGL函数
	#endif