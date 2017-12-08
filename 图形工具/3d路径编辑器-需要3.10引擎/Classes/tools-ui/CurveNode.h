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
	//�Ƿ���ͣ��ģ��
	bool              _isPauseModel;
	float _weight;
	std::function<void(CurveType type, int param, int param2)> _onUIChangedCallback;
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
	virtual bool   onTouchBegan(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera  *camera);

	virtual void   onTouchMoved(const   cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera);

	virtual void   onTouchEnded(const    cocos2d::Vec2   &touchPoint, cocos2d::Camera *camera);
	/*
	*�����µ�Ctrl���ͷŵ�ʱ��Ļص�����
	*/
	virtual void    onCtrlKeyRelease();
	/*
	  *������Ctrl+Z����ʱ��Ļص�����
	 */
	virtual  void   onCtrlZPressed();
	/*
	  *�����߿��Ƶ㷢���仯��ʱ�������UI�㷢�͵�֪ͨ
	  *param,param2�����ľ���������ɻص������Լ�����
	 */
	virtual  void   setUIChangedCallback(std::function<void (CurveType type,int param,int param2)>);
	/*
	  *����Ҽ��ַ�,��ֻ����ͬʱ����alt����ʱ��Ż���Ч
	 */
	virtual  void   onMouseClick(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	virtual  void   onMouseMoved(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	virtual  void   onMouseReleased(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	/*
	  *����Ҽ��¼�,ֻ����ͬʱ����Ctrl����ʱ��Ż���Ч
	 */
	virtual   void  onMouseClickCtrl(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
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
	virtual void   initCurveNodeWithPoints(const ControlPointSet  &controlPointSet);
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
	/*
	  *��ȡ��ǰԤ����ģ�͵ļ���
	 */
	const FishVisual &getFishVisual()const { return _fishVisual; };
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
    cocos2d::Label          *_labelPosition;
	int                                _index;
	//��������
	int                               _actionIndex;
	//���Ƶ��������ϵľ���
	float                            _distance;
private:
	ControlPoint();
	void      initControlPoint(int index);
public:
	~ControlPoint();
	static ControlPoint   *createControlPoint(int index);
	/*
	  *�޸Ŀ��Ƶ�Ĵ���
	 */
	void   changeSequence(int index);
	/*
	  *��Ҫ�ֹ������ú���
	 */
	void     drawAxis();//��������
    
    float _speedCoef;
    
    void setLabelPosition(cocos2d::Vec3 position);

	void setActionIndex(int actionIndex) { _actionIndex = actionIndex; };
	void setActionDistance(float distance) { _distance = distance; };

	int getActionIndex()const { return _actionIndex; };
};
#endif
