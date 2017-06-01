/*
  *贝塞尔曲线点实现
  *2017-3-22
  *@author:xiaoxiong
 */
#include"BesselNode.h"
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
//OpenGL Shader
static const char *__static_bessel_Vertex_Shader = "attribute vec4 a_position;"
"uniform mat4 u_modelMatrix;"
"void main()"
"{"
"		gl_Position  = CC_MVPMatrix * u_modelMatrix * a_position;"
"}";
static const char *__static_bessel_Frag_Shader = "uniform vec4 u_color;"
"void main()"
"{"
"		gl_FragColor = u_color;"
"}";

BesselPoint::BesselPoint()
{
	_modelSprite = NULL;
	_sequence = NULL;
	_iconSprite = NULL;
}

BesselPoint::~BesselPoint()
{
}

void BesselPoint::initBesselPoint(int index)
{
	Node::init();
	_modelSprite = Sprite3D::create("Sprite3d/xiaolvyu/xiaolvyu.c3b");
	_modelSprite->setScale(0.15);
	this->addChild(_modelSprite);

	_iconSprite = Sprite::create("tools-ui/snow.png");
	this->addChild(_iconSprite);

	_sequence = Sprite::create("tools-ui/number_seq.png",Rect(14*index+14,0,14,20));
	this->addChild(_sequence);
	//设置大小尺寸,在后面的触屏操作中将会被用到
	this->setContentSize(_iconSprite->getContentSize());
}

BesselPoint   *BesselPoint::createBesselPoint(int index)
{
	BesselPoint *point = new BesselPoint();
	point->initBesselPoint(index);
	return point;
}
///////////////////////////////////////////////////////////////////////////////////
BesselNode::BesselNode()
{
	_lineProgram = NULL;
	_besselPointSize = 0;
	_positionLoc = 0;
	_colorLoc = 0;
	_modelMatrixLoc = 0;
	_lastSelectIndex = -1;
}

BesselNode::~BesselNode()
{
	_lineProgram->release();
}

 BesselNode   *BesselNode::createBesselNode()
{
	BesselNode  *node = new BesselNode();
	node->initBesselNode();
	return node;
}

 void   BesselNode::initBesselNode()
 {
	 Node::init();
	 initBesselPoint(4);
	 /*
	   *GLProgram
	  */
	 _lineProgram = GLProgram::createWithByteArrays(__static_bessel_Vertex_Shader, __static_bessel_Frag_Shader);
	 _lineProgram->retain();

	 _positionLoc = _lineProgram->getAttribLocation("a_position");
	 _modelMatrixLoc = _lineProgram->getUniformLocation("u_modelMatrix");
	 _colorLoc = _lineProgram->getUniformLocation("u_color");
	 //color
	 _lineColor = Vec4(1.0f,1.0f,1.0f,1.0f);
 }
 /*
   *初始化贝塞尔曲线顶点
  */
 void    BesselNode::initBesselPoint(int pointCount)
 {
	 if (_besselPointSize == pointCount)
		 return;
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
		 BesselPoint		*other = _besselContainer.at(i);
		 other->setVisible(true);
		 //等分屏幕空间
		 other->setPosition3D(Vec3((i+1)*stepX-halfWidth, winSize.height*disturbFactor[i && i != pointCount-1] / 2.0f - halfHeight,0.0f));
	 }
	 //第二阶段,创建新的贝塞尔曲线节点
	 for (i = _besselContainer.size(); i < pointCount; ++i)
	 {
		 BesselPoint    *other = BesselPoint::createBesselPoint(i);
		 other->setZOrder(i);
		 other->setPosition3D(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != pointCount-1] / 2.0f - halfHeight, 0.0f));
		 //需要设置摄像机参数,否则不能被摄像机看到
		 other->setCameraMask(2);
		 this->addChild(other);
		 _besselContainer.push_back(other);
	 }
	 //第三阶段,隐藏多余的节点
	 for (i = pointCount; i < _besselContainer.size(); ++i)
	 {
		 _besselContainer.at(i)->setVisible(false);
	 }
	 _besselPointSize = pointCount;
 }

 void    BesselNode::setRotateMatrix(const cocos2d::Mat4 &rotateMatrix)
 {
	 _rotateMatrix = rotateMatrix;
 }

 void    BesselNode::setLineColor(cocos2d::Vec4 &color)
 {
	 _lineColor = color;
 }
 void   BesselNode::projectToOpenGL(cocos2d::Camera *camera,const cocos2d::Vec3 &src, cocos2d::Vec3 &dts)
 {
	 auto &viewport = Director::getInstance()->getWinSize();
	 Vec4 clipPos;
	 camera->getViewProjectionMatrix().transformVector(Vec4(src.x, src.y, src.z, 1.0f), &clipPos);

	 CCASSERT(clipPos.w != 0.0f, "clipPos.w can't be 0.0f!");
	 float ndcX = clipPos.x / clipPos.w;
	 float ndcY = clipPos.y / clipPos.w;

	 dts.x = ndcX  * 0.5f * viewport.width;
	 dts.y = ndcY* 0.5f * viewport.height;
	 dts.z = clipPos.z/clipPos.w ;
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
		 BesselPoint    *other = _besselContainer.at(j);
		 Vec3     nowPoint =_rotateMatrix * other->getPosition3D();
		 Vec3     glPosition;
		 //转换到OpenGL世界坐标系
		 this->projectToOpenGL(camera, nowPoint, glPosition);
		 
		 if (touchPoint.x >= glPosition.x - halfWidth && touchPoint.x <= glPosition.x + halfWidth
			 && touchPoint.y >= glPosition.y - halfHeight && glPosition.y <= glPosition.y + halfHeight)
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
 }

 void    BesselNode::onTouchMoved(const Vec2  &touchPoint, cocos2d::Camera  *camera)
 {
	 if (_lastSelectIndex >= 0)
	 {
		 Vec2    realOffsetVec2 =touchPoint - _lastOffsetVec2;
//		 Vec3    OffsetVec3 = _rotateMatrix * Vec3(realOffsetVec2.x,realOffsetVec2.y,0.0f);
		 BesselPoint   *other = _besselContainer.at(_lastSelectIndex);
		 const Vec3    &originVec3 = other->getPosition3D();
		 //需要将这种平面上的偏移量转换到新的基于旋转矩阵的坐标系空间中
		 Vec3              newPosition = _rotateMatrix * originVec3 + Vec3(realOffsetVec2.x, realOffsetVec2.y,0.0);
		 //需要求解一次逆矩阵，但是考虑到旋转矩阵是一种正交矩阵,因此此步骤可以简化,在本人的程序中,
		 //为了使代码更具有可读性,本人没有使用转置矩阵
		 const Mat4				invRotate = _rotateMatrix.getInversed();
		 other->setPosition3D(invRotate * newPosition);
		 _lastOffsetVec2 = touchPoint;
	 }
 }

 void   BesselNode::onTouchEnded(const Vec2 &touchPoint, cocos2d::Camera  *camera)
 {
	 _lastSelectIndex = -1;
 }

 void  BesselNode::onCtrlKeyRelease()
 {
	 _lastSelectIndex = -1;
 }
 /////////////////////////////////////////////////////////////////////////////////////////////
 //回掉函数
 void   BesselNode::visit(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
 {
	 if (!_visible)
		 return;
	 //因为涉及到BesselUI中设置了摄像机参数
	 if (isVisitableByVisitingCamera())
	 {
		 _drawBesselCommand.init(_globalZOrder);
		 _drawBesselCommand.func = CC_CALLBACK_0(BesselNode::drawBesselPoint,this,parentTransform,parentFlags);
		 renderer->addCommand(&_drawBesselCommand);
		 Node::visit(renderer,parentTransform,parentFlags);
	 }
 }
 void BesselNode::drawBesselPoint(cocos2d::Mat4 &parentTransform, uint32_t flag)
 {
	 //计算分解贝塞尔曲线需要的线段数目,默认情况下每4像素一条直线
	 int  lineCount = 0;
	 Vec3    startPoint = _besselContainer.at(0)->getPosition3D();
	 for (int i = 1; i < _besselPointSize; ++i)
	 {
		 const  Vec3  &finalPoint = _besselContainer.at(i)->getPosition3D();
		 lineCount += ceil((finalPoint - startPoint).length() / 4.0f);
		 startPoint = finalPoint;
	 }
	 //计算贝塞尔曲线的点
	 float   *Vertex = new float[lineCount * 3 + 3];
	 Vec3   *linePoints = (Vec3 *)Vertex;
	 const  int  _pointSize = _besselPointSize;
	 for (int j = 0; j < lineCount + 1; ++j)
	 {
		 cocos2d::Vec3  linePoint;
		 const  float  t = 1.0f*j / lineCount;
		 const  float  one_minus_t = 1.0f - t;
		 for (int k = 0; k < _besselPointSize; ++k)
		 {
			 //const  Vec3 position3D = _besselContainer.at(k)->getPosition3D();
			 linePoint += __static_bessel_coefficient[_pointSize - 1][k] * powf(one_minus_t, _pointSize - k - 1) * powf(t, k) *_besselContainer.at(k)->getPosition3D();
		 }
		 linePoints[j] = linePoint;
	 }
	 //将曲线画出来
	 int  _defaultVertex;
	 glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultVertex);
	 if (_defaultVertex != 0)
		 glBindBuffer(GL_ARRAY_BUFFER, 0);

	 _lineProgram->use();
	 _lineProgram->setUniformsForBuiltins(parentTransform);

	 glEnableVertexAttribArray(_positionLoc);
	 glVertexAttribPointer(_positionLoc, 3, GL_FLOAT, GL_FALSE, 0, linePoints);

	 glUniform4fv(_colorLoc, 1, &_lineColor.x);
	 glUniformMatrix4fv(_modelMatrixLoc, 1, GL_FALSE, _rotateMatrix.m);
	 glLineWidth(1.0f);

	 glDrawArrays(GL_LINE_STRIP, 0, lineCount + 1);

	 if (_defaultVertex != 0)
		 glBindBuffer(GL_ARRAY_BUFFER, _defaultVertex);
	 delete[] Vertex;
	 Vertex = NULL;
 }
 /*
   *获取当前贝塞尔控制点相关的数据
  */
 void BesselNode::getBesselPoints(BesselSet &besSet)
 {
	 for (int j = 0; j < _besselPointSize; ++j)
	 {
		 BesselPoint	*other = _besselContainer.at(j);
		 besSet.addNewPoint(other->getPosition3D());
	 }
 }

 void   BesselNode::previewCurive(std::function<void(float)> actionFinishedCallback)
 {
	 //计算相关的时间
	 std::vector<cocos2d::Vec3>  pointSequence;
	 pointSequence.reserve(_besselPointSize);
	 //
	 float   realDistance = 0.0f;
	 Vec3  startPoint = _besselContainer.at(0)->getPosition3D();
	 for (int j = 0; j < _besselPointSize; ++j)
	 {
		 BesselPoint  *other = _besselContainer.at(j);
		 const Vec3 &nowPoint = other->getPosition3D();
		 realDistance += (nowPoint - startPoint).length();
		 startPoint = nowPoint;
		 pointSequence.push_back(nowPoint);
	 }
	 const float duration = realDistance / Director::getInstance()->getWinSize().width * 8.0f;
	 //3D 模型
	 const std::string  filename = "Sprite3d/bianfuyu/bianfuyu.c3b";
	 Sprite3D   *tempModel = Sprite3D::create(filename);
	 tempModel->setPosition3D(_besselContainer.at(0)->getPosition3D());
	 tempModel->setCameraMask((short)CameraFlag::USER1);
	 tempModel->setScale(0.15f);
	 //UIAnimation3D，播放游动动作
	 cocos2d::Animation3D  *animation = cocos2d::Animation3D::create(filename);
	 const float startTime = 0.0f;
	 const float endTime = 60.0f / 30.0f;
	 cocos2d::Animate3D      *aniAction = cocos2d::Animate3D::create(animation, startTime, endTime - startTime);
	 tempModel->runAction(cocos2d::RepeatForever::create(aniAction));

	 this->addChild(tempModel,16);
	 BesselNAction  *action = BesselNAction::createWithDuration(duration, pointSequence);

	 tempModel->runAction(Sequence::create(action, CallFuncN::create([=](cocos2d::Node *psender) {
		 actionFinishedCallback(duration);
		 psender->removeFromParentAndCleanup(true);
	 }), NULL));
 }
 /////////////////////////////////Action//////////////////////////////////////////////////////////
 void   BesselNAction::initWithControlPoints(float d, std::vector<cocos2d::Vec3> &pointSequence)
 {
	 cocos2d::ActionInterval::initWithDuration(d);
	 _besselPoints = pointSequence;
 }

 void  BesselNAction::startWithTarget(cocos2d::Node *target)
 {
	 cocos2d::ActionInterval::startWithTarget(target);
 }

 BesselNAction *BesselNAction::createWithDuration(float duration, std::vector<cocos2d::Vec3> &pointSequence)
 {
	 BesselNAction *nAction = new BesselNAction();
	 nAction->initWithControlPoints(duration, pointSequence);
	 nAction->autorelease();
	 return nAction;
 }
 //更新到时间比率
 void   BesselNAction::update(float timeRate)
 {
	 cocos2d::Vec3  linePoint;
	 const  float  one_minus_t = 1.0f - timeRate;
	 const  int     _nowSize=_besselPoints.size();
	 const  int     expCoeffcient = _nowSize - 1;
	 const  float	 *CoeffcientVertex=(float *)( __static_bessel_coefficient+ expCoeffcient);
	 for (int k = 0; k < _nowSize; ++k)
	 {
		 linePoint += CoeffcientVertex[k] * powf(one_minus_t, expCoeffcient - k) * powf(timeRate, k) *_besselPoints.at(k);
	 }
	 _target->setPosition3D(linePoint);

	 //计算在该插值点各个坐标轴分量关于 rate的偏导数
	 cocos2d::Vec3    dxyzCoeffcient = -expCoeffcient * powf(one_minus_t, expCoeffcient - 1) * _besselPoints[0];
	 dxyzCoeffcient += expCoeffcient *powf(timeRate, expCoeffcient - 1)* _besselPoints[expCoeffcient];
	 //
	 for (int j = 1; j < expCoeffcient; ++j)
	 {
		 const    float halfCoeff = -1.0f *(expCoeffcient - j) * powf(one_minus_t, expCoeffcient - 1 - j)*powf(timeRate, j);
		 const    float otherCoeff = j* powf(one_minus_t, expCoeffcient - j)*powf(timeRate, j - 1);
		 dxyzCoeffcient += CoeffcientVertex[j] * (halfCoeff + otherCoeff) * _besselPoints.at(j);
	 }
	 //计算相关的旋转分量,X-Z平面向量与X轴的夹角
	 const float angleOfYOffset = atan2f(dxyzCoeffcient.x,  dxyzCoeffcient.z) - M_PI_2;
	 //绕Z轴的旋转分量,X-Y平面向量与X轴的夹角
	 const float angleOfZOffset = atan2f(dxyzCoeffcient.y, sqrtf(dxyzCoeffcient.x*dxyzCoeffcient.x+dxyzCoeffcient.z+dxyzCoeffcient.z)) ;
	 //绕X轴的旋转分量,Y-Z平面向量与Z轴的夹角b
	 //const float angleOfXOffset = atan2f(fabs(dxyzCoeffcient.z),fabs(dxyzCoeffcient.y));

	 cocos2d::Quaternion  rotateQuaternion = cocos2d::Quaternion(Vec3(0.0f, 1.0f, 0.0f), angleOfYOffset) * cocos2d::Quaternion(Vec3(0.0f, 0.0f, 1.0f), angleOfZOffset);

	 _target->setRotationQuat(rotateQuaternion);

	 dxyzCoeffcient = dxyzCoeffcient.getNormalized();

 }