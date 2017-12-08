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
#include"ControlPointSet.h"
#include "BezierRoute.hpp"
#include "Common.h"
#include "DrawNode3D.h"
#include "CurveNode.h"
/*
  *N�ױ��������߶���
  *
  */
class   BesselNAction :public cocos2d::ActionInterval
{
private:
	std::vector<int >             _actionIndexVec;
	std::function<void(const cocos2d::Vec3 &position)>   _callback;
	FishVisual							_fishVisualMap;
public:
	/*
	  *duration:������ʱ��
	  *pointSequence:���������Ƶ������
	 */
	static BesselNAction  *createWithDuration(float duration,std::vector<int> &actionIndexVec, BezierRoute* _route);
	static BesselNAction  *createWithBezierRoute(float speed, BezierRoute* _route);
	virtual  void startWithTarget(cocos2d::Node *target);
    virtual void step(float dt) override;
	virtual void update(float time);
	void              setCallback(std::function<void(const cocos2d::Vec3 &)> callback) { _callback = callback; };
	void     setAnimationFile(const std::string &filename) { _aniFile = filename; };
	void     setActionIndex(int actionIndex) { _actionIndex = actionIndex; };
	void     setActionIndexVec(const std::vector<int> &actionIndexVec) {_actionIndexVec = actionIndexVec;};
	void     setFishVisual(const FishVisual &fishVisual) { _fishVisualMap = fishVisual; };
public:
	BesselNAction();
	~BesselNAction();
	void       initWithControlPoints(float d,std::vector<int> &actionIndexVec);
    void		  initWithBezierRoute(float speed, BezierRoute* _route);
    BezierRoute* _route;
	float   _distance;
	float   _pastDistance;
    float _lastTime;
    float _speed;
    struct State {
        float m_fSpeedCoef;
        cocos2d::Vec3 m_Position;
        cocos2d::Vec3 m_Direction;
    };
    State m_pBaseInterpState;
    float m_fLastInterp;
	//�������ļ���/ȫ��
	std::string   _aniFile;
	//��ǰ�����Ŀ��Ƶ������
	int                _controlPointIndex;
	int                _actionIndex;
};
/*
  *��Ҫע�����.�ڵ�����ĵ�����Ļ������,������Ϊ�ڹ��ߵ�UI�������Ѿ��ٶ����ǵ����еĲ���ȫ������OpenGL��������ϵ
  */
class BesselNode :public CurveNode
{
private:
	//���������ߵ�ļ���
	std::vector<ControlPoint *>  _besselContainer;
	//ʵ�ʵĶ������Ŀ
	//int                                          _besselPointSize;
	//OpenGL�������
	cocos2d::GLProgram          *_lineProgram;
	//���ߵ���ɫ
	cocos2d::Vec4                 _lineColor;
	//
	cocos2d::CustomCommand		_drawBesselCommand;
	//position of uniform
	int           _positionLoc;
	int           _colorLoc;
	//��ǰ��ƫ������
	cocos2d::Vec2    _offsetVec2;
	/*
	  *�ϴ�ѡ�еĵ�����
	  *�Լ���صĵ�����
	 */
	int                         _lastSelectIndex;
	//��ǰѡ�еĿ��Ƶ�,�ÿ��Ƶ�ᱻ��������ڵ��ٶ�
	int                        _currentSelectIndex;
	cocos2d::Vec2     _lastOffsetVec2;
    
    BezierRoute* _bezierRoute;
    std::vector<CubicBezierRoute::PointInfo> _controlPoints;
	//����Ctrl+Z����ʱ�����,ֻ�ܻ���һ��
	int                       _backTraceindex;
	std::function<void(int)> _selectedCallback;
private:
	BesselNode();
	void        initBesselNode();
public:
	~BesselNode();
    
    
    virtual void onEnter();
    
    virtual void setWeight(float weight);

	static  BesselNode  *createBesselNode();

	void        drawBesselPoint(cocos2d::Mat4  &parentTransform,uint32_t flag);

	virtual  void   draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags);
	/*
	*��ʼ�����������ߵ�
	*@param:pointCountΪ���ߵĿ��Ƶ����Ŀ
	*��ʼΪ3�����Ƶ�
	*/
	virtual void   initControlPoint(int pointCount);
	/*
	  *��������������ת�Ĵ����ص�����
	  *touchPoint:�����������ĵ�Ϊ��Ļ�����ĵ�OpenGL��������ϵ�µĵ�����
	 */
	virtual bool   onTouchBegan(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera  *camera);
	virtual void   onTouchMoved(const   cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);
	virtual void   onTouchEnded(const    cocos2d::Vec2   &touchPoint,cocos2d::Camera *camera);
	/*
	  *��Ӧ����Ҽ��ĺ���,��Ϊ�����������м���в�ֵ�ĵ�
	 */
	virtual void onMouseClick(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	virtual void onMouseMoved(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	virtual void onMouseReleased(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	/*
	  *����������ǰԤ����ģ��
	 */
	virtual void onMouseClickCtrl(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera);
	/*
	  *�����µ�Ctrl���ͷŵ�ʱ��Ļص�����
	 */
	virtual void    onCtrlKeyRelease();
	/*
	  *������Ctrl+Z����ʱ��
	*/
	virtual void onCtrlZPressed();
	/*
	  *��ȡ��ǰ�ı��������Ƶ���Ϣ
	  */
	virtual void   getControlPoint(ControlPointSet &)override;
	/*
	  *Ԥ����ǰ�Ѿ����ɵ�����
	���뺯��Ϊȥ��������֮��ĺ������
	*/
	virtual void   previewCurive(std::function<void()> callback)override;
	/*
	  *ʹ�ø�����һϵ�п��Ƶ�����ʼ���ڵ�����,��Ҫ��ʱ����Ҫ���´����ڵ�
	  */
	virtual void   initCurveNodeWithPoints(const ControlPointSet  &controlPointSet)override;
	/*
	  *�ָ���ǰ�ڵ��λ��
	 */
	void   restoreCurveNodePosition();
	/*
	  *Ԥ��ģ�͵�ʱ��������Ҫʹ�õ�ģ�͵���Ϣ
	 */
	virtual void   setPreviewModel(const FishVisual &fishMap)override;
    
    void setTouchSelectedCallback(std::function<void (int)> callback) {_selectedCallback = callback;}
    
    cocos2d::DrawNode3D* drawNode;
    
    bool showLines;
	/*
	  *��ȡ��ǰѡ�еĿ��Ƶ�,���û��ѡ���κ�һ��,�򷵻�nullptr
	 */
	ControlPoint  *getSelectControlPoint()const;
};

#endif
