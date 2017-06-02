/*
  *���������߽ڵ�
  *Ŀ�����ڷ���������,������Ҫ���������еĵ����3d��������
  *@Version:1.0ʵ�����������3d������ʾ
  *@Version:2.0ʵ����3d����������ϵͳ,Ҳʹ�������˸��õ�3d����
  *@Version:3.0 ������3d·����ʾ�Ĺ���
  *2017-3-22
  *@Author:xiaoxiong
 */
#ifndef __BESSEL_NODE_H__
#define __BESSEL_NODE_H__
#include "cocos2d.h"
#include"BesselSet.h"
/*
  *���������ߵ�
 */
class BesselPoint :public cocos2d::Node
{
private:
	//3dģ��,Ϊ�˷�����3d�ռ��ж�Զ��������ֱ�۵��Ӿ�����
	cocos2d::Sprite3D    *_modelSprite;
	//�ڵ��˳��,���������߽ڵ��˳��ͬ������γɵ�����·��Ҳ��ͬ
	cocos2d::Sprite          *_sequence;
	//ͼ��
	cocos2d::Sprite         *_iconSprite;
private:
	BesselPoint();
	void      initBesselPoint(int index);
public:
	~BesselPoint();
	static BesselPoint   *createBesselPoint(int index);
};
/*
  *N�ױ��������߶���
  *
  */
class   BesselNAction :public cocos2d::ActionInterval
{
private:
	std::vector<cocos2d::Vec3 >  _besselPoints;
public:
	/*
	  *duration:������ʱ��
	  *pointSequence:���������Ƶ������
	 */
	static BesselNAction  *createWithDuration(float duration,std::vector<cocos2d::Vec3> &pointSequence);
	virtual  void startWithTarget(cocos2d::Node *target);
	virtual  void update(float time);
private:
	void       initWithControlPoints(float d,std::vector<cocos2d::Vec3> &pointSequence);
};
/*
  *��Ҫע�����.�ڵ�����ĵ�����Ļ������,������Ϊ�ڹ��ߵ�UI�������Ѿ��ٶ����ǵ����еĲ���ȫ������OpenGL��������ϵ
  */
class BesselNode :public cocos2d::Node
{
private:
	//���������ߵ�ļ���
	std::vector<BesselPoint *>  _besselContainer;
	//ʵ�ʵĶ������Ŀ
	int                                          _besselPointSize;
	//OpenGL�������
	cocos2d::GLProgram          *_lineProgram;
	//���ߵ���ɫ
	cocos2d::Vec4                 _lineColor;
	//
	cocos2d::CustomCommand		_drawBesselCommand;
	//position of uniform
	int           _positionLoc;
	int           _colorLoc;
	int           _modelMatrixLoc;
	//��ǰ��ƫ������
	cocos2d::Vec2    _offsetVec2;
	/*
	  *������3d��������,��Ϊ�ؼ��Ĳ���
	  *3ά��ת����
	 */
	cocos2d::Mat4     _rotateMatrix;
	/*
	  *�ϴ�ѡ�еĵ�����
	  *�Լ���صĵ�����
	 */
	int                         _lastSelectIndex;
	cocos2d::Vec2     _lastOffsetVec2;
private:
	BesselNode();
	void        initBesselNode();
public:
	~BesselNode();

	static  BesselNode  *createBesselNode();

	void        drawBesselPoint(cocos2d::Mat4  &parentTransform,uint32_t flag);

	virtual  void   visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	/*
	*��ʼ�����������ߵ�
	*@param:pointCountΪ���ߵĿ��Ƶ����Ŀ
	*��ʼΪ3�����Ƶ�
	*/
	void   initBesselPoint(int pointCount);
	/*
	  *�������ߵ���ɫ
	 */
	void   setLineColor(cocos2d::Vec4 &);
	/*
	  *���ó�������ת����
	  *�˺��������Ǳ����,���ǿ��Լ�cocos2d�����м��α任�����ĵ���
	 */
	void   setRotateMatrix(const cocos2d::Mat4 &);
	/*
	  *��������������ת�Ĵ����ص�����
	  *touchPoint:�����������ĵ�Ϊ��Ļ�����ĵ�OpenGL��������ϵ�µĵ�����
	 */
	void   onTouchBegan(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera  *camera);

	void   onTouchMoved(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);

	void   onTouchEnded(const    cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);
	/*
	  *�����µ�Ctrl���ͷŵ�ʱ��Ļص�����
	 */
	void    onCtrlKeyRelease();
	/*
	*��άͶӰ����任
	*/
	void   projectToOpenGL(cocos2d::Camera *camera,const cocos2d::Vec3  &src, cocos2d::Vec3   &dts);
	/*
	  *��ȡ��ǰ�ı��������Ƶ���Ϣ
	  */
	void   getBesselPoints(BesselSet &);
	/*
	  *Ԥ����ǰ�Ѿ����ɵ�����
	  */
	//���뺯��Ϊȥ��������֮��ĺ������
	void   previewCurive(std::function<void  (float )> actionFinishedCallback);
	/*
	  *ʹ�ø�����һϵ�п��Ƶ�����ʼ���ڵ�����,��Ҫ��ʱ����Ҫ���´����ڵ�
	  */
	void   initBesselNodeWithPoints(const std::vector<cocos2d::Vec3>  &points);
	/*
	  *�ָ���ǰ�ڵ��λ��
	 */
	void   restoreBesselNodePosition();
};

#endif