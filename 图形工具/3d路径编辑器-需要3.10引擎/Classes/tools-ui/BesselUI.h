/*
  *贝塞尔曲线生成工具
  *2017-03-20
  *@Author:xiaoxiong
  *@Version:1.0 支持最基本的曲线生成
  *@Version:2.0 加入了对3d贝塞尔曲线点进行操纵的功能
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
//键盘掩码,目前只是用了一个,以后随着工具的扩展,将会引入更多的按键掩码
#define _KEY_CTRL_MASK_      0x01
//如果W键被按下
#define _KEY_W_MASK_            0x02
//如果S键被按下
#define _KEY_S_MASK_			  0x04
//Alt按键
#define _KEY_ALT_MASK_         0x08
/*
  *贝塞尔曲线生成工具类
  *3d场景采用的是以屏幕的中心点为(0,0,0)点,坐标系按照OpenGL世界坐标系来进行建模
  *考虑到贝塞尔曲线具有刚体平移的性质,最后在保存数据的时候，我们会将他的数据做一次变换
  *但不会改变贝塞尔曲线的形状
  */
class BesselUI :public cocos2d::Layer,public cocos2d::ui::EditBoxDelegate
{
private:
	//与贝塞尔曲线的参数设置有关的组件
	cocos2d::Layer     *_settingLayer;
	//ScrollView
	cocos2d::ui::ScrollView  *_scrollView;
	//摄像机参数
	cocos2d::Camera	*_viewCamera;
	//
	//position of uniform
	//上次选中的贝塞尔曲线点的索引
	int           _lastSelectIndex;
	cocos2d::Vec2        _offsetPoint;
	cocos2d::Vec2        _originVec2;
	//记录x,y方向上的偏移
	cocos2d::Vec2        _xyOffset;
	/*
	  *3d场景下的摄像机
	 */
	cocos2d::Camera   *_camera;
	/*
	  *文本输入框
	 */
	cocos2d::ui::EditBox     *_editBox;
	//对于螺旋曲线的上半径输入框
	cocos2d::ui::EditBox     *_topRadiusEditBox;
	//下半径输入框
	cocos2d::ui::EditBox     *_bottomRadiusEditBox;
	//编辑每一个曲线控制点的速度
	cocos2d::ui::EditBox     *_speedEditBox;
	/*
	  *与摄像机相关的参数,摄像机可以拉伸的最远,最近距离
	  *此数据域作用于视图矩阵之上
	 */
	float             _maxZeye, _minZeye,_nowZeye;
	/*
	  *曲线类型
	 */
	CurveNode                        *_curveNode;
	//关于3个方向的坐标轴
	cocos2d::DrawNode3D   *_axisNode;
	//3d空间的网格,用来使整个场景具有空间感
	Matrix    _rotateMatrix;
	//键盘按键掩码
	int                            _keyMask;
	/*
	  *记录所有已经完成的曲线点集合配置
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
	  *当前正在编辑的路径id,如果为-1则表示正在编辑新建的,否则为编辑已经存在的队列中的某个
	 */
	int                                      _currentEditPathIndex;
	//
	cocos2d::EventListenerKeyboard   *_keyboardListener;
	cocos2d::EventListenerTouchOneByOne    *_touchListener;
	//鼠标事件
	cocos2d::EventListenerMouse        *_mouseListener;
	bool                                                     _isResponseMouse;//是否响应鼠标右键
	/*
	  *路径与鱼的关联,使用路径id查找鱼,或者使用鱼的名字查找路径id
	 */
	std::map<int, FishPathMap>           _fishPathMap;
	//使用路径的id去查找相关的鱼id
	std::map<int, FishIdMap>				_pathFishMap;
	//当前选中的鱼的集合
	std::vector<int>                                  _currentSelectFishIds;
	/*
	  *所有鱼相关的资料,键为鱼的id
	  */
	std::map<int, FishVisual>                 _fishVisualStatic;
private:
	BesselUI();
	void   initBesselLayer();
	/*
	  *创建旋转矩阵
	 */
	void   makeRotateMatrix(const cocos2d::Vec2  &xyOffset,cocos2d::Mat4 &outMatrix,cocos2d::Quaternion  &);
	/*
	  *画出整个3d坐标轴以及整个空间网格
	 */
	void   drawAxisMesh();
	/*
	  *实时更新摄像机的位置,如果有调整摄像机的动作
	 */
	void   updateCamera(float dt);
public:
	~BesselUI();
	//layer
	static BesselUI    *createBesselLayer();
	//scene
	static cocos2d::Scene  *createScene();

	void visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	//触屏事件
	virtual  bool   onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	virtual void    onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	//键盘事件,主要检测Ctrl键是否按下了,以后随着工具的扩展,将会引入更多的按键处理
	void                onKeyPressed(cocos2d::EventKeyboard::KeyCode    keyCode,cocos2d::Event    *unused_event);
	void                onKeyReleased(cocos2d::EventKeyboard::KeyCode   keyCode,cocos2d::Event *unused_event);
	//鼠标事件,此事件只会检测邮件
	void					onMouseClick(cocos2d::EventMouse  *mouseEvent);
	void                 onMouseMoved(cocos2d::EventMouse *mouseEvent);
	void                 onMouseReleased(cocos2d::EventMouse *mouseEvent);
	/*当底层的曲线对象中控制点发生了变化的时候产生的通知
	//param参数的具体意义由曲线的类型决定,一般来说param1指代参数的类型,param2指代这个类型的值
	*/
	void                 onUIChangedCallback(CurveType curveType,int param1,int param2);
	/*
	  *控制3d场景的面板
	 */
	void           loadSettingLayer();
	/*
	  *点击隐藏或者伸展面板
	 */
	void           onButtonClick_SpreadOrHide(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	*新建一条路径
	*/
	void          onButtonClick_New(cocos2d::Ref *sender,cocos2d::ui::Widget::TouchEventType type);
	/*
	  *控制贝塞尔曲线的控制点数目的组按钮事件
	 */
	void          onChangeRadioButtonSelect_ControlPoint(cocos2d::ui::RadioButton* radioButton, cocos2d::ui::RadioButton::EventType type);
	/*
	  *切换曲线类型
	 */
	void          onChangeRadioButtonSelect_ChangeCurve(cocos2d::ui::RadioButton *radioButton,cocos2d::ui::RadioButton::EventType type);
	/*
	  *删除上一条记录
	 */
	void          onButtonClick_RemoveLast(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	//上一个回调函数的中间函数,用于删除某一个记录
	void          removeSomeRecore(int index);
	/*
	  *保存当前记录
	 */
	void          onButtonClick_SaveRecord(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *将当前记录写入到文件中
	 */
	void          onButtonClick_SaveToFile(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
    
    void          onButtonClick_SaveParsed(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *预览曲线
	 */
	void         onButtonClick_Preview(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *选择鱼群的配置
	 */
	void        onButtonClick_FishMap(cocos2d::Ref *pSender, cocos2d::ui::Widget::TouchEventType type);
	/*
	  *写入到文件中
	 */
	void         writeRecordToFile();
	/*
	  *从文件Visual_Path.xml中加载原来已经有的数据,如果出现杂乱的数据,则直接删除原来的文件
	 */
	void         loadVisualXml();
	/*
	  *文本输入框回调函数实现
	 */
	 //当编辑框获得焦点时将被调用
	virtual void editBoxEditingDidBegin(cocos2d::ui::EditBox* editBox);
	//当编辑框失去焦点后将被调用
	virtual void editBoxEditingDidEnd(cocos2d::ui::EditBox* editBox);
	//当编辑框内容发生改变将被调用
	virtual void editBoxTextChanged(cocos2d::ui::EditBox* editBox, const std::string& text);
	//当编辑框的结束操作被调用
	virtual void editBoxReturn(cocos2d::ui::EditBox* editBox);
    
    void parseControlPoints();
    std::vector<CubicBezierRoute*> _parsedRoutes;
	/*
	  *从和鱼相关的配置文件中加载所有的数据
	*/
	void        loadFishVisualStatic();
	/*
	  *加载鱼和路径相关联的文件中的数据
	 */
	void        loadFishPathMap();
	/*
	  *将鱼和路径的关联写入到文件中
	 */
	void       saveFishMap();
	/*
	  *切换当前曲线
	 */
	void       changeCurveNode(CurveType curveType);
};
#endif
