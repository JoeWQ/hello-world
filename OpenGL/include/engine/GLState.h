/*
  *@aim:OpenGL应用程序使用的宏
  &2016-4-30
*/
#ifndef   __GL_STATE_H__
#define  __GL_STATE_H__

/////////////////////////////////宏开关////////////////////////////////////////////////////////////////
typedef 
enum     _tDrawFlag{
	kFlag_OrthoMatrix = 1,//如果该位不为0,则表示该矩阵是正交矩阵,否则是透视矩阵
	kFlag_Shadow = 2,//如果该位不为0,表示引擎启用了阴影功能
	kFlag_Geometry = 4,//表示开启了几何着色器功能
	kFlag_OpenGLVersion=8,//表示该版本是OpenGL,否则为OpenGLES
	kFlag_ShaderVersion30=16,//表示shader的版本至少为3.0或者以上,否则表示2.0
	kFlag_DefferedRender = 1 << 16,//如果该位不为0,则表示引擎启用了延迟着色功能
} tDrawFlagType;
//OpenGL的版本控制,是否是OpenGL版本,或者是OpenGLES版本
#if defined _WIN32 || defined _LINUX || defined _APPLE
#define      __OPENGL_VERSION__
#endif
//是否开启几何着色器,默认是不开启的,在OpenGLES版本中,必须禁止这个宏
#define      __GEOMETRY_SHADER__
//是否开启缓存,着色器缓存,纹理缓存
#define     __ENABLE_PROGRAM_CACHE__    
//开启纹理缓存
#define     __ENABLE_TEXTURE_CACHE__
///////////////////////////////////////////////////////////////////////////////////////////////////
//枚举常量,由于着色器内属性变量位置的不一致,暂时不设定确切的值
#define      GLAttribPosition            0   //位置坐标
#define      GLAttribTexCoord          1   //纹理坐标
#define      GLAttribNormal             2  //法线

//最常用的着色器对象名字,在SpriteSprite使用
#define      OpenGLSpriteProgram                     "OpenGLSpriteProgram"
//一般光照着色器
#define      OpenGLNormalLightProgram          "OpenGLLightProgram"
//点光源着色器
#define      OpenGLPointLightProgram             "OpenGLPointLightProgram"
//结构体内偏移
#define   __offsetof(s,m)           (char *)(&((s *)NULL)->m)

//关于点阴影的选择
//#define   __GEOMETRY_SHADOW__

//代替GLUT_宏常量
#define   GLSTATE_RGBA           0x0000
#define   GLSTATE_DOUBLE      0x0002
#define   GLSTATE_DEPTH        0x0010
#define   GLSTATE_STENCIL     0x0020
#ifndef  NULL
#define  NULL  0
#endif

#define    __MATH_PI__        3.1415926535873f
#define    _RADIUS_FACTOR_ (__MATH_PI__/180.0f)
//重力系数
#define    __GRAVITY_CONSTANT		9.810f
//引擎的命名空间名字
#define	 __NS_GLK_BEGIN                 namespace glk {
#define    __NS_GLK_END                     }
#define    __US_GLK__						    using namespace glk;
#endif