/*
  *��������
  *@date:2017-7-12
  *@Author:xiaoxiong
  @Version:1.0 ʵ����Բ��������
  @Version:2.0 ʵ��Բ׶������
 */
#ifndef __SPIRAL_NODE_H__
#define __SPIRAL_NODE_H__
#include "cocos2d.h"
#include "CurveNode.h"
#include "DrawNode3D.h"
/*
  *�������߽ڵ�,��ʼ������Ϊ��ת�ᳯ����Y��,������OpenGL��������ϵԭ��
  *�뾶Ϊ100.0f,������ת����Ա��϶���ת�ƶ�
  *��Ŀǰ�İ汾��,ֻʵ�����������Բ��������,����һ�汾�н�ʵ�ָ��Ӹ߼���Բ׶������
 */
class SpiralNode :public CurveNode
{
private:
	//�����ߵ���ת��,���뾭����λ��,��ʼֵΪ(0,1.0f,0.0f)
	cocos2d::Vec3						 _rotateAxis;
	//�뾶
	float											 _radius0;
	float                                         _radius1;
	//�����ߵ�����
	float                                         _windCount;
	//ÿһ�������ߵĸ߶�
	float                                         _spiralHeight;
	//�������ߵ���ת
	cocos2d::Mat4                      _curveRotateMatrix;
	//�������ߵ�ģ�;���
	cocos2d::Mat4                      _modelMatrix;
	//���������ߵĶ�������,��Ҫ��̬����
	float                                         *_vertexData;
	//�������Ŀ
	int                                              _vertexCount;
	/*
	  *������Ƶ�,ÿ�����Ƶ��������μ�SpiralNode.cpp�ļ�
	 */
	ControlPoint							*_controlPoints[6];
	//Shader
	cocos2d::GLProgram             *_glProgram;
	cocos2d::CustomCommand   _drawCommand;
	//Shader Position
	int                                             _positionLoc;
	int                                             _colorLoc;
	int                                             _modelMatrixLoc;
	cocos2d::DrawNode3D           *_axisNode;
	//�ϴ�ѡ�еĿ��Ƶ�
	int                                               _lastSelectIndex;
	//�ϴε������
	cocos2d::Vec2                           _lastOffsetPoint;
	//�ص�����
	std::function<void(SpiralValueType type,float radius)>  _radiusChangeCallback;
private:
	void  initSpiralNode();
	SpiralNode();
public:
	~SpiralNode();
	static SpiralNode *createSpiralNode();
	//�������ߵĿ��Ƶ����Ŀ,�˺���Ϊһ���ƺ���
	virtual void initControlPoint(int pointCount);
	//�����ص�,�˻ص�����������Control�������µ�ʱ�����
	virtual void onTouchBegan(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	/*
	*�����µ�Ctrl���ͷŵ�ʱ��Ļص�����
	*/
	virtual void    onCtrlKeyRelease();

	//�������ģ�͵�ʱ��Ļص�����
	virtual void   previewCurive(std::function<void()> callback);
	/*
	*ʹ�ø�����һϵ�п��Ƶ�����ʼ���ڵ�����,��Ҫ��ʱ����Ҫ���´����ڵ�
	*/
	virtual void   initCurveNodeWithPoints(const std::vector<cocos2d::Vec3>  &points);
	/*
	*�ָ���ǰ�ڵ��λ��
	*/
	virtual void   restoreCurveNodePosition();
	virtual void   draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	void               drawSpiralNode(cocos2d::Mat4 &parentTransform,uint32_t parentFlags);
	/*
	  *���¼��㶥�����Ŀ,
	  @param:needUpdateVertex�Ƿ���Ҫ���¶�������,false����Ҫ,true��Ҫ
	 */
	void               updateVertexData(bool needUpdateVertex);
	/*
	  *����ת�������ص���ת����
	 */
	void               updateRotateMatrix(const cocos2d::Vec3 &rotateAxis);
	/*
	  *���������߽ڵ��л�ȡ����
	  *�������ݵĸ�ʽ,��μ�SpiralNode.cpp�ļ�
	 */
	virtual void  getControlPoint(ControlPointSet &cpoints);
	/*
	  *�������ߵ�ʵ�ʳ���
	 */
	float             getSpiralLength()const;
	/*
	  *�°뾶�����仯��ʱ��Ļص�����
	  *type��뾶������,Ҳ���Ա�ʾ����������
	  *Ŀǰ0:�°뾶,1��ʾ�ϰ뾶
	 */
	void             setRadiusChangeCallback(std::function<void (SpiralValueType type,float radius)> callback);
	/*
	  *�����°뾶
	 */
	void            setBottomRadius(float radius);
	/*
	  *�����ϰ뾶
	 */
	void            setTopRadius(float radius);
};
/*
  *�������߶���,
 */
class SpiralAction :public cocos2d::ActionInterval
{
private:
	cocos2d::Vec3  _rotateAxis;//��ת��
	cocos2d::Vec3  _centerPoint;//��������
	float                  _bottomRadius;//�·��뾶
	float                  _topRadius;//�Ϸ��뾶
	float                  _spiralHeight;//����
	float                  _windCount;//����
	cocos2d::Mat4 _modelMatrix;//ȫ�������ݺϳɵı任����
private:
	/*
	  *�������е�ԭ����ѭgetControlPoint�����е�˵��
	 */
	void    initWithControlPoint(float duration,const std::vector<cocos2d::Vec3> &controlPoints);
	void    initWithControlPoint(float duration,const cocos2d::Vec3 &rotateAxis, const cocos2d::Vec3 &centerPoint, float bottomRadius, float topRadius, float spiralHeight, float windCount);
	//������ת����
	void    updateRotateMatrix();
public:
	static SpiralAction *create(float duration,const cocos2d::Vec3 &rotateAxis,const cocos2d::Vec3 &centerPoint,float bottomRadius,float topRadius,float spiralHeight,float windCount);
	static SpiralAction *create(float duration,const std::vector<cocos2d::Vec3> &controlPoints);
	virtual  void update(float rate);
};
#endif