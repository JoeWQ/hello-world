/*
  *Ⱥ�巭���˶�
  *2017-8-4
  *@Author:xiaohuaxiong
 */
#ifndef __ROLLING_GROUP_H__
#define __ROLLING_GROUP_H__
#include "extensions/cocos-ext.h"
#include "ui/CocosGUI.h"
#include "GroupRoute.h"
//ÿһ���ռ�Բ�Ĳ�������
struct CycleEquation
{
	cocos2d::Vec3 centerPoint;//���������
	float                  radius;//�뾶
};
/*
  *Ⱥ�巭���˶�
 */
class RollingRoute :public GroupRoute
{
	//����
	cocos2d::Vec3    _tangent;
	//����ͼ�����������λ��,Ĭ��λ��Ϊ��Ļ�����ĵ�,ʵ������Ҳ�ǽڵ������
	cocos2d::Vec3   _location;
	//��Բ�ķ���ʽ,����a,b��ȡֵ��ΧΪ:�����Ļ�ĳߴ��һ��,��С��Ļ��1/4��
	cocos2d::Vec2   _abEquation;
	//ֱ�ߵķ���ʽ,��ֱ�ߴ�����Բ�����˵�������
	cocos2d::Vec3   _originLocation, _finalLocation;
	cocos2d::Vec3   _lineVertex[2];
	//����XOY��Բ��������
	cocos2d::Vec3    *_xoyVertex;
	int                         _xoyVertexSize;
	//����YOZԲ����
	cocos2d::Vec3    *_yozVertex;
	int                         _yozVertexSize;
	//������Բƽ��Բ�ܶ��ٴ�,���Լ����RollingGroup.cpp��
	int                         _windHCount;
	//����Բ����Ŀ,��Լ����Χ��RollingGroup.cpp��
	int                         _windVCount;
	//Shader
	cocos2d::GLProgram              *_glProgram;
	//position loc
	int                                               _positionLoc;
	//color loc
	int                                               _colorLoc;
	//Model Matrix
	int                                              _modelMatrixLoc;
	//color
	cocos2d::Vec4                           _color;
	//��Ⱦ
	cocos2d::CustomCommand    _drawGroupCommand;
	//�������任����
	std::vector<cocos2d::Mat4>   _modelHMatrixVector;
	//�������任����
	std::vector<cocos2d::Mat4>   _modelVMatrixVector;
	std::vector<CycleEquation>    _cycleEquations;
	//ֱ�ߵı任����
	cocos2d::Mat4                          _modelLineMatrix;
	//�洢���пռ�Բ��ռ���Բ�Ľ���,������_cycleEquation������,
	std::map<int , std::vector<cocos2d::Vec3>>   _intersectPointMap;
	//��Բ�ܽ�����Sprite3Dģ��,ģ�͵�tagΪ���Id���û�о�Ϊnullptr
	std::map<int, std::vector<cocos2d::Sprite3D*>>   _intersectSprite3DMap;
	//��ʾ��Բ��Բ�ܽ����ľ���,�˾��鲻�������,������ʾ
	std::map<int, std::vector<cocos2d::Sprite*>>         _intersectSpriteMap;
	//ÿ������Բ�ܵĿ��Ƶ�,λ��Բ�ܺ���Բ���е������ߵĽ���,�����һ���������ڵ�����Ŀ��Ƶ�
	std::vector<ControlPoint *>   _cycleControlPoints;
	//��ǰѡ�еĿ��Ƶ������
	int                                              _lastSelectedIndex;
	//�ϴεĴ�����
	cocos2d::Vec2                          _lastOffsetVec2;
	//��Բ�ܵĽ������
	int                                             _intersectCycleIndex;
private:
	RollingRoute();
	RollingRoute(const RollingRoute &);
	bool       initWithLayer();
public:
	~RollingRoute();
	static RollingRoute *create();
	/*
	  *����Layer��,���������������ߵ�����
	 */
	virtual cocos2d::Layer *getControlLayer();
	/*
	  *�����ص�����
	 */
	virtual bool onTouchBegan(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void  onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	virtual void  onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera);
	/*
	  *�Ҽ��ص�,ֻʵ�������е�һ��
	 */
	virtual void onMouseClick(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera);
	/*
	  *��ȡ����
	 */
	virtual void   getGroupData(GroupData &output);
	//draw
	virtual  void draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags);
	/*
	  *�������˶����߽ṹ
	 */
	void             drawGroup(const cocos2d::Mat4 &transform,uint32_t flags);
	//���¶�������
	//check:�Ƿ���Ҫ�����µı�Ҫ��
	void             updateVertex(bool needCheck);
	//���³����ľ���任,�˺����������������Ѿ��������˵Ķ�������/����任
	//offsetVec3:��ʾ���ĵ��ƽ������
	void             updateTranformMatrix(const cocos2d::Vec3 &offsetVec3);
	//����ĳһ������Բ
	void             updateSomeCycle(int selectIndex,cocos2d::Vec3 &offsetVec3);
	//�����ϲ�ĵ����Ի���ʱ��Ҫ����Ļص�����
	void             onChooseDialogConfirmCallback(const FishInfo &fishInfo);
};
////////////////////////////�����������ߵ�Layer��///////////////////
class LayerRolling :public cocos2d::Layer
{
	/*
	  *������2������,һ�ǿ��ƹ����ĺ���������Ŀ
	  *�������������ߵ��ظ���Ŀ
	 */
private:
	cocos2d::ui::ScrollView    *_scrollViewEllipse;//������Բ���ظ���
	cocos2d::ui::ScrollView    *_scrollViewCycle;//����Բ�ܵ��ظ���
	//����Button
	cocos2d::ui::Button          *_hideSpreadButton;
	//����RollingGroup���������
	RollingRoute                     *_rollingRouteGroup;
private:
	LayerRolling(RollingRoute *rollingGroup);
	LayerRolling(const LayerRolling &);
	bool     init();
public:
	static LayerRolling *create(RollingRoute *rollingGroup);

	/*
	  *�鰴ť�ص�����,�л���Բ���ظ���
	 */
	void onRadioButtonClick_SelectEllipse(cocos2d::ui::RadioButton *radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *�л�Բ���ظ���
	 */
	void onRadioButtonClick_SelectCycle(cocos2d::ui::RadioButton *radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *�����ť��ʱ���������
	 */
	void onButtonClick_HideOrSpread(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType eventType);
};
#endif