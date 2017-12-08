/*
  *贝塞尔曲线点实现
  *2017-3-22
  *@author:xiaoxiong
 */
#include"BesselNode.h"
#ifdef _WIN32
#include "geometry/Geometry.h"
#else
#include "Geometry.h"
#endif

USING_NS_CC;

/*
*贝塞尔曲线系数
*/
static const float  __static_bessel_coefficient[7][7] = {
	{ 0.0f,0.0f,0.0f, },
	{ 1.0,0.0f },//一阶
	{ 1.0f,2.0f,1.0f },//2 order
	{ 1.0f,3.0f,3.0f,1.0f },//3 order
	{ 1.0f,4.0f,6.0f,4.0f,1.0f },//4 order
	{ 1.0f,5.0f,10.0f,10.0f,5.0f,1.0f },//5.0f
	{ 1.0f,6.0f,15.0f,20.0f,15.0f,6.0f,1.0f },//6 order
};
///////////////////////////////////////////////////////////////////////////////////
BesselNode::BesselNode():CurveNode(CurveType::CurveType_Bessel)
{
	_lineProgram = NULL;
	//_besselPointSize = 0;
	_positionLoc = 0;
	_colorLoc = 0;
	_lastSelectIndex = -1;
	_currentSelectIndex = -1;
    _previewSpeed = 100;
    _weight = 0.5;
    _bezierRoute = new CubicBezierRoute();
    _selectedCallback = nullptr;
    ((CubicBezierRoute*)_bezierRoute)->setWeight(_weight);
    
    //drawNode = DrawNode3D::create();
    //this->addChild(drawNode);
    
    showLines = true;
	_backTraceindex = -1;
}

BesselNode::~BesselNode()
{
	_lineProgram->release();
}

 BesselNode   *BesselNode::createBesselNode()
{
	BesselNode  *node = new BesselNode();
	node->initBesselNode();
	node->autorelease();
	return node;
}

void BesselNode::setWeight(float weight)
{
    ((CubicBezierRoute*)_bezierRoute)->setWeight(weight);
    _bezierRoute->clear();
    _bezierRoute->addPoints(_controlPoints);
//    _bezierRoute->calculateDistance();
    _weight = weight;
}

 void   BesselNode::initBesselNode()
 {
	 Node::init();
	 _isSupportedControlPoint = true;//支持控制点选择
	 initControlPoint(4);
	 /*
	   *GLProgram
	  */
	 _lineProgram = GLProgramCache::getInstance()->getGLProgram(_SHADER_TYPE_COMMON_);
	 if (!_lineProgram)
	 {
		 _lineProgram = GLProgram::createWithByteArrays(_static_bessel_Vertex_Shader, _static_bessel_Frag_Shader);
		 GLProgramCache::getInstance()->addGLProgram(_lineProgram, _SHADER_TYPE_COMMON_);
	 }
	 _lineProgram->retain();

	 _positionLoc = _lineProgram->getAttribLocation("a_position");
	 _colorLoc = _lineProgram->getUniformLocation("u_color");
	 //color
	 _lineColor = Vec4(1.0f,1.0f,1.0f,1.0f);
 }
 /*
   *初始化贝塞尔曲线顶点
  */
 void    BesselNode::initControlPoint(int pointCount)
 {
	 if (_besselContainer.size() == pointCount)
		 return;
	 _backTraceindex = -1;
	 if (_currentSelectIndex >= 0)
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
	 _currentSelectIndex = -1;
	 //检测容器中存留的点的数目,并同时初始化点的坐标
	 const cocos2d::Size &winSize = Director::getInstance()->getWinSize();
	 int  i = 0;
	 //第一阶段，可视化判定
	 const   float  stepX = winSize.width / (pointCount + 1);
	 const   int    count = _besselContainer.size();
	 const   int    oneOrder = pointCount > count ? pointCount : count;
	 //float    disturbFactor[8] = { 1.0f,1.5f,1.5f,1.5f ,1.5f,1.5f,1.5f};
	 const   float  halfWidth = winSize.width / 2.0f;
	 const   float  halfHeight = winSize.height / 2.0f;
	 const   float  disturbFactor[2] = {1.0f,1.5f};
	 for (i = 0; i < oneOrder; ++i)
	 {
		 if (i >= count)
		 {
			 ControlPoint    *other = ControlPoint::createControlPoint(i);
			 other->setZOrder(i);
			 other->setPosition3D(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != pointCount - 1] / 2.0f - halfHeight, 0.0f));
			 other->drawAxis();
             other->setLabelPosition(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != pointCount - 1] / 2.0f - halfHeight, 0.0f));
			 //需要设置摄像机参数,否则不能被摄像机看到
			 other->setCameraMask(2);
			 this->addChild(other);
			 _besselContainer.push_back(other);
		 }
		 else
		 {
			 if (i >= pointCount)
			 {
				 ControlPoint		*other = _besselContainer.at(pointCount);
				 other->removeFromParent();
				 _besselContainer.erase(_besselContainer.begin() + pointCount);
			 }
			 else
			 {
				 ControlPoint		*other = _besselContainer.at(i);
				 other->setPosition3D(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != pointCount - 1] / 2.0f - halfHeight, 0.0f));
                 other->setLabelPosition(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != pointCount - 1] / 2.0f - halfHeight, 0.0f));
			 }
		 }
	 }
     _controlPoints.clear();
     for(int i=0;i<_besselContainer.size();++i)
     {
         CubicBezierRoute::PointInfo info;
         info.position = _besselContainer[i]->getPosition3D();
         info.speedCoef = _besselContainer[i]->_speedCoef;
         
         _controlPoints.push_back(info);
     }
     
     _bezierRoute->clear();
     _bezierRoute->addPoints(_controlPoints);
//     _bezierRoute->calculateDistance();
 }

 void   BesselNode::initCurveNodeWithPoints(const ControlPointSet  &controlPointSet)
 {
	 //判断是否需要重新创建节点
	 //取消选中的控制点
	 if (_currentSelectIndex >= 0)
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
	 _currentSelectIndex = -1;
	 _backTraceindex = -1;
	 //
	 const std::vector<RouteProtocol::PointInfo> &points = controlPointSet._pointsSet;
	 const int count = _besselContainer.size();
	 const int maxCount = points.size() > count ? points.size() : count;
	 for (int i = 0; i < maxCount; ++i)
	 {
		 if (i >= count)
		 {
			 ControlPoint    *other = ControlPoint::createControlPoint(i);
			 other->drawAxis();
			 other->setZOrder(i);
			 other->setCameraMask(2);
			 other->setPosition3D(points.at(i).position);
             other->setLabelPosition(points.at(i).position);
			 other->setActionIndex(points.at(i).aniIndex);
			 other->setActionDistance(points.at(i).aniDistance);
			 this->addChild(other);
			 _besselContainer.push_back(other);
		 }
		 else if (i >= points.size())
		 {
			 _besselContainer.erase(_besselContainer.begin() + points.size());
		 }
		 else
		 {
			 _besselContainer[i]->setPosition3D(points.at(i).position);
			 _besselContainer[i]->setActionIndex(points.at(i).aniIndex);
			 _besselContainer[i]->setActionDistance(points.at(i).aniDistance);
		 }
	 }
     _controlPoints.clear();
     for(int i=0;i<_besselContainer.size();++i)
     {
         CubicBezierRoute::PointInfo info;
         info.position = _besselContainer[i]->getPosition3D();
         info.speedCoef = _besselContainer[i]->_speedCoef;
		 info.aniIndex = _besselContainer[i]->_actionIndex;
		 info.aniDistance = _besselContainer[i]->_distance;
		 //
         _controlPoints.push_back(info);
     }
     _bezierRoute->clear();
     _bezierRoute->addPoints(_controlPoints);
//     _bezierRoute->calculateDistance();
 }

 void    BesselNode::restoreCurveNodePosition()
 {
	 //检测容器中存留的点的数目,并同时初始化点的坐标
	 const cocos2d::Size &winSize = Director::getInstance()->getWinSize();
	 int  i = 0;
	 //第一阶段，可视化判定
	 const   float  stepX = winSize.width / (_besselContainer.size()+ 1);
	 //float    disturbFactor[8] = { 1.0f,1.5f,1.5f,1.5f ,1.5f,1.5f,1.5f};
	 const   float  halfWidth = winSize.width / 2.0f;
	 const   float  halfHeight = winSize.height / 2.0f;
	 const   float  disturbFactor[2] = { 1.0f,1.5f };
	 for (i = 0; i < _besselContainer.size(); ++i)
	 {
		 ControlPoint		*other = _besselContainer.at(i);
		 other->setVisible(true);
		 //等分屏幕空间
		 other->setPosition3D(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != _besselContainer.size() - 1] / 2.0f - halfHeight, 0.0f));
         other->setLabelPosition(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != _besselContainer.size() - 1] / 2.0f - halfHeight, 0.0f));
		 other->setColor(Color3B::WHITE);
	 }
	 //恢复被选中的点的颜色
	 _currentSelectIndex = -1;
	 //重新生成曲线
	 _controlPoints.clear();
	 for (int i = 0; i < _besselContainer.size(); ++i)
	 {
		 CubicBezierRoute::PointInfo info;
		 info.position = _besselContainer[i]->getPosition3D();
		 info.speedCoef = _besselContainer[i]->_speedCoef;
		 info.aniIndex = _besselContainer[i]->_actionIndex;
		 info.aniDistance = _besselContainer[i]->_distance;
		 //
		 _controlPoints.push_back(info);
	 }
	 _bezierRoute->clear();
	 _bezierRoute->addPoints(_controlPoints);
 }
 /////////////////////////////////////触屏回调函数/////////////////////////////////////////
 bool    BesselNode::onTouchBegan(const Vec2 &touchPoint, cocos2d::Camera  *camera)
 {
	 _lastOffsetVec2 = touchPoint;
	 //检测是否某一个贝塞尔曲线控制点被选中了
	 const cocos2d::Size  &pointSize = _besselContainer.at(0)->getContentSize();
	 const float  halfWidth = pointSize.width / 2.0f;
	 const float  halfHeight = pointSize.height / 2.0f;
	 _lastSelectIndex = -1;
	 float        _lastZorder=0.0f;
	 for (int j = 0; j < _besselContainer.size(); ++j)
	 {
		 ControlPoint    *other = _besselContainer.at(j);
		 Vec3     nowPoint =_rotateMatrix * other->getPosition3D();
		 Vec3     glPosition;
		 //转换到OpenGL世界坐标系
		 this->projectToOpenGL(camera, nowPoint, glPosition);
		 
		 if (touchPoint.x >= glPosition.x - halfWidth && touchPoint.x <= glPosition.x + halfWidth
			 && touchPoint.y >= glPosition.y - halfHeight && touchPoint.y <= glPosition.y + halfHeight)
		 {
			 //选择的条件
			 if (_lastSelectIndex >= 0)//Zorder更大
			 {
				 if (glPosition.z < _lastZorder ||
					 (glPosition.z == _lastZorder && other->getLocalZOrder() > _besselContainer.at(_lastSelectIndex)->getLocalZOrder())
					 )//或者Zorder更大
				 {
					 _lastSelectIndex = j;
					 _lastZorder = glPosition.z;
				 }
			 }
			 else
			 {
				 _lastSelectIndex = j;
				 _lastZorder = glPosition.z;
			 }
		 }
	 }
	 //检测以前是否选中了
	 if (_currentSelectIndex >= 0)
	 {
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
	 }
	 _currentSelectIndex = _lastSelectIndex;
	 if (_currentSelectIndex >= 0)
	 {
		 _besselContainer[_currentSelectIndex]->setCascadeColorEnabled(true);
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::RED);
         _selectedCallback(_currentSelectIndex);
	 }
	 return true;
 }

 void    BesselNode::onTouchMoved(const Vec2  &touchPoint, cocos2d::Camera  *camera)
 {
	 if (_lastSelectIndex >= 0)
	 {
		 Vec2    realOffsetVec2 =touchPoint - _lastOffsetVec2;
//		 Vec3    OffsetVec3 = _rotateMatrix * Vec3(realOffsetVec2.x,realOffsetVec2.y,0.0f);
		 ControlPoint   *other = _besselContainer.at(_lastSelectIndex);
		 const Vec3    &originVec3 = other->getPosition3D();
		 //需要将这种平面上的偏移量转换到新的基于旋转矩阵的坐标系空间中
		 Vec3              newPosition = _rotateMatrix * originVec3 + Vec3(realOffsetVec2.x, realOffsetVec2.y,0.0);
		 //需要求解一次逆矩阵，但是考虑到旋转矩阵是一种正交矩阵,因此此步骤可以简化,在本人的程序中,
		 //为了使代码更具有可读性,本人没有使用转置矩阵
		 const Mat4				invRotate = _rotateMatrix.getInversed();
		 //对Z坐标进行限制
		 Vec3 afterPosition = invRotate * newPosition;
		 //目前对Z坐标的限制为前向不能超过zeye的1/4
		 auto &winSize = Director::getInstance()->getWinSize();
		 const float zeye = winSize.height / (1.1566f*4.0f);
		 if (afterPosition.z > zeye)
			 afterPosition.z = zeye;
		 //额外的限制,两个控制点的距离不能小于4像素
		 bool changed = true;
		 _lastOffsetVec2 = touchPoint;
		 for (int i = 0; i < _besselContainer.size(); ++i)
		 {
			 if (i != _lastSelectIndex)
			 {
				 Vec3 point = _besselContainer[i]->getPosition3D();
				 if ((point - afterPosition).length() <= 24.0f)
				 {
					 changed = false;
					 return;
				 }
			 }
		 }
		 if(changed)//如果修改坐标的条件满足
         {
             other->setPosition3D(afterPosition);
             other->setLabelPosition(afterPosition);
         }
	 }
     
     _controlPoints.clear();
     
     for(int i = 0; i < _besselContainer.size(); i++)
     {
         CubicBezierRoute::PointInfo info;
         info.position = _besselContainer[i]->getPosition3D();
         info.speedCoef = _besselContainer[i]->_speedCoef;
         
         _controlPoints.push_back(info);
     }
     
     _bezierRoute->clear();
     _bezierRoute->addPoints(_controlPoints);
//     _bezierRoute->calculateDistance();
 }

 void   BesselNode::onTouchEnded(const Vec2 &touchPoint, cocos2d::Camera  *camera)
 {
	 _lastSelectIndex = -1;	
	 //再次判断是否选中了某一个
	 if (_currentSelectIndex >= 0)
	 {
		 const cocos2d::Size  &pointSize = _besselContainer.at(0)->getContentSize();
		 const float  halfWidth = pointSize.width / 2.0f;
		 const float  halfHeight = pointSize.height / 2.0f;
		 Vec3     nowPoint = _rotateMatrix * _besselContainer[_currentSelectIndex]->getPosition3D();
		 Vec3     glPosition;
		 //转换到OpenGL世界坐标系
		 projectToOpenGL(camera, nowPoint, glPosition);

		 if (touchPoint.x >= glPosition.x - halfWidth && touchPoint.x <= glPosition.x + halfWidth
			 && touchPoint.y >= glPosition.y - halfHeight && touchPoint.y <= glPosition.y + halfHeight)
		 {
			 _besselContainer[_currentSelectIndex]->setCascadeColorEnabled(true);
			 _besselContainer[_currentSelectIndex]->setColor(Color3B::RED);
		 }
		 else
		 {
			 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
			 _currentSelectIndex = -1;
		 }
	 }
 }

 void  BesselNode::onCtrlKeyRelease()
 {
	 _lastSelectIndex = -1;
 }

 void BesselNode::onCtrlZPressed()
 {
	 if (_backTraceindex != -1)
	 {
		 //将控制点插入控制队列中
		 _besselContainer[_backTraceindex]->removeFromParent();
		 _besselContainer.erase(_besselContainer.begin() + _backTraceindex);
		 //修改某些控制点的次序
		 for (int i = _backTraceindex; i < _besselContainer.size(); ++i)
			 _besselContainer[i]->changeSequence(i);
		 //更新控制点的数据
		 _controlPoints.clear();
		 for (int i = 0; i < _besselContainer.size(); ++i)
		 {
			 CubicBezierRoute::PointInfo info;
			 info.position = _besselContainer[i]->getPosition3D();
			 info.speedCoef = _besselContainer[i]->_speedCoef;

			 _controlPoints.push_back(info);
		 }

		 _bezierRoute->clear();
		 _bezierRoute->addPoints(_controlPoints);
		 //通知上层UI,底层控制点发生了变化
		 _onUIChangedCallback(_curveType, 0, _besselContainer.size());
		 _backTraceindex = -1;
		 //检测以前是否选中了
		 if (_currentSelectIndex >= 0)
		 {
			 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
			 _currentSelectIndex = -1;
		 }
	 }
 }

 void BesselNode::onMouseClick(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 //如果已经到达了节点数目允许的上限,直接跳过
	 if (_besselContainer.size() >= _static_bessel_node_max_count)
	 {
		 return;
	 }
	 //转换为NDC
	 auto &winSize = Director::getInstance()->getWinSize();
	 float ndcx = clickPoint.x / winSize.width * 2.0f;
	 float ndcy = clickPoint.y / winSize.height * 2.0f;
	 //还原摄像机空间中的点的坐标到世界空间
	 Vec4  worldPosition;
	 const Mat4 &mvpMatrix = camera->getViewProjectionMatrix();//注意,节点本身还有一个旋转矩阵
	 Mat4 inverseMatrix = mvpMatrix.getInversed();
	 inverseMatrix.transformVector(Vec4(ndcx, ndcy, 1.0f, 1.0f), &worldPosition);
	 Vec3   worldPoint(worldPosition.x / worldPosition.w, worldPosition.y / worldPosition.w, worldPosition.z / worldPosition.w);
	 //
	 Vec3 cameraPosition = camera->getPosition3D();
	 //求取射线
	 Vec3 ray = (worldPoint - cameraPosition).getNormalized();
	 //求点是否在直线上
	 CubicBezierRoute *route =  (CubicBezierRoute *)_bezierRoute;
	 const std::vector<cocos2d::Vec3> &cachedPositions = route->getCachedPosition();
	 float  maxL = 0x7FFFFFFF;
	 int     selectIndex = -1;
	 for (int i = 0; i < cachedPositions.size(); ++i)
	 {
		 const Vec3 point = _rotateMatrix * cachedPositions[i];
		 Vec3     unitVec = point - cameraPosition;
		 float D = unitVec.length();
		 Vec3    normal = unitVec.getNormalized();
		 float     cosValue = Vec3::dot(normal, ray);
		 //如果平行,则一定在直线上
		 int        S = -1;
		 float      L = 0x7FFFFFFF;
	     float d = D * sqrtf(1.0 - cosValue * cosValue);
	    //检测d的取值范围,如果很小,则可以认为在这条直线上
		 if (d <= 4)//在4像素之内,可以认为是选中曲线上某一点了
			S = i;
		L = d;
		 if (selectIndex != -1 )
		 {
			 if (L < maxL)
			 {
				 selectIndex = S;
				 maxL = L;
			 }
		 }
		 else if(S !=-1)
			 selectIndex=S;
	 }
	 if (selectIndex != -1)
	 {
		 //检测以前是否选中了
		 if (_currentSelectIndex >= 0)
		 {
			 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
			 _currentSelectIndex = -1;
		 }
		 const std::vector<int>   &cachedIndex = route->getCachedIndex();
		 int     targetIndex = cachedIndex[selectIndex];
		 //获取目标索引在曲线中的坐标
		 const Vec3 targetPosition = cachedPositions[selectIndex];
		 //检测目标点与某一个控制点是否距离太近
		 for (int u = 0; u < _besselContainer.size(); ++u)
		 {
			 Vec3 position = _besselContainer[u]->getPosition3D();
			 if ((position - targetPosition).length() <= 24)//方圆24像素之内不能再次插入点
				 return;
		 }
		 //需要修改的目标控制点
		 _backTraceindex = targetIndex+1;
		 //修改控制点
		 ControlPoint  *cpoint = ControlPoint::createControlPoint(_backTraceindex);
		 cpoint->setPosition3D(targetPosition);
         cpoint->setLabelPosition(targetPosition);
		 cpoint->setCameraMask((short)CameraFlag::USER1);
		 this->addChild(cpoint);
		 //将控制点插入控制队列中
		 _besselContainer.insert(_besselContainer.begin()+ _backTraceindex,cpoint);
		 //修改某些控制点的次序
		 for (int i = _backTraceindex; i < _besselContainer.size(); ++i)
			 _besselContainer[i]->changeSequence(i);
		 //更新控制点的数据
		 _controlPoints.clear();
		 for (int i = 0; i < _besselContainer.size(); ++i)
		 {
			 CubicBezierRoute::PointInfo info;
			 info.position = _besselContainer[i]->getPosition3D();
			 info.speedCoef = _besselContainer[i]->_speedCoef;

			 _controlPoints.push_back(info);
		 }

		 _bezierRoute->clear();
		 _bezierRoute->addPoints(_controlPoints);
		 //通知上层UI,底层控制点发生了变化
		 _onUIChangedCallback(_curveType, 0, _besselContainer.size());
	 }
 }

 void BesselNode::onMouseMoved(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 //转换为NDC
	 auto &winSize = Director::getInstance()->getWinSize();
 }

 void BesselNode::onMouseReleased(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {

 }

 void BesselNode::onMouseClickCtrl(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 //检测是否有模型正在进行动作
	 Node *previewNode = this->getChildByName("PreviewModel");
	 if (previewNode)
	 {
		 if (!_isPauseModel)
			 _director->getActionManager()->pauseTarget(previewNode);
		 else
			 _director->getActionManager()->resumeTarget(previewNode);
		 _isPauseModel = !_isPauseModel;
		 return;
	 }
 }

 ControlPoint *BesselNode::getSelectControlPoint()const
 {
	 if (_currentSelectIndex >= 0)
		 return _besselContainer[_currentSelectIndex];
	 return nullptr;
 }
 /////////////////////////////////////////////////////////////////////////////////////////////
 //回掉函数
 void   BesselNode::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
 {
		 _drawBesselCommand.init(_globalZOrder);
		 _drawBesselCommand.func = CC_CALLBACK_0(BesselNode::drawBesselPoint,this,parentTransform,parentFlags);
		 renderer->addCommand(&_drawBesselCommand);
 }
 void BesselNode::drawBesselPoint(cocos2d::Mat4 &parentTransform, uint32_t flag)
 {
	 //计算分解贝塞尔曲线需要的线段数目,默认情况下每4像素一条直线
//	 int  lineCount = 0;
//	 Vec3    startPoint = _besselContainer.at(0)->getPosition3D();
//	 for (int i = 1; i < _besselPointSize; ++i)
//	 {
//		 const  Vec3  &finalPoint = _besselContainer.at(i)->getPosition3D();
//		 lineCount += ceil((finalPoint - startPoint).length() / 4.0f);
//		 startPoint = finalPoint;
//	 }
//	 //计算贝塞尔曲线的点
//	 float   *Vertex = new float[lineCount * 3 + 3];
//	 Vec3   *linePoints = (Vec3 *)Vertex;
//	 const  int  _pointSize = _besselPointSize;
//	 for (int j = 0; j < lineCount + 1; ++j)
//	 {
//		 cocos2d::Vec3  linePoint;
//		 const  float  t = 1.0f*j / lineCount;
//		 const  float  one_minus_t = 1.0f - t;
//		 for (int k = 0; k < _besselPointSize; ++k)
//		 {
//			 //const  Vec3 position3D = _besselContainer.at(k)->getPosition3D();
//			 linePoint += __static_bessel_coefficient[_pointSize - 1][k] * powf(one_minus_t, _pointSize - k - 1) * powf(t, k) *_besselContainer.at(k)->getPosition3D();
//		 }
//		 linePoints[j] = linePoint;
//	 }
#ifdef __USE_TEMP_DATA_
     if( false )//if(!showLines)
     {
         for(int i = 0; i < _besselContainer.size(); i++)
         {
             _besselContainer[i]->setVisible(false);
         }
         
         return;
     }
     else
     {
         for(int i = 0; i < _besselContainer.size(); i++)
         {
             _besselContainer[i]->setVisible(true);
         }
     }
     
     int pointNumber = _controlPoints.size();
     
     std::vector<cocos2d::Vec3> controlPoints;
     std::vector<cocos2d::Vec3> vertices;
     
     for(int i = 0; i < pointNumber; i++)
     {
         int index_back = (pointNumber + i - 1) % pointNumber;
         int index_forward = (i + 1) % pointNumber;
         Vec3 mid_back = (_controlPoints[index_back].position + _controlPoints[i].position) / 2;
         Vec3 mid_forward = (_controlPoints[index_forward].position + _controlPoints[i].position) / 2;
         float dist_back = _controlPoints[index_back].position.distance(_controlPoints[i].position);
         float dist_forward = _controlPoints[index_forward].position.distance(_controlPoints[i].position);
         Vec3 control_point_back = (mid_back - mid_forward) * dist_back * _weight / (dist_back + dist_forward) + _controlPoints[i].position;
         Vec3 control_point_forward = (mid_forward - mid_back) * dist_forward * _weight / (dist_back + dist_forward) + _controlPoints[i].position;
         
         controlPoints.push_back(control_point_back);
         controlPoints.push_back(control_point_forward);
         
         
//         drawLine(routePoints[index_back], routePoints[i], color);
//         drawLine(control_point_back, control_point_forward, color);
     }
     
     for(int i = 1; i < pointNumber - 2; i ++)
     {
         Vec3& p0 = _controlPoints[i].position;
         Vec3& p1 = controlPoints[(i * 2 + 1) % (pointNumber * 2)];
         Vec3& p2 = controlPoints[(i * 2 + 2) % (pointNumber * 2)];
         Vec3& p3 = _controlPoints[(i + 1) % pointNumber].position;
         
         Vec3 a = -1 * p0 + 3 * p1 - 3 * p2 + p3;
         Vec3 b =  3 * p0 - 6 * p1 + 3 * p2;
         Vec3 c = -3 * p0 + 3 * p1;
         Vec3 d =      p0;
         
         Vec3 da = -3 * p0 +  9 * p1 - 9 * p2 + 3 * p3;
         Vec3 db =  6 * p0 - 12 * p1 + 6 * p2;
         Vec3 dc = -3 * p0 +  3 * p1;
         
         float t = 0.0;
         
         do {
             
             float t0 = t;
             float t1 = t = t + 1.0 / (t * t * da + t * db + dc).length();
             t1 = t = t > 1.0 ? 1.0 : t ;
             
             Vec3 from = t0 * t0 * t0 * a + t0 * t0 * b + t0 * c + d;
             //Vec3 to = t1 * t1 * t1 * a + t1 * t1 * b + t1 * c + d;
             
//             drawLine(from, to, color);
             vertices.push_back(from);
             //vertices.push_back(to);
             
         }while(t != 1);
     }
#endif
	 CubicBezierRoute *cubic = (CubicBezierRoute*)_bezierRoute;
	 const std::vector<Vec3> &position = cubic->getCachedPosition();
	 //将曲线画出来
	 int  _defaultVertex;
	 glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultVertex);
     GL::bindVAO(0);
	 if (_defaultVertex != 0)
		 glBindBuffer(GL_ARRAY_BUFFER, 0);

	 _lineProgram->use();
	 _lineProgram->setUniformsForBuiltins(parentTransform);

	 glEnableVertexAttribArray(_positionLoc);
	 glVertexAttribPointer(_positionLoc, 3, GL_FLOAT, GL_FALSE, 0, position.data());

	 glUniform4fv(_colorLoc, 1, &_lineColor.x);
	 glLineWidth(1.0f);

	 glDrawArrays(GL_LINE_STRIP, 0, position.size());

	 if (_defaultVertex != 0)
		 glBindBuffer(GL_ARRAY_BUFFER, _defaultVertex);
//	 delete[] Vertex;
//	 Vertex = NULL;
 }
 /*
   *获取当前贝塞尔控制点相关的数据
  */
 void BesselNode::getControlPoint(ControlPointSet &besSet)
 {
	 besSet.setType(_curveType);
	 CubicBezierRoute *route = (CubicBezierRoute*)_bezierRoute;
	 auto &pointToDistanceVec = route->getPointToDistance();
	 for (int j = 0; j < _besselContainer.size(); ++j)
	 {
		 ControlPoint	*other = _besselContainer.at(j);
         Vec3 position = other->getPosition3D();
		 besSet.addNewPoint(position, other->_speedCoef);
         besSet.weight = _weight;
		 //对于ActionIndex不为0的数据,计算其详细的distance数值
		 besSet._pointsSet[j].aniIndex = other->_actionIndex;
		 besSet._pointsSet[j].aniDistance = pointToDistanceVec[j];
	 }
 }

 void   BesselNode::previewCurive(std::function<void()> callback)
 {
     Node* previewModel = this->getChildByName("PreviewModel");
     if(previewModel)
     {
         previewModel->removeFromParent();
		 this->removeChildByName("PreviewModelLabel");
     }
      _isPauseModel = false;
//	 //计算相关的时间
//	 std::vector<cocos2d::Vec3>  pointSequence;
//	 pointSequence.reserve(_besselPointSize);
//	 //
//	 float   realDistance = 0.0f;
//	 Vec3  startPoint = _besselContainer.at(0)->getPosition3D();
//	 for (int j = 0; j < _besselPointSize; ++j)
//	 {
//		 BesselPoint  *other = _besselContainer.at(j);
//		 const Vec3 &nowPoint = other->getPosition3D();
//		 realDistance += (nowPoint - startPoint).length();
//		 startPoint = nowPoint;
//		 pointSequence.push_back(nowPoint);
//	 }
//	 const float duration = realDistance / Director::getInstance()->getWinSize().width * 8.0f;
//	 //3D 模型
	 const std::string  filename = "3d/"+_fishVisual.name+"/"+_fishVisual.name+".c3b";
	 Sprite3D   *tempModel = Sprite3D::create(filename);
	 tempModel->setPosition3D(_besselContainer.at(0)->getPosition3D());
	 tempModel->setCameraMask((short)CameraFlag::USER1);
	 tempModel->setRotation3D(cocos2d::Vec3::ZERO);
	 tempModel->setScale(_fishVisual.scale);
	 //UIAnimation3D，播放游动动作
	 cocos2d::Animation3D  *animation = cocos2d::Animation3D::create(filename);
	 //选取第一个控制点上的动画
	 cocos2d::Animate3D      *aniAction = nullptr;
	 Action *headAction = nullptr;
	 if (_controlPoints[1].aniIndex != 0)
	 {
		 auto &fishAniMap =_fishVisual.fishAniVec[_controlPoints[1].aniIndex];
		 aniAction = Animate3D::create(animation,fishAniMap.startFrame/30.0f,(fishAniMap.endFrame-fishAniMap.startFrame)/30.0f);
		 auto &firstAniMap = _fishVisual.fishAniVec[0];
		 headAction = Sequence::create(aniAction,
			 CallFunc::create([this,tempModel,filename,firstAniMap,animation] {
				Action *action = RepeatForever::create(Animate3D::create(animation, firstAniMap.startFrame / 30.0f, (firstAniMap.endFrame - firstAniMap.startFrame) / 30.0f));
				action->setTag(0x87);
				tempModel->runAction(action);
		 }),
			 nullptr);
	 }
	 else
	 {
		 auto &fishAniMap = _fishVisual.fishAniVec[0];
		 aniAction = cocos2d::Animate3D::create(animation, fishAniMap.startFrame / 30.0f, (fishAniMap.endFrame - fishAniMap.startFrame) / 30.0f);
		 headAction = RepeatForever::create(aniAction);
	 }
	 //Action *aniForever = cocos2d::RepeatForever::create(aniAction);
	 //设置上标志,方便在贝塞尔曲线动作中停止这个动画动作
	 headAction->setTag(0x87);
	 tempModel->runAction(headAction);
     tempModel->setName("PreviewModel");

	 this->addChild(tempModel,16);
     
     showLines = false;
     
     _controlPoints.clear();
     for(int i=0;i<_besselContainer.size();++i)
     {
         CubicBezierRoute::PointInfo info;
         info.position = _besselContainer[i]->getPosition3D();
         info.speedCoef = _besselContainer[i]->_speedCoef;
		 info.aniIndex = _besselContainer[i]->_actionIndex;
		 info.aniDistance = _besselContainer[i]->_distance;
         
         _controlPoints.push_back(info);
     }
     
     _bezierRoute->clear();
     _bezierRoute->addPoints(_controlPoints);
	 //
	 //收集动画索引
	 std::vector<int> actionIndexVec;
	 for (auto it = _controlPoints.begin(); it != _controlPoints.end(); ++it)
	 {
		 actionIndexVec.push_back(it->aniIndex);
	 }
	 //
     ((CubicBezierRoute*)_bezierRoute)->setWeight(_weight);
	 BesselNAction *action = BesselNAction::createWithBezierRoute(_previewSpeed, _bezierRoute);
     tempModel->runAction(action);
	 action->setAnimationFile(filename);
	 action->setActionIndex(_controlPoints[1].aniIndex);
	 action->setActionIndexVec(actionIndexVec);
	 action->setFishVisual(_fishVisual);
     //action->retain();
     //
     //this->getScheduler()->unschedule("checkEnd", this);
     //
     //this->getScheduler()->schedule([this, action, tempModel, callback](float dt){
     //    
     //    if(action->isDone())
     //    {
     //        action->release();
     //        tempModel->removeFromParent();
     //        callback();
     //        this->getScheduler()->unschedule("checkEnd", this);
     //    }
     //    
     //    
     //}, this, 0, CC_REPEAT_FOREVER, 0, false, "checkEnd");
	 Label *label = Label::createWithSystemFont("0", "Arial",24);
	 this->addChild(label,18);
	 action->setCallback([label](const Vec3 &position) {
		 label->setPosition3D(Vec3(position.x,position.y-40,position.z));
		 char buffer[128];
		 sprintf(buffer,"[%d,%d,%d]",(int)position.x,(int)position.y,(int)position.z);
		 label->setString(buffer);
	 });
	 label->setCameraMask((short)CameraFlag::USER1);
	 label->setName("PreviewModelLabel");
	 tempModel->runAction(Sequence::create(action, CallFuncN::create([=](cocos2d::Node *sender) {
		 showLines = true;
		 sender->removeFromParentAndCleanup(true);
		 this->removeChildByName("PreviewModelLabel");
		 if (callback)
			 callback();
		 _isPauseModel = false;
	 }), nullptr));
 }
 /////////////////////////////////Action//////////////////////////////////////////////////////////
 BesselNAction::BesselNAction():
	 _controlPointIndex(1)
	 , _actionIndex(0)
 {

 }
 BesselNAction::~BesselNAction()
 {
	 _route->release();
 }
 void   BesselNAction::initWithControlPoints(float d, std::vector<int> &actionIndexVec)
 {
	 cocos2d::ActionInterval::initWithDuration(d);
	 _actionIndexVec = actionIndexVec;
 }

void   BesselNAction::initWithBezierRoute(float speed, BezierRoute* route)
{
    float duration = route->getDistance();
    
    cocos2d::ActionInterval::initWithDuration(duration/ speed);
    
    _speed = speed;
    _route = route;
	_distance = duration;
	route->retain();
}

 void  BesselNAction::startWithTarget(cocos2d::Node *target)
 {
	 cocos2d::ActionInterval::startWithTarget(target);
     m_fLastInterp = 0;
	 _pastDistance = 0;
     float overflow = 0;
	 
    ((CubicBezierRoute*)_route)->retrieveState(m_pBaseInterpState.m_Position, m_pBaseInterpState.m_Direction, m_pBaseInterpState.m_fSpeedCoef, overflow, _controlPointIndex, 0);
 }

 BesselNAction *BesselNAction::createWithDuration(float duration, std::vector<int> &actionIndexVec, BezierRoute*  route)
 {
	 BesselNAction *nAction = new BesselNAction();
	 nAction->initWithControlPoints(duration, actionIndexVec);
	 nAction->autorelease();
     nAction->_route = route;
	 return nAction;
 }

BesselNAction  *BesselNAction::createWithBezierRoute(float speed, BezierRoute* route)
{
    BesselNAction *nAction = new BesselNAction();
    nAction->initWithBezierRoute(speed, route);
    nAction->autorelease();
    return nAction;
}
 //更新到时间比率
void   BesselNAction::step(float fdt)
{
    fdt = fdt + 0.016 * m_fLastInterp;
    float overflow = 0;
    State currentState;
    State nextState;
	int pointIndex = _controlPointIndex;

    while (fdt > 0.016)
    {
        float currentSpeed = _speed * m_pBaseInterpState.m_fSpeedCoef;
        
		_pastDistance += 0.016 * currentSpeed;
        
        if (_pastDistance < _distance)
        {
            ((CubicBezierRoute*)_route)->retrieveState(m_pBaseInterpState.m_Position, m_pBaseInterpState.m_Direction, m_pBaseInterpState.m_fSpeedCoef, overflow, pointIndex,_pastDistance);
            
            fdt = fdt - 0.016;
        }
//	// //计算相关的旋转分量,X-Z平面向量与X轴的夹角
//	 const float angleOfYOffset = atan2f(dxyzCoeffcient.x,  dxyzCoeffcient.z) - M_PI_2;
//	// //绕Z轴的旋转分量,X-Y平面向量与X轴的夹角
//	 const float dddd = dxyzCoeffcient.x*dxyzCoeffcient.x + dxyzCoeffcient.z * dxyzCoeffcient.z;
//	 assert(dddd>=0.0f);
//	// printf("%f   ", dddd);
//	 const float angleOfZOffset = atan2f(dxyzCoeffcient.y, sqrtf(dddd)) ;
//	 //绕X轴的旋转分量,Y-Z平面向量与Z轴的夹角b
        else
        {
            ((CubicBezierRoute*)_route)->retrieveState(m_pBaseInterpState.m_Position, m_pBaseInterpState.m_Direction, m_pBaseInterpState.m_fSpeedCoef, overflow, pointIndex,_distance - 1);
            
            fdt = 0;
        }
    }
    
    if (_pastDistance > _distance)
    {
        ((CubicBezierRoute*)_route)->retrieveState(currentState.m_Position, currentState.m_Direction, currentState.m_fSpeedCoef, overflow, pointIndex,_distance - 1);
    }
    else
    {
        float currentSpeed = _speed * m_pBaseInterpState.m_fSpeedCoef;
        float futureTime = _pastDistance + 0.016 * currentSpeed;
        futureTime = futureTime < (_distance - 1) ? futureTime : (_distance - 1);
        ((CubicBezierRoute*)_route)->retrieveState(nextState.m_Position, nextState.m_Direction, nextState.m_fSpeedCoef, overflow, pointIndex,futureTime);
        
        m_fLastInterp = fdt / 0.016;
        
        currentState.m_Position = m_pBaseInterpState.m_Position * (1 - m_fLastInterp) + nextState.m_Position * m_fLastInterp;
        currentState.m_Direction = m_pBaseInterpState.m_Direction * (1 - m_fLastInterp) + nextState.m_Direction * m_fLastInterp;
        currentState.m_fSpeedCoef = m_pBaseInterpState.m_fSpeedCoef * (1 - m_fLastInterp) + nextState.m_fSpeedCoef * m_fLastInterp;
    }
    
    _target->setPosition3D(currentState.m_Position);
    
    Vec3 direction = currentState.m_Direction;
    
    float rotY = atan2f(-direction.z, direction.x);
    float rotZ = atanf(direction.y / sqrtf(direction.x * direction.x + direction.z * direction.z));
    
    cocos2d::Quaternion quatY = cocos2d::Quaternion(Vec3(0, 1, 0), rotY);
    cocos2d:: Quaternion quatZ = cocos2d::Quaternion(Vec3(0, 0, 1), rotZ);
    
    _target->setRotationQuat(quatY * quatZ);
	if (_callback)
		_callback(currentState.m_Position);
	//检测是否需要切换动画
	if (pointIndex != _controlPointIndex &&_actionIndexVec[pointIndex] != _actionIndex )//跨过了不同的控制点,且动画索引不同
	{
		_controlPointIndex = pointIndex;
		_actionIndex = _actionIndexVec[pointIndex];
		//切换不同的动画
		if (_actionIndex != 0)
		{
			_target->stopActionByTag(0x87);
			_target->stopActionByTag(0x87);
			Animation3D *animation = Animation3D::create(_aniFile);
			auto &fishAniMap = _fishVisualMap.fishAniVec[_actionIndex];
			auto &firstAniMap = _fishVisualMap.fishAniVec[0];
			/*
			 *注意不能使用Sequence内嵌RepeateForever动作,实验证明这种写法是无效的
			 */
			Animate3D *animate = Animate3D::create(animation, fishAniMap.startFrame / 30.0f, (fishAniMap.endFrame - fishAniMap.startFrame) / 30.0f);
			Action *headAction = Sequence::create(animate,
				CallFunc::create([this, firstAniMap, animation] {
					Action *action = RepeatForever::create(Animate3D::create(animation, firstAniMap.startFrame / 30.0f, (firstAniMap.endFrame - firstAniMap.startFrame) / 30.0f));
					action->setTag(0x87);
					_target->runAction(action);
			}),nullptr);
			headAction->setTag(0x87);
			_target->runAction(headAction);
		}
	}
}

void BesselNAction::update(float time)
{

}

void BesselNode::onEnter()
{
    Node::onEnter();
}

 void     BesselNode::setPreviewModel(const FishVisual &fishMap)
 {
	 _fishVisual = fishMap;
 }
