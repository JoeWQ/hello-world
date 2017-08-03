/*
  *���߽ڵ�,Ϊ���������ߵ����Ͳ��Ҳ��������Ĳ���Ҫ�ĸ�����,���������
  *@date:2017-07-12
  *@Author:xiaoxiong
 */
#ifndef __CURVE_NODE_H__
#define __CURVE_NODE_H__
#include "cocos2d.h"
#include "Common.h"
#include "ControlPointSet.h"
#include "DrawNode3D.h"
/*
  *����������ĳЩ����,��������಻֧��ĳЩ����,���Խ���ù��ܶ�Ӧ�ĺ�������Ϊ��֧�ֵĺ���
 */
class CurveNode :public cocos2d::Node
{
protected:
	CurveType        _curveType;
	cocos2d::Vec4  _lineColor;
	/*
	*������3d��������,��Ϊ�ؼ��Ĳ���
	*3ά��ת����
	*/
	cocos2d::Mat4     _rotateMatrix;
	FishVisual			  _fishVisual;
	float _previewSpeed;//Ԥ�����ٶ�
	//�Ƿ�֧�ֿ��Ƶ��ѡ��
	bool              _isSupportedControlPoint;
	float _weight;
protected:
	void              setSupportedControlPoint(bool b) { _isSupportedControlPoint = b; };
protected:
	CurveNode(CurveType curveType);
public:
	CurveType  getType()const { return _curveType; };
	//���ó�������ת����
	void     setRotateMatrix(const cocos2d::Mat4 &rotateM);
	//�������ߵ���ɫ
	void     setLineColor(const cocos2d::Vec4 &lineColor);
	//�������ߵ�Ȩ��
	virtual  void  setWeight(float weight);
	//�������ߵĿ��Ƶ����Ŀ,���������֧�ִ˹���,���Բ���ʵ��
	virtual void   initControlPoint(int pointCount);
	/*
	*��������������ת�Ĵ����ص�����,�˺���������Control���������µ�ʱ�����
	*touchPoint:�����������ĵ�Ϊ��Ļ�����ĵ�OpenGL��������ϵ�µĵ�����
	*/
	virtual void   onTouchBegan(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera  *camera);

	virtual void   onTouchMoved(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera);

	virtual void   onTouchEnded(const    cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera);
	/*
	*�����µ�Ctrl���ͷŵ�ʱ��Ļص�����
	*/
	virtual void    onCtrlKeyRelease();
	/*
	*��άͶӰ����任
	*/
	void   projectToOpenGL(cocos2d::Camera *camera, const cocos2d::Vec3  &src, cocos2d::Vec3   &dts);
	/*
	*��ȡ��ǰ�ı��������Ƶ���Ϣ
	*/

	//���뺯��Ϊȥ��������֮��ĺ������
	virtual void   previewCurive(std::function<void()> callback);
	/*
	*ʹ�ø�����һϵ�п��Ƶ�����ʼ���ڵ�����,��Ҫ��ʱ����Ҫ���´����ڵ�
	*/
	virtual void   initCurveNodeWithPoints(const std::vector<cocos2d::Vec3>  &points);
	/*
	*�ָ���ǰ�ڵ��λ��
	*/
	virtual void   restoreCurveNodePosition();
	/*
	*Ԥ��ģ�͵�ʱ��������Ҫʹ�õ�ģ�͵���Ϣ
	*/
    virtual void   setPreviewModel(const FishVisual &fishMap);
	/*
	  *��ȡ�ڵ����Ϣ
	 */
	virtual void  getControlPoint(ControlPointSet &);
	/*
	  *�����ٶ�
	 */
	virtual void  setPreviewSpeed(float speed);
	/*
	  *�Ƿ�֧�ֿ��Ƶ�ѡ��,����������֧��,�����������߲�֧��
	 */
	bool  isSupportedControlPoint() { return _isSupportedControlPoint; };
};
/*
*�������߿��Ƶ����۱�־
*/
class BesselNode;
class SpiralNode;
class ControlPoint :public cocos2d::Node
{
	friend class CureveNode;
	friend class BesselNode;
	friend class SpiralNode;
private:
	//3dģ��,Ϊ�˷�����3d�ռ��ж�Զ��������ֱ�۵��Ӿ�����
	cocos2d::Sprite3D    *_modelSprite;
	//�ڵ��˳��,���������߽ڵ��˳��ͬ������γɵ�����·��Ҳ��ͬ
	cocos2d::Label          *_sequence;
	//ͼ��
	cocos2d::Sprite         *_iconSprite;
	//�ڿ��Ƶ��ϻ���������
	cocos2d::DrawNode3D *_drawNode3D;
private:
	ControlPoint();
	void      initControlPoint(int index);
public:
	~ControlPoint();
	static ControlPoint   *createControlPoint(int index);
	/*
	  *��Ҫ�ֹ������ú���
	 */
	void     drawAxis();//��������
    
    float _speedCoef;
};
#endif
