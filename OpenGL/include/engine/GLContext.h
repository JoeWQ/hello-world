	/*
	*@aim:OpenGL��������������װ
	*version2.0,��������������ɫ�������֧��
	//Version 3.0:�����˶������,ȫ��ͶӰ�����֧��
	//Version 4.0:�����˶��¼��Ĺ���
	&2016-4-30
	*/
	#ifndef  __ENTRY_H__
	#define __ENTYY_H__
	#include<engine/Geometry.h>
	//OpenGL��������Ⱦ����,�Լ��̳���һЩ�ô��Ƚ�Ƶ���ĺ���
	struct   GLContext
	{
	friend         void         __OnDraw__();
	friend         void         __OnUpdate__(int);
	friend         int           main(int, char  **);
	//�û�˽������
	void      *userObject;
	public:
	//��ʱ�ص�����
	void(*update)(GLContext *, float  deltaTime);//
	void(*draw)(GLContext *);

	void(*init)(GLContext *);//    ��ʼ������
	void(*finalize)(GLContext *);//����ر�ʱ�ص�

	int          lastTickCount;//�ϴλ�ȡ�Ŀ���������
	//��windowsϵͳʹ��
	#ifndef  _WIN32
	int          baseTickCount;
	#endif
	//��Ļ�ߴ�,��λ����
	Size                winSize;
	Size                _shadowSize;//��Ӱ�Ŀ��,���߱���ȳ�
	GLVector2     winPosition;
	//���ڻ�����������
	int         displayMode;
	//���ڵ�����
	char      *winTitle;
	//ȫ�ֱ�־,���庬����μ�GLState.h��tDrawFlagType
	unsigned          _globleFlag;
	//һ���ǹ���ȫ����ɫ������
	GLVector2       _near_far_plane;//��Զƽ��ľ���
	Matrix             _projMatrix;        //ȫ��ͶӰ����
	//���������
	unsigned          _rand_seed;
	private:
	GLContext(GLContext &);
	GLContext();
	static        GLContext     _singleGLContext;
	public:
	static     GLContext         *getInstance();
	//ע��ӿ�
	void      registerUpdateFunc(void(*update)(GLContext*, float));
	void      registerDrawFunc(void(*draw)(GLContext *));
	void      registerInitFunc(void(*init)(GLContext *));
	void      registerShutDownFunc(void(*finalize)(GLContext *));
	//���ش��ڵĴ�С
	Size      &getWinSize();
	//���ô��ڵĴ�С
	void      setWinSize(Size &);
//������Ӱ���ڵĿ��
	void      setShadowSize(Size   &sSize){ _shadowSize = sSize; };
	Size      &getShadowSize(){ return _shadowSize; };
	//���ô��ڻ�����������
	void      setDisplayMode(int flag);
	int        getDisplayMode();
	void      setWindowTitle(char   *);
	char     *getWindowTitle();
	void       setWinPosition(GLVector2 &);
	//���ý�ƽ��Ԫƽ��ľ���
	void           setNearFarPlane(GLVector2   &);
	GLVector2     &getNearFarPlane();
	//����ȫ��ͶӰ����
	void                  setProjMatrix(Matrix   &);
	Matrix            &getProjMatrix();
	//�������������
	void           initSeed(unsigned seed){ _rand_seed = seed; };
	float           randomValue();//����[0.0--1.0]֮��ĸ�����
	//���ص�λ���㻺��������,��Ҫ���ӳ���ɫ,SSAO��ʹ��
	unsigned        loadBufferIdentity();
	void                setGlobleFlag(unsigned  flag){ _globleFlag = flag; };
	unsigned        getGlobleFlag(){ return _globleFlag; };
	};
	//ע�Ὣ�趨�õĲ���ע������ڳ���,ע�����ﲻ�ܵ���OpenGL����
	#endif