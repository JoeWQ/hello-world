/*
  *@aim:OpenGLӦ�ó���ʹ�õĺ�
  &2016-4-30
*/
#ifndef   __GL_STATE_H__
#define  __GL_STATE_H__

/////////////////////////////////�꿪��////////////////////////////////////////////////////////////////
typedef 
enum     _tDrawFlag{
	kFlag_OrthoMatrix = 1,//�����λ��Ϊ0,���ʾ�þ�������������,������͸�Ӿ���
	kFlag_Shadow = 2,//�����λ��Ϊ0,��ʾ������������Ӱ����
	kFlag_Geometry = 4,//��ʾ�����˼�����ɫ������
	kFlag_OpenGLVersion=8,//��ʾ�ð汾��OpenGL,����ΪOpenGLES
	kFlag_ShaderVersion30=16,//��ʾshader�İ汾����Ϊ3.0��������,�����ʾ2.0
	kFlag_DefferedRender = 1 << 16,//�����λ��Ϊ0,���ʾ�����������ӳ���ɫ����
} tDrawFlagType;
//OpenGL�İ汾����,�Ƿ���OpenGL�汾,������OpenGLES�汾
#if defined _WIN32 || defined _LINUX || defined _APPLE
#define      __OPENGL_VERSION__
#endif
//�Ƿ���������ɫ��,Ĭ���ǲ�������,��OpenGLES�汾��,�����ֹ�����
#define      __GEOMETRY_SHADER__
//�Ƿ�������,��ɫ������,������
#define     __ENABLE_PROGRAM_CACHE__    
//����������
#define     __ENABLE_TEXTURE_CACHE__
///////////////////////////////////////////////////////////////////////////////////////////////////
//ö�ٳ���,������ɫ�������Ա���λ�õĲ�һ��,��ʱ���趨ȷ�е�ֵ
#define      GLAttribPosition            0   //λ������
#define      GLAttribTexCoord          1   //��������
#define      GLAttribNormal             2  //����

//��õ���ɫ����������,��SpriteSpriteʹ��
#define      OpenGLSpriteProgram                     "OpenGLSpriteProgram"
//һ�������ɫ��
#define      OpenGLNormalLightProgram          "OpenGLLightProgram"
//���Դ��ɫ��
#define      OpenGLPointLightProgram             "OpenGLPointLightProgram"
//�ṹ����ƫ��
#define   __offsetof(s,m)           (char *)(&((s *)NULL)->m)

//���ڵ���Ӱ��ѡ��
//#define   __GEOMETRY_SHADOW__

//����GLUT_�곣��
#define   GLSTATE_RGBA           0x0000
#define   GLSTATE_DOUBLE      0x0002
#define   GLSTATE_DEPTH        0x0010
#define   GLSTATE_STENCIL     0x0020
#ifndef  NULL
#define  NULL  0
#endif

#define    __MATH_PI__        3.1415926535873f
#define    _RADIUS_FACTOR_ (__MATH_PI__/180.0f)
//����ϵ��
#define    __GRAVITY_CONSTANT		9.810f
//����������ռ�����
#define	 __NS_GLK_BEGIN                 namespace glk {
#define    __NS_GLK_END                     }
#define    __US_GLK__						    using namespace glk;
#endif