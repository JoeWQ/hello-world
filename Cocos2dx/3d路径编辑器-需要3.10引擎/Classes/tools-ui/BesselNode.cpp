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
	_besselPointSize = 0;
	_positionLoc = 0;
	_colorLoc = 0;
	_lastSelectIndex = -1;
	_currentSelectIndex = -1;
    _previewSpeed = 100;
    _weight = 0.5;
    _bezierRoute = new CubicBezierRoute();
    _selectedCallback = [](){};
    ((CubicBezierRoute*)_bezierRoute)->setWeight(_weight);
    
    //drawNode = DrawNode3D::create();
    //this->addChild(drawNode);
    
    showLines = true;
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
	 _lineProgram = GLProgram::createWithByteArrays(_static_bessel_Vertex_Shader, _static_bessel_Frag_Shader);
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
	 if (_besselPointSize == pointCount)
		 return;
	 if (_currentSelectIndex >= 0)
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
	 _currentSelectIndex = -1;
	 //检测容器中存留的点的数目,并同时初始化点的坐标
	 const cocos2d::Size &winSize = Director::getInstance()->getWinSize();
	 int  i = 0;
	 //第一阶段，可视化判定
	 const   float  stepX = winSize.width / (pointCount + 1);
	 const   int _oneOrder = pointCount < _besselPointSize ? pointCount : _besselPointSize;
	 //float    disturbFactor[8] = { 1.0f,1.5f,1.5f,1.5f ,1.5f,1.5f,1.5f};
	 const   float  halfWidth = winSize.width / 2.0f;
	 const   float  halfHeight = winSize.height / 2.0f;
	 const   float  disturbFactor[2] = {1.0f,1.5f};
	 for (i = 0; i < _besselContainer.size(); ++i)
	 {
		 ControlPoint		*other = _besselContainer.at(i);
		 other->setVisible(true);
		 //等分屏幕空间
		 other->setPosition3D(Vec3((i+1)*stepX-halfWidth, winSize.height*disturbFactor[i && i != pointCount-1] / 2.0f - halfHeight,0.0f));
	 }
	 //第二阶段,创建新的贝塞尔曲线节点
     
     //_controlPoints.clear();
     
	 for (i = _besselContainer.size(); i < pointCount; ++i)
	 {
		 ControlPoint    *other = ControlPoint::createControlPoint(i);
		 other->setZOrder(i);
		 other->setPosition3D(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != pointCount-1] / 2.0f - halfHeight, 0.0f));
		 other->drawAxis();
		 //需要设置摄像机参数,否则不能被摄像机看到
		 other->setCameraMask(2);
		 this->addChild(other);
		 _besselContainer.push_back(other);
         //_controlPoints.push_back(other->getPosition3D());
	 }
	 //第三阶段,隐藏多余的节点
	 for (i = pointCount; i < _besselContainer.size(); ++i)
	 {
		 _besselContainer.at(i)->setVisible(false);
	 }
	 _besselPointSize = pointCount;
     
     _controlPoints.clear();
     for(int i=0;i<_besselPointSize;++i)
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

 void   BesselNode::initCurveNodeWithPoints(const std::vector<cocos2d::Vec3> &points)
 {
	 //判断是否需要重新创建节点
	 const int originSize = _besselContainer.size();
	 //取消选中的控制点
	 if (_currentSelectIndex >= 0)
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
	 _currentSelectIndex = -1;
	 //
	 if (points.size() > originSize)
	 {
		 for (int i = originSize; i < points.size(); ++i)
		 {
			 ControlPoint    *other = ControlPoint::createControlPoint(i);
			 other->drawAxis();
			 other->setZOrder(i);
			 other->setCameraMask(2);
			 this->addChild(other);
			 _besselContainer.push_back(other);
		 }
	 }
	 //设置相关的数据
	 for (int i = 0; i < points.size(); ++i)
	 {
		 ControlPoint *other = _besselContainer.at(i);
		 other->setVisible(true);
		 other->setPosition3D(points.at(i));
	 }
	 _besselPointSize = points.size();
	 //如果原来的数据已经大于point.size,则隐藏掉多余的节点
	 for (int i = points.size(); i < originSize; ++i)
	 {
		 _besselContainer.at(i)->setVisible(false);
	 }
     _controlPoints.clear();
     for(int i=0;i<_besselPointSize;++i)
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

 void    BesselNode::restoreCurveNodePosition()
 {
	 //检测容器中存留的点的数目,并同时初始化点的坐标
	 const cocos2d::Size &winSize = Director::getInstance()->getWinSize();
	 int  i = 0;
	 //第一阶段，可视化判定
	 const   float  stepX = winSize.width / (_besselPointSize+ 1);
	 //float    disturbFactor[8] = { 1.0f,1.5f,1.5f,1.5f ,1.5f,1.5f,1.5f};
	 const   float  halfWidth = winSize.width / 2.0f;
	 const   float  halfHeight = winSize.height / 2.0f;
	 const   float  disturbFactor[2] = { 1.0f,1.5f };
	 for (i = 0; i < _besselPointSize; ++i)
	 {
		 ControlPoint		*other = _besselContainer.at(i);
		 other->setVisible(true);
		 //等分屏幕空间
		 other->setPosition3D(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != _besselPointSize - 1] / 2.0f - halfHeight, 0.0f));
	 }
 }
 /////////////////////////////////////触屏回掉函数/////////////////////////////////////////
 void    BesselNode::onTouchBegan(const Vec2 &touchPoint, cocos2d::Camera  *camera)
 {
	 _lastOffsetVec2 = touchPoint;
	 //检测是否某一个贝塞尔曲线控制点被选中了
	 const cocos2d::Size  &pointSize = _besselContainer.at(0)->getContentSize();
	 const float  halfWidth = pointSize.width / 2.0f;
	 const float  halfHeight = pointSize.height / 2.0f;
	 _lastSelectIndex = -1;
	 float        _lastZorder=0.0f;
	 for (int j = 0; j < _besselPointSize; ++j)
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
     
     cocos2d::Size winSize = Director::getInstance()->getWinSize();
     Vec3 nearMin = camera->unprojectGL(Vec3(0, 0, -1));
     Vec3 nearMax = camera->unprojectGL(Vec3(winSize.width, winSize.height, -1));
     Vec3 farMin = camera->unprojectGL(Vec3(0, 0, 1));
     Vec3 farMax = camera->unprojectGL(Vec3(winSize.width, winSize.height, 1));
     Vec3 nearCenter = (nearMax - nearMin) / 2;
     Vec3 farCenter = (farMax - farMin) / 2;
     
     Vec3 Pn(touchPoint.x, touchPoint.y, -1), Pf(touchPoint.x, touchPoint.y, 1);
     Pn = camera->unprojectGL(Pn);
     Pf = camera->unprojectGL(Pf);
     
     Pn.x = (Pn.x + nearCenter.x);
     Pn.y = (Pn.y + nearCenter.y);
     
     Pf.x = (Pf.x + farCenter.x);
     Pf.y = (Pf.y + farCenter.y);
     
     Vec3 center = (Pn + Pf) / 2;
     Vec3 zAxis = Pf - Pn;
     zAxis.normalize();
     Vec3 xAxis = Vec3(1, 1, -(zAxis.x + zAxis.y) / zAxis.z);
     xAxis.normalize();
     Vec3 yAxis;
     Vec3::cross(zAxis, xAxis, &yAxis);
     yAxis.normalize();
     
     Vec3 extents = Vec3(10, 10, (Pf - Pn).length());
     
     OBB selector;
     selector.set(center, xAxis, yAxis, zAxis, extents);
     selector._extentX = selector._xAxis * selector._extents.x;
     selector._extentY = selector._yAxis * selector._extents.y;
     selector._extentZ = selector._zAxis * selector._extents.z;
     
     int result = -1;
     float minZ = 10000000;
     Vec3 corners[8];
     
     for (int i = 0; i < _besselPointSize; ++i)
     {
         ControlPoint *current = _besselContainer[i];
         AABB aabb = current->_modelSprite->getAABB();
         Mat4 transform = current->_modelSprite->getNodeToWorldTransform();
         OBB obb = OBB(aabb);
//         obb.transform(transform);
         
         if(obb.intersects(selector) && current->getPosition3D().z < minZ)
         {
             result = i;
         }
         
         obb.getCorners(corners);
//         drawNode->drawCube(corners, Color4F(1.0, 0.0, 0.0, 1.0));
     }
     
//     drawNode->drawLine(Pf, Vec3(0, 0, 0), Color4F(1.0, 0.0, 0.0, 1.0));
//     drawNode->drawLine(Pn, Vec3(0, 0, 0), Color4F(1.0, 0.0, 0.0, 1.0));
//     drawNode->drawLine(Pn, Pf, Color4F(1.0, 0.0, 0.0, 1.0));
     
     _lastSelectIndex = result;
	 //检测以前是否选中了
	 if (_currentSelectIndex >= 0)
	 {
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
	 }
	 _currentSelectIndex = result;
	 if (_currentSelectIndex >= 0)
	 {
		 _besselContainer[_currentSelectIndex]->setCascadeColorEnabled(true);
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::RED);
         _selectedCallback();
	 }
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
		 other->setPosition3D(afterPosition);
		 _lastOffsetVec2 = touchPoint;
	 }
     
     _controlPoints.clear();
     
     for(int i = 0; i < _besselPointSize; i++)
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
     
     if( false )//if(!showLines)
     {
         for(int i = 0; i < _besselPointSize; i++)
         {
             _besselContainer[i]->setVisible(false);
         }
         
         return;
     }
     else
     {
         for(int i = 0; i < _besselPointSize; i++)
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
             Vec3 to = t1 * t1 * t1 * a + t1 * t1 * b + t1 * c + d;
             
//             drawLine(from, to, color);
             vertices.push_back(from);
             vertices.push_back(to);
             
         }while(t != 1);
         
     }
     
	 //将曲线画出来
	 int  _defaultVertex;
	 glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultVertex);
     GL::bindVAO(0);
	 if (_defaultVertex != 0)
		 glBindBuffer(GL_ARRAY_BUFFER, 0);

	 _lineProgram->use();
	 _lineProgram->setUniformsForBuiltins(parentTransform);

	 glEnableVertexAttribArray(_positionLoc);
	 glVertexAttribPointer(_positionLoc, 3, GL_FLOAT, GL_FALSE, 0, vertices.data());

	 glUniform4fv(_colorLoc, 1, &_lineColor.x);
	 glLineWidth(1.0f);

	 glDrawArrays(GL_LINES, 0, vertices.size());

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
	 for (int j = 0; j < _besselPointSize; ++j)
	 {
		 ControlPoint	*other = _besselContainer.at(j);
         Vec3 position = other->getPosition3D();
		 besSet.addNewPoint(position, other->_speedCoef);
         besSet.weight = _weight;
	 }
 }

 void   BesselNode::previewCurive(std::function<void()> callback)
 {
     Node* previewModel = this->getChildByName("PreviewModel");
     if(previewModel)
     {
         previewModel->removeFromParent();
     }
     
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
	  float startTime = _fishVisual.from;
	  float endTime = _fishVisual.to ;
	 cocos2d::Animate3D      *aniAction = cocos2d::Animate3D::create(animation, startTime/30.0f, (endTime - startTime)/30.0f);
	 tempModel->runAction(cocos2d::RepeatForever::create(aniAction));
     tempModel->setName("PreviewModel");

	 this->addChild(tempModel,16);
     
     showLines = false;
     
     _controlPoints.clear();
     for(int i=0;i<_besselPointSize;++i)
     {
         CubicBezierRoute::PointInfo info;
         info.position = _besselContainer[i]->getPosition3D();
         info.speedCoef = _besselContainer[i]->_speedCoef;
         
         _controlPoints.push_back(info);
     }
     
     _bezierRoute->clear();
     _bezierRoute->addPoints(_controlPoints);
     ((CubicBezierRoute*)_bezierRoute)->setWeight(_weight);
	 BesselNAction *action = BesselNAction::createWithBezierRoute(_previewSpeed, _bezierRoute);
     tempModel->runAction(action);
     action->retain();
     
     this->getScheduler()->unschedule("checkEnd", this);
     
     this->getScheduler()->schedule([this, action, tempModel, callback](float dt){
         
         if(action->isDone())
         {
             action->release();
             tempModel->removeFromParent();
             callback();
             this->getScheduler()->unschedule("checkEnd", this);
         }
         
         
     }, this, 0, CC_REPEAT_FOREVER, 0, false, "checkEnd");
//     tempModel->runAction(Sequence::create(action,  CallFuncN::create([=](cocos2d::Node *sender){
//         showLines = true;
//		 sender->removeFromParentAndCleanup(true);
//		 if(callback)
//			callback();
//     }), nullptr));
     
 }
 /////////////////////////////////Action//////////////////////////////////////////////////////////
 void   BesselNAction::initWithControlPoints(float d, std::vector<cocos2d::Vec3> &pointSequence)
 {
	 cocos2d::ActionInterval::initWithDuration(d);
	 _besselPoints = pointSequence;
 }

void   BesselNAction::initWithBezierRoute(float speed, BezierRoute* route)
{
    float duration = route->getDistance();
    
    cocos2d::ActionInterval::initWithDuration(duration);
    
    _speed = speed;
    _route = route;
}

 void  BesselNAction::startWithTarget(cocos2d::Node *target)
 {
	 cocos2d::ActionInterval::startWithTarget(target);
     m_fLastInterp = 0;
     float overflow = 0;
    ((CubicBezierRoute*)_route)->retrieveState(m_pBaseInterpState.m_Position, m_pBaseInterpState.m_Direction, m_pBaseInterpState.m_fSpeedCoef, overflow, 0);
 }

 BesselNAction *BesselNAction::createWithDuration(float duration, std::vector<cocos2d::Vec3> &pointSequence, BezierRoute*  route)
 {
	 BesselNAction *nAction = new BesselNAction();
	 nAction->initWithControlPoints(duration, pointSequence);
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
    
    while (fdt > 0.016)
    {
        float currentSpeed = _speed * m_pBaseInterpState.m_fSpeedCoef;
        
        _elapsed += 0.016 * currentSpeed;
        
        if (_elapsed < _duration)
        {
            ((CubicBezierRoute*)_route)->retrieveState(m_pBaseInterpState.m_Position, m_pBaseInterpState.m_Direction, m_pBaseInterpState.m_fSpeedCoef, overflow, _elapsed);
            
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
            ((CubicBezierRoute*)_route)->retrieveState(m_pBaseInterpState.m_Position, m_pBaseInterpState.m_Direction, m_pBaseInterpState.m_fSpeedCoef, overflow, _duration - 1);
            
            fdt = 0;
        }
    }
    
    if (_elapsed > _duration)
    {
        ((CubicBezierRoute*)_route)->retrieveState(currentState.m_Position, currentState.m_Direction, currentState.m_fSpeedCoef, overflow, _duration - 1);
    }
    else
    {
        float currentSpeed = _speed * m_pBaseInterpState.m_fSpeedCoef;
        float futureTime = _elapsed + 0.016 * currentSpeed;
        futureTime = futureTime < (_duration - 1) ? futureTime : (_duration - 1);
        ((CubicBezierRoute*)_route)->retrieveState(nextState.m_Position, nextState.m_Direction, nextState.m_fSpeedCoef, overflow, futureTime);
        
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
}

void BesselNode::onEnter()
{
    Node::onEnter();
}

 void     BesselNode::setPreviewModel(const FishVisual &fishMap)
 {
	 _fishVisual = fishMap;
 }
