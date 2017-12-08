/*
  *���������ߵ�ʵ��
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
*����������ϵ��
*/
static const float  __static_bessel_coefficient[7][7] = {
	{ 0.0f,0.0f,0.0f, },
	{ 1.0,0.0f },//һ��
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
	 _isSupportedControlPoint = true;//֧�ֿ��Ƶ�ѡ��
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
   *��ʼ�����������߶���
  */
 void    BesselNode::initControlPoint(int pointCount)
 {
	 if (_besselContainer.size() == pointCount)
		 return;
	 _backTraceindex = -1;
	 if (_currentSelectIndex >= 0)
		 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
	 _currentSelectIndex = -1;
	 //��������д����ĵ����Ŀ,��ͬʱ��ʼ���������
	 const cocos2d::Size &winSize = Director::getInstance()->getWinSize();
	 int  i = 0;
	 //��һ�׶Σ����ӻ��ж�
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
			 //��Ҫ�������������,�����ܱ����������
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
	 //�ж��Ƿ���Ҫ���´����ڵ�
	 //ȡ��ѡ�еĿ��Ƶ�
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
	 //��������д����ĵ����Ŀ,��ͬʱ��ʼ���������
	 const cocos2d::Size &winSize = Director::getInstance()->getWinSize();
	 int  i = 0;
	 //��һ�׶Σ����ӻ��ж�
	 const   float  stepX = winSize.width / (_besselContainer.size()+ 1);
	 //float    disturbFactor[8] = { 1.0f,1.5f,1.5f,1.5f ,1.5f,1.5f,1.5f};
	 const   float  halfWidth = winSize.width / 2.0f;
	 const   float  halfHeight = winSize.height / 2.0f;
	 const   float  disturbFactor[2] = { 1.0f,1.5f };
	 for (i = 0; i < _besselContainer.size(); ++i)
	 {
		 ControlPoint		*other = _besselContainer.at(i);
		 other->setVisible(true);
		 //�ȷ���Ļ�ռ�
		 other->setPosition3D(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != _besselContainer.size() - 1] / 2.0f - halfHeight, 0.0f));
         other->setLabelPosition(Vec3((i + 1)*stepX - halfWidth, winSize.height*disturbFactor[i && i != _besselContainer.size() - 1] / 2.0f - halfHeight, 0.0f));
		 other->setColor(Color3B::WHITE);
	 }
	 //�ָ���ѡ�еĵ����ɫ
	 _currentSelectIndex = -1;
	 //������������
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
 /////////////////////////////////////�����ص�����/////////////////////////////////////////
 bool    BesselNode::onTouchBegan(const Vec2 &touchPoint, cocos2d::Camera  *camera)
 {
	 _lastOffsetVec2 = touchPoint;
	 //����Ƿ�ĳһ�����������߿��Ƶ㱻ѡ����
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
		 //ת����OpenGL��������ϵ
		 this->projectToOpenGL(camera, nowPoint, glPosition);
		 
		 if (touchPoint.x >= glPosition.x - halfWidth && touchPoint.x <= glPosition.x + halfWidth
			 && touchPoint.y >= glPosition.y - halfHeight && touchPoint.y <= glPosition.y + halfHeight)
		 {
			 //ѡ�������
			 if (_lastSelectIndex >= 0)//Zorder����
			 {
				 if (glPosition.z < _lastZorder ||
					 (glPosition.z == _lastZorder && other->getLocalZOrder() > _besselContainer.at(_lastSelectIndex)->getLocalZOrder())
					 )//����Zorder����
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
	 //�����ǰ�Ƿ�ѡ����
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
		 //��Ҫ������ƽ���ϵ�ƫ����ת�����µĻ�����ת���������ϵ�ռ���
		 Vec3              newPosition = _rotateMatrix * originVec3 + Vec3(realOffsetVec2.x, realOffsetVec2.y,0.0);
		 //��Ҫ���һ������󣬵��ǿ��ǵ���ת������һ����������,��˴˲�����Լ�,�ڱ��˵ĳ�����,
		 //Ϊ��ʹ��������пɶ���,����û��ʹ��ת�þ���
		 const Mat4				invRotate = _rotateMatrix.getInversed();
		 //��Z�����������
		 Vec3 afterPosition = invRotate * newPosition;
		 //Ŀǰ��Z���������Ϊǰ���ܳ���zeye��1/4
		 auto &winSize = Director::getInstance()->getWinSize();
		 const float zeye = winSize.height / (1.1566f*4.0f);
		 if (afterPosition.z > zeye)
			 afterPosition.z = zeye;
		 //���������,�������Ƶ�ľ��벻��С��4����
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
		 if(changed)//����޸��������������
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
	 //�ٴ��ж��Ƿ�ѡ����ĳһ��
	 if (_currentSelectIndex >= 0)
	 {
		 const cocos2d::Size  &pointSize = _besselContainer.at(0)->getContentSize();
		 const float  halfWidth = pointSize.width / 2.0f;
		 const float  halfHeight = pointSize.height / 2.0f;
		 Vec3     nowPoint = _rotateMatrix * _besselContainer[_currentSelectIndex]->getPosition3D();
		 Vec3     glPosition;
		 //ת����OpenGL��������ϵ
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
		 //�����Ƶ������ƶ�����
		 _besselContainer[_backTraceindex]->removeFromParent();
		 _besselContainer.erase(_besselContainer.begin() + _backTraceindex);
		 //�޸�ĳЩ���Ƶ�Ĵ���
		 for (int i = _backTraceindex; i < _besselContainer.size(); ++i)
			 _besselContainer[i]->changeSequence(i);
		 //���¿��Ƶ������
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
		 //֪ͨ�ϲ�UI,�ײ���Ƶ㷢���˱仯
		 _onUIChangedCallback(_curveType, 0, _besselContainer.size());
		 _backTraceindex = -1;
		 //�����ǰ�Ƿ�ѡ����
		 if (_currentSelectIndex >= 0)
		 {
			 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
			 _currentSelectIndex = -1;
		 }
	 }
 }

 void BesselNode::onMouseClick(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 //����Ѿ������˽ڵ���Ŀ���������,ֱ������
	 if (_besselContainer.size() >= _static_bessel_node_max_count)
	 {
		 return;
	 }
	 //ת��ΪNDC
	 auto &winSize = Director::getInstance()->getWinSize();
	 float ndcx = clickPoint.x / winSize.width * 2.0f;
	 float ndcy = clickPoint.y / winSize.height * 2.0f;
	 //��ԭ������ռ��еĵ�����굽����ռ�
	 Vec4  worldPosition;
	 const Mat4 &mvpMatrix = camera->getViewProjectionMatrix();//ע��,�ڵ㱾����һ����ת����
	 Mat4 inverseMatrix = mvpMatrix.getInversed();
	 inverseMatrix.transformVector(Vec4(ndcx, ndcy, 1.0f, 1.0f), &worldPosition);
	 Vec3   worldPoint(worldPosition.x / worldPosition.w, worldPosition.y / worldPosition.w, worldPosition.z / worldPosition.w);
	 //
	 Vec3 cameraPosition = camera->getPosition3D();
	 //��ȡ����
	 Vec3 ray = (worldPoint - cameraPosition).getNormalized();
	 //����Ƿ���ֱ����
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
		 //���ƽ��,��һ����ֱ����
		 int        S = -1;
		 float      L = 0x7FFFFFFF;
	     float d = D * sqrtf(1.0 - cosValue * cosValue);
	    //���d��ȡֵ��Χ,�����С,�������Ϊ������ֱ����
		 if (d <= 4)//��4����֮��,������Ϊ��ѡ��������ĳһ����
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
		 //�����ǰ�Ƿ�ѡ����
		 if (_currentSelectIndex >= 0)
		 {
			 _besselContainer[_currentSelectIndex]->setColor(Color3B::WHITE);
			 _currentSelectIndex = -1;
		 }
		 const std::vector<int>   &cachedIndex = route->getCachedIndex();
		 int     targetIndex = cachedIndex[selectIndex];
		 //��ȡĿ�������������е�����
		 const Vec3 targetPosition = cachedPositions[selectIndex];
		 //���Ŀ�����ĳһ�����Ƶ��Ƿ����̫��
		 for (int u = 0; u < _besselContainer.size(); ++u)
		 {
			 Vec3 position = _besselContainer[u]->getPosition3D();
			 if ((position - targetPosition).length() <= 24)//��Բ24����֮�ڲ����ٴβ����
				 return;
		 }
		 //��Ҫ�޸ĵ�Ŀ����Ƶ�
		 _backTraceindex = targetIndex+1;
		 //�޸Ŀ��Ƶ�
		 ControlPoint  *cpoint = ControlPoint::createControlPoint(_backTraceindex);
		 cpoint->setPosition3D(targetPosition);
         cpoint->setLabelPosition(targetPosition);
		 cpoint->setCameraMask((short)CameraFlag::USER1);
		 this->addChild(cpoint);
		 //�����Ƶ������ƶ�����
		 _besselContainer.insert(_besselContainer.begin()+ _backTraceindex,cpoint);
		 //�޸�ĳЩ���Ƶ�Ĵ���
		 for (int i = _backTraceindex; i < _besselContainer.size(); ++i)
			 _besselContainer[i]->changeSequence(i);
		 //���¿��Ƶ������
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
		 //֪ͨ�ϲ�UI,�ײ���Ƶ㷢���˱仯
		 _onUIChangedCallback(_curveType, 0, _besselContainer.size());
	 }
 }

 void BesselNode::onMouseMoved(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 //ת��ΪNDC
	 auto &winSize = Director::getInstance()->getWinSize();
 }

 void BesselNode::onMouseReleased(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {

 }

 void BesselNode::onMouseClickCtrl(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
 {
	 //����Ƿ���ģ�����ڽ��ж���
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
 //�ص�����
 void   BesselNode::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
 {
		 _drawBesselCommand.init(_globalZOrder);
		 _drawBesselCommand.func = CC_CALLBACK_0(BesselNode::drawBesselPoint,this,parentTransform,parentFlags);
		 renderer->addCommand(&_drawBesselCommand);
 }
 void BesselNode::drawBesselPoint(cocos2d::Mat4 &parentTransform, uint32_t flag)
 {
	 //����ֽⱴ����������Ҫ���߶���Ŀ,Ĭ�������ÿ4����һ��ֱ��
//	 int  lineCount = 0;
//	 Vec3    startPoint = _besselContainer.at(0)->getPosition3D();
//	 for (int i = 1; i < _besselPointSize; ++i)
//	 {
//		 const  Vec3  &finalPoint = _besselContainer.at(i)->getPosition3D();
//		 lineCount += ceil((finalPoint - startPoint).length() / 4.0f);
//		 startPoint = finalPoint;
//	 }
//	 //���㱴�������ߵĵ�
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
	 //�����߻�����
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
   *��ȡ��ǰ���������Ƶ���ص�����
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
		 //����ActionIndex��Ϊ0������,��������ϸ��distance��ֵ
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
//	 //������ص�ʱ��
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
//	 //3D ģ��
	 const std::string  filename = "3d/"+_fishVisual.name+"/"+_fishVisual.name+".c3b";
	 Sprite3D   *tempModel = Sprite3D::create(filename);
	 tempModel->setPosition3D(_besselContainer.at(0)->getPosition3D());
	 tempModel->setCameraMask((short)CameraFlag::USER1);
	 tempModel->setRotation3D(cocos2d::Vec3::ZERO);
	 tempModel->setScale(_fishVisual.scale);
	 //UIAnimation3D�������ζ�����
	 cocos2d::Animation3D  *animation = cocos2d::Animation3D::create(filename);
	 //ѡȡ��һ�����Ƶ��ϵĶ���
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
	 //�����ϱ�־,�����ڱ��������߶�����ֹͣ�����������
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
	 //�ռ���������
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
 //���µ�ʱ�����
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
//	// //������ص���ת����,X-Zƽ��������X��ļн�
//	 const float angleOfYOffset = atan2f(dxyzCoeffcient.x,  dxyzCoeffcient.z) - M_PI_2;
//	// //��Z�����ת����,X-Yƽ��������X��ļн�
//	 const float dddd = dxyzCoeffcient.x*dxyzCoeffcient.x + dxyzCoeffcient.z * dxyzCoeffcient.z;
//	 assert(dddd>=0.0f);
//	// printf("%f   ", dddd);
//	 const float angleOfZOffset = atan2f(dxyzCoeffcient.y, sqrtf(dddd)) ;
//	 //��X�����ת����,Y-Zƽ��������Z��ļн�b
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
	//����Ƿ���Ҫ�л�����
	if (pointIndex != _controlPointIndex &&_actionIndexVec[pointIndex] != _actionIndex )//����˲�ͬ�Ŀ��Ƶ�,�Ҷ���������ͬ
	{
		_controlPointIndex = pointIndex;
		_actionIndex = _actionIndexVec[pointIndex];
		//�л���ͬ�Ķ���
		if (_actionIndex != 0)
		{
			_target->stopActionByTag(0x87);
			_target->stopActionByTag(0x87);
			Animation3D *animation = Animation3D::create(_aniFile);
			auto &fishAniMap = _fishVisualMap.fishAniVec[_actionIndex];
			auto &firstAniMap = _fishVisualMap.fishAniVec[0];
			/*
			 *ע�ⲻ��ʹ��Sequence��ǶRepeateForever����,ʵ��֤������д������Ч��
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
