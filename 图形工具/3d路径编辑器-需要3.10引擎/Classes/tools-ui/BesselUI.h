/*
  *�������������ɹ���
  *2017-03-20
  *@Author:xiaoxiong
  *@Version:1.0 ֧�����������������
  *@Version:2.0 �����˶�3d���������ߵ���в��ݵĹ���
 */
#ifndef __BESSEL_UI_H__
#define __BESSEL_UI_H__
#include"cocos2d.h"
#ifdef _WIN32
#include"geometry/Geometry.h"
#else
#include "Geometry.h"
#endif
#include "extensions/cocos-ext.h"
#include "ui/CocosGUI.h"
//#include"BesselNode.h"
#include"DrawNode3D.h"
#include"BezierRoute.hpp"
#include<vector>
#include"Common.h"
#include "CurveNode.h"
//��������,Ŀǰֻ������һ��,�Ժ����Ź��ߵ���չ,�����������İ�������
#define _KEY_CTRL_MASK_      0x01
//���W��������
#define _KEY_W_MASK_            0x02
//���S��������
#define _KEY_S_MASK_			  0x04
//Alt����
#define _KEY_ALT_MASK_         0x08
/*
  *�������������ɹ�����
  *3d�������õ�������Ļ�����ĵ�Ϊ(0,0,0)��,����ϵ����OpenGL��������ϵ�����н�ģ
  *���ǵ����������߾��и���ƽ�Ƶ�����,����ڱ������ݵ�ʱ�����ǻὫ����������һ�α任
  *������ı䱴�������ߵ���״
  */
class BesselUI :public cocos2d::Layer,public cocos2d::ui::EditBoxDelegate
{
private:
	//�뱴�������ߵĲ��������йص����
	cocos2d::Layer     *_settingLayer;
	//ScrollView
	cocos2d::ui::ScrollView  *_scrollView;
	//���������
	cocos2d::Camera	*_viewCamera;
	//
	//position of uniform
	//�ϴ�ѡ�еı��������ߵ������
	int           _lastSelectIndex;
	cocos2d::Vec2        _offsetPoint;
	cocos2d::Vec2        _originVec2;
	//��¼x,y�����ϵ�ƫ��
	cocos2d::Vec2        _xyOffset;
	/*
	  *3d�����µ������
	 */
	cocos2d::Camera   *_camera;
	/*
	  *�ı������
	 */
	cocos2d::ui::EditBox     *_editBox;
	//�����������ߵ��ϰ뾶�����
	cocos2d::ui::EditBox     *_topRadiusEditBox;
	//�°뾶�����
	cocos2d::ui::EditBox     *_bottomRadiusEditBox;
	//�༭ÿһ�����߿��Ƶ���ٶ�
	cocos2d::ui::EditBox     *_speedEditBox;
	/*
	  *���������صĲ���,����������������Զ,�������
	  *����������������ͼ����֮��
	 */
	float             _maxZeye, _minZeye,_nowZeye;
	/*
	  *��������
	 */
	CurveNode                        *_curveNode;
	//����3�������������
	cocos2d::DrawNode3D   *_axisNode;
	//3d�ռ������,����ʹ�����������пռ��
	Matrix    _rotateMatrix;
	//���̰�������
	int                            _keyMask;
	/*
	  *��¼�����Ѿ���ɵ����ߵ㼯������
	 */
	std::vector<ControlPointSet>     _besselSetData;
    
    struct Parameters
    {
        cocos2d::Vec3 a;
        cocos2d::Vec3 b;
        cocos2d::Vec3 c;
        cocos2d::Vec3 d;
        cocos2d::Vec3 da;
        cocos2d::Vec3 db;
        cocos2d::Vec3 dc;
    };
    
    struct PathInfo
    {
        std::vector<Parameters> segments;
        float duration;
    };
    
    std::vector<PathInfo> _parsedData;
	//int                                      _besselSetSize;
	/*
	  *��ǰ���ڱ༭��·��id,���Ϊ-1���ʾ���ڱ༭�½���,����Ϊ�༭�Ѿ����ڵĶ����е�ĳ��
	 */
	int                                      _currentEditPathIndex;
	//
	cocos2d::EventListenerKeyboard   *_keyboardListener;
	cocos2d::EventListenerTouchOneByOne    *_touchListener;
	//����¼�
	cocos2d::EventListenerMouse        *_mouseListener;
	bool                                                     _isResponseMouse;//�Ƿ���Ӧ����Ҽ�
	/*
	  *·������Ĺ���,ʹ��·��id������,����ʹ��������ֲ���·��id
	 */
	std::map<int, FishPathMap>           _fishPathMap;
	//ʹ��·����idȥ������ص���id
	std::map<int, FishIdMap>				_pathFishMap;
	//��ǰѡ�е���ļ���
	std::vector<int>                                  _currentSelectFishIds;
	/*
	  *��������ص�����,��Ϊ���id
	  */
	std::map<int, FishVisual>                 _fishVisualStatic;
private:
	BesselUI();
	void   initBesselLayer();
	/*
	  *������ת����
	 */
	void   makeRotateMatrix(const cocos2d::Vec2  &xyOffset,cocos2d::Mat4 &outMatrix,cocos2d::Quaternion  &);
	/*
	  *��������3d�������Լ������ռ�����
	 */
	void   drawAxisMesh();
	/*
	  *ʵʱ�����������λ��,����е���������Ķ���
	 */
	void   updateCamera(float dt);
public:
	~BesselUI();
	//layer
	static BesselUI    *createBesselLayer();
	//scene
	static cocos2d::Scene  *createScene();

	void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	//�����¼�
	virtual  bool   onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	//�����¼�,��Ҫ���Ctrl���Ƿ�����,�Ժ����Ź��ߵ���չ,�����������İ�������
	void                onKeyPressed(cocos2d::EventKeyboard::KeyCode    keyCode,cocos2d::Event    *unused_event);
	void                onKeyReleased(cocos2d::EventKeyboard::KeyCode   keyCode,cocos2d::Event *unused_event);
	//����¼�,���¼�ֻ�����ʼ�
	void					onMouseClick(cocos2d::EventMouse  *mouseEvent);
	void                 onMouseMoved(cocos2d::EventMouse *mouseEvent);
	void                 onMouseReleased(cocos2d::EventMouse *mouseEvent);
	/*���ײ�����߶����п��Ƶ㷢���˱仯��ʱ�������֪ͨ
	//param�����ľ������������ߵ����;���,һ����˵param1ָ������������,param2ָ��������͵�ֵ
	*/
	void                 onUIChangedCallback(CurveType curveType,int param1,int param2);
	/*
	  *����3d���������
	 */
	void           loadSettingLayer();
	/*
	  *������ػ�����չ���
	 */
	void           onButtonClick_SpreadOrHide(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	*�½�һ��·��
	*/
	void          onButtonClick_New(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType type);
	/*
	  *���Ʊ��������ߵĿ��Ƶ���Ŀ���鰴ť�¼�
	 */
	void          onChangeRadioButtonSelect_ControlPoint(cocos2d::ui::RadioButton* radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *�л���������
	 */
	void          onChangeRadioButtonSelect_ChangeCurve(cocos2d::ui::RadioButton *radioButton,cocos2d::ui::RadioButton::EventType type);
	/*
	  *ɾ����һ����¼
	 */
	void          onButtonClick_RemoveLast(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	//��һ���ص��������м亯��,����ɾ��ĳһ����¼
	void          removeSomeRecore(int index);
	/*
	  *���浱ǰ��¼
	 */
	void          onButtonClick_SaveRecord(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *����ǰ��¼д�뵽�ļ���
	 */
	void          onButtonClick_SaveToFile(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
    
    void          onButtonClick_SaveParsed(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *Ԥ������
	 */
	void         onButtonClick_Preview(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *ѡ����Ⱥ������
	 */
	void        onButtonClick_FishMap(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *д�뵽�ļ���
	 */
	void         writeRecordToFile();
	/*
	  *���ļ�Visual_Path.xml�м���ԭ���Ѿ��е�����,����������ҵ�����,��ֱ��ɾ��ԭ�����ļ�
	 */
	void         loadVisualXml();
	/*
	  *�ı������ص�����ʵ��
	 */
	 //���༭���ý���ʱ��������
	virtual void editBoxEditingDidBegin(cocos2d::ui::EditBox* editBox);
	//���༭��ʧȥ����󽫱�����
	virtual void editBoxEditingDidEnd(cocos2d::ui::EditBox* editBox);
	//���༭�����ݷ����ı佫������
	virtual void editBoxTextChanged(cocos2d::ui::EditBox* editBox, const std::string& text);
	//���༭��Ľ�������������
	virtual void editBoxReturn(cocos2d::ui::EditBox* editBox);
    
    void parseControlPoints();
    std::vector<CubicBezierRoute*> _parsedRoutes;
	/*
	  *�Ӻ�����ص������ļ��м������е�����
	*/
	void        loadFishVisualStatic();
	/*
	  *�������·����������ļ��е�����
	 */
	void        loadFishPathMap();
	/*
	  *�����·���Ĺ���д�뵽�ļ���
	 */
	void       saveFishMap();
	/*
	  *�л���ǰ����
	 */
	void       changeCurveNode(CurveType curveType);
};
#endif
