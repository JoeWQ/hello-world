/*
  *�����߽ڵ�
  *@2017-07-12
  @Author:xiaoxiong
  *@Version 1.0:ʵ����Բ��������
 */
#include "SpiralNode.h"
#include<math.h>
/*
  *�����ĸ����Ƶ�ĺ���
 */
#define _CONTROL_POINT_MOVE_        0 //�ƶ������ߵĿ��Ƶ�
#define _CONTROL_POINT_ROTATE_    1 //�϶���ת��Ŀ��Ƶ�
#define _CONTROL_POINT_RADIUS0_  2 //�޸������߰뾶�Ŀ��Ƶ�
#define _CONTROL_POINT_RADIUS1_   3 //�޸������߰뾶�Ŀ��Ƶ�,����������Ծ��������ߵĻ�������(Բ��/Բ׶)
#define _CONTROL_POINT_WIND_        4 //�޸������ߵ�����
#define _CONTROL_POINT_SPIRAL_      5 //�޸������ߵĵ���
#define _CONTROL_POINT_COUNT_      6 //���Ƶ����Ŀ
//��ʼ�����߰뾶
#define _ORIGIN_RADIUS_    50.0f

USING_NS_CC;
SpiralNode::SpiralNode():CurveNode(CurveType::CurveType_Spiral)
,_rotateAxis(0.0f,1.0f,0.0f)
,_radius0(_ORIGIN_RADIUS_)
,_radius1(_ORIGIN_RADIUS_)
,_spiralHeight( _ORIGIN_RADIUS_)
,_clockwise(1.0f)
, _windCount(1.0f)
,_vertexCount(0)
, _axisNode(nullptr)
, _lastSelectIndex(-1)
{
	_controlPoints[0] = nullptr;
	_controlPoints[1] = nullptr;
	_controlPoints[2] = nullptr;
	_controlPoints[3] = nullptr;
	_controlPoints[4] = nullptr;
	_controlPoints[5] = nullptr;
	_vertexData = nullptr;
}

SpiralNode::~SpiralNode()
{
	_glProgram->release();
	_glProgram = nullptr;
	delete _vertexData;
	_vertexData = nullptr;
}

void SpiralNode::initSpiralNode()
{
	//��������ϵ
	_controlPoints[_CONTROL_POINT_MOVE_] = ControlPoint::createControlPoint(_CONTROL_POINT_MOVE_);
	_controlPoints[_CONTROL_POINT_ROTATE_] = ControlPoint::createControlPoint(_CONTROL_POINT_ROTATE_);
	_controlPoints[_CONTROL_POINT_RADIUS0_] = ControlPoint::createControlPoint(_CONTROL_POINT_RADIUS0_);
	_controlPoints[_CONTROL_POINT_RADIUS1_] = ControlPoint::createControlPoint(_CONTROL_POINT_RADIUS1_);
	_controlPoints[_CONTROL_POINT_WIND_] = ControlPoint::createControlPoint(_CONTROL_POINT_WIND_);
	_controlPoints[_CONTROL_POINT_SPIRAL_] = ControlPoint::createControlPoint(_CONTROL_POINT_SPIRAL_);
	//auto &winSize = Director::getInstance()->getWinSize();
	//��������
	_controlPoints[_CONTROL_POINT_MOVE_]->setPosition(Vec2());//���ĵ�
	//������ת������ĵ�
	_controlPoints[_CONTROL_POINT_ROTATE_]->setPosition(Vec2(0.0f, _spiralHeight/2.0f + 60.0f));
	//�ײ����ư뾶�����ĵ�
	_controlPoints[_CONTROL_POINT_RADIUS0_]->setPosition(Vec2(_radius0,-_spiralHeight/2.0f));
	_controlPoints[_CONTROL_POINT_RADIUS1_]->setPosition(Vec2(_radius1, _spiralHeight/2.0f));
	//���������ߵĵ���
	_controlPoints[_CONTROL_POINT_SPIRAL_]->setPosition(Vec2(0.0f,-_spiralHeight/2.0f));
	//���������ߵ����������ĵ�
	_controlPoints[_CONTROL_POINT_WIND_]->setPosition(Vec2(0.0f,_spiralHeight/2.0f));
	for (int i = 0; i < _CONTROL_POINT_COUNT_; ++i)
	{
		this->addChild(_controlPoints[i]);
		_controlPoints[i]->setCameraMask((short)CameraFlag::USER1);
	}
	_glProgram = GLProgramCache::getInstance()->getGLProgram(_SHADER_TYPE_MODEL_);
	if (!_glProgram)
	{
		_glProgram = cocos2d::GLProgram::createWithByteArrays(_static_spiral_Vertex_Shader, _static_spiral_Frag_Shader);
		GLProgramCache::getInstance()->addGLProgram(_glProgram, _SHADER_TYPE_MODEL_);
	}
	_glProgram->retain();
	_positionLoc = _glProgram->getAttribLocation("a_position");
	_colorLoc = _glProgram->getUniformLocation("u_color");
	_modelMatrixLoc = _glProgram->getUniformLocation("u_modelMatrix");
	_axisNode = DrawNode3D::create();
	this->addChild(_axisNode, 2);
	updateVertexData(true);
}

SpiralNode   *SpiralNode::createSpiralNode()
{
	SpiralNode *node = new SpiralNode();
	node->initSpiralNode();
	node->autorelease();
	return node;
}
float SpiralNode::getSpiralLength()const
{
	//�������ߵĳ���
	const int integrity = (int)_windCount;//����������
	const float frag = _windCount - integrity;//ʣ��Ĳ���һ��������
	float length = 0.0f;
	const float realRadius = _radius0+ (_radius1-_radius0) / _windCount * integrity;
	for (int k = 1; k <= integrity; ++k)
	{
		float lastRadius = _radius0 + 1.0f *(k - 1) / integrity * (realRadius - _radius0);
		float nowRadius = _radius0 + 1.0f *k / integrity * (realRadius - _radius0);
		float tmp = (lastRadius + nowRadius)*M_PI;
		length += sqrtf(tmp * tmp + _spiralHeight * _spiralHeight);
	}
	//�ۼ���ʣ���β��
	float tmp = M_PI *(realRadius + realRadius + 1.0f/integrity *(realRadius-_radius0));
	length += frag * sqrtf(tmp * tmp + _spiralHeight * _spiralHeight);
	return length;
}

//���¶�������,�������Ƶ��λ��
void  SpiralNode::updateVertexData(bool needUpdateVertex)
{
	const float height = _spiralHeight*_windCount;
	//��ת���λ��
	auto centerPoint = _controlPoints[_CONTROL_POINT_MOVE_]->getPosition3D();
	//������ת��Ŀ��Ƶ�
	_controlPoints[_CONTROL_POINT_ROTATE_]->setPosition3D(centerPoint+_rotateAxis * (height /2.0f + 60.0f));
	//���㼶������
	Mat4  translateMatrix;
	cocos2d::Mat4::createTranslation(centerPoint,&translateMatrix);
	_modelMatrix = translateMatrix * _curveRotateMatrix;
	//�ײ����ư뾶�Ŀ��Ƶ�
	Vec4  point = _modelMatrix *Vec4(_radius0, -height / 2.0f,0.0f,1.0f);
	_controlPoints[_CONTROL_POINT_RADIUS0_]->setPosition3D(Vec3(point.x, point.y, point.z));
	//�������ư뾶�Ŀ��Ƶ�
	Vec4 point1 =  _modelMatrix *Vec4(_radius1, height / 2.0f,0.0f,1.0f);
	_controlPoints[_CONTROL_POINT_RADIUS1_]->setPosition3D(Vec3(point1.x, point1.y, point1.z));
	//���������ߵĵ���
	_controlPoints[_CONTROL_POINT_SPIRAL_]->setPosition3D(centerPoint+ _rotateAxis *(-height/2.0f));
	//�����������������Ŀ��Ƶ�
	Vec4 point2 =  _modelMatrix * Vec4(0.0f, height / 2.0f,0.0f,1.0f);
	_controlPoints[_CONTROL_POINT_WIND_]->setPosition3D(Vec3(point2.x, point2.y, point2.z));
	if (needUpdateVertex)
	{
		//���㶥������
		if (_vertexData)
			delete _vertexData;
		float length = getSpiralLength();
		//�ֶ�,ÿ6����һ���߶�
		float seg = 6.0f;
		if (length > 1000000)
			seg = 48;
		else if (length > 100000)
			seg = 24;
		else if (length > 50000)
			seg = 16;
		else if (length > 10000)
			seg = 8;
		_vertexCount = ceil(length / seg);
		_vertexData = new float[_vertexCount * 3];
		int  index = 0;
		//ע���߶���ָ���ߵĸ߶ȵ�һ��������ߵĻ��ֵ�һ��
		const float halfHeight = height / 2.0f;
		const float paix2 = 2.0f * M_PI * _clockwise;//�˴�����������������Ƿ�����ʱ����ת
		const float totalAngle = paix2 * _windCount;
		for (int k = 0; k < _vertexCount; ++k)
		{
			const float rate = 1.0f *k / _vertexCount;
			float  angle = rate * totalAngle;
			float radius = _radius0 + (_radius1 - _radius0)*angle / totalAngle;
			_vertexData[index] = radius * sinf(angle);
			float vertexHeight = _spiralHeight * angle / paix2 - halfHeight;
			_vertexData[index + 1] = vertexHeight;
			_vertexData[index + 2] = radius * cosf(angle);
			index += 3;
		}
	}
	//����ת��
	_axisNode->clear();
	const Vec3 topPoint = centerPoint+_rotateAxis * height /2.0f;
	const Vec3 bottomPoint = centerPoint+_rotateAxis *(-height /2.0f);
	_axisNode->drawLine(centerPoint+_rotateAxis * (height /2.0f+60.0f), bottomPoint,Color4F(1.0f,0.0f,1.0f,1.0f));//��ת��
	_axisNode->drawLine(bottomPoint, Vec3(point.x, point.y, point.z),Color4F(1.0f,1.0f,0.0f,1.0f));//�ײ��뾶
	_axisNode->drawLine(topPoint, Vec3(point1.x, point1.y, point1.z),Color4F(0.3f,0.0f,1.0f,1.0f));//�����뾶
	//�뾶�����˱仯
	if (_onUIChangedCallback)
	{
		_onUIChangedCallback(_curveType, SpiralValueType::SpiralValueType_BottomRadius, _radius0);
		_onUIChangedCallback(_curveType, SpiralValueType::SpiralValueType_TopRadius, _radius1);
	}
}

void SpiralNode::updateRotateMatrix(const cocos2d::Vec3 &rotateAxis)
{
	//��ת����
	Vec3  axis;
	Vec3::cross(Vec3(0.0f, 1.0f, 0.0f), rotateAxis, &axis);
	axis.normalize();
	const float dotValue = Vec3::dot(rotateAxis, Vec3(0.0f, 1.0f, 0.0f));
	const float angle = acosf(dotValue);
	Mat4::createRotation(axis, angle, &_curveRotateMatrix);
}

void SpiralNode::setBottomRadius(float radius)
{
	if (radius < _ORIGIN_RADIUS_)
		radius = _ORIGIN_RADIUS_;
	_radius0 = radius;
}

void SpiralNode::setTopRadius(float radius)
{
	if (radius < _ORIGIN_RADIUS_)
		radius = _ORIGIN_RADIUS_;
	_radius1 = radius;
}

void  SpiralNode::setCCWValue(float ccwValue)
{
	if (ccwValue != _clockwise)
	{
		_clockwise = ccwValue;
		updateVertexData(true);
	}
}

void  SpiralNode::initControlPoint(int pointCount)
{

}

void SpiralNode::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& parentTransform, uint32_t parentFlags)
{
		_drawCommand.init(_globalZOrder);
		_drawCommand.func = CC_CALLBACK_0(SpiralNode::drawSpiralNode, this, parentTransform, parentFlags);
		renderer->addCommand(&_drawCommand);
}

void SpiralNode::drawSpiralNode(cocos2d::Mat4 &parentTransform, uint32_t parentFlags)
{
	//�����߻�����
	int  _defaultVertex;
    GL::bindVAO(0);
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &_defaultVertex);
	if (_defaultVertex != 0)
		glBindBuffer(GL_ARRAY_BUFFER, 0);

	_glProgram->use();
	_glProgram->setUniformsForBuiltins(parentTransform);

	glEnableVertexAttribArray(_positionLoc);
	glVertexAttribPointer(_positionLoc, 3, GL_FLOAT, GL_FALSE, 0, _vertexData);

	glUniform4fv(_colorLoc, 1, &_lineColor.x);

	glUniformMatrix4fv(_modelMatrixLoc, 1, GL_FALSE, _modelMatrix.m);
	glLineWidth(1.0f);

	glDrawArrays(GL_LINE_STRIP, 0, _vertexCount);

	if (_defaultVertex != 0)
		glBindBuffer(GL_ARRAY_BUFFER, _defaultVertex);
}

void SpiralNode::initCurveNodeWithPoints(const ControlPointSet  &controlPointSet)
{
	const std::vector<RouteProtocol::PointInfo>  &points = controlPointSet._pointsSet;
	_rotateAxis = points[0].position;//��ת��
	_controlPoints[_CONTROL_POINT_MOVE_]->setPosition3D(points[1].position);//��������
	const Vec3 &point = points[2].position;
	//���ϰ뾶
	_radius0 = point.x;
	_radius1 = point.y;
	//����
	_spiralHeight = point.z;
	//����
	_windCount = points[3].position.x;
	_clockwise =	points[3].position.y;
	updateRotateMatrix(_rotateAxis);
	updateVertexData(true);
}

void SpiralNode::restoreCurveNodePosition()
{
	//������ص�����
	_radius0 = _ORIGIN_RADIUS_;
	_radius1 = _ORIGIN_RADIUS_;
	_windCount = 1.0f;
	_rotateAxis = Vec3(0.0f, 1.0f, 0.0f);
	_controlPoints[_CONTROL_POINT_MOVE_]->setPosition3D(Vec3());
	updateRotateMatrix(_rotateAxis);
	updateVertexData(true);
}

void SpiralNode::previewCurive(std::function<void()> callback)
{
	//����Ƿ����в�����
	Node *lastMode = this->getChildByName("PreviewModel");
	if (lastMode != nullptr)
		lastMode->removeFromParent();
	const std::string  filename = "3d/" + _fishVisual.name + "/" + _fishVisual.name + ".c3b";
	Sprite3D   *tempModel = Sprite3D::create(filename);
	tempModel->setPosition3D(_controlPoints[_CONTROL_POINT_MOVE_]->getPosition3D());
	tempModel->setCameraMask((short)CameraFlag::USER1);
	tempModel->setRotation3D(cocos2d::Vec3::ZERO);
	tempModel->setScale(_fishVisual.scale);
	//UIAnimation3D�������ζ�����
	cocos2d::Animation3D  *animation = cocos2d::Animation3D::create(filename);
	//ѡȡ��һ������
	auto &fishAniMap = _fishVisual.fishAniVec[0];
	cocos2d::Animate3D      *aniAction = cocos2d::Animate3D::create(animation, fishAniMap.startFrame / 30.0f, (fishAniMap.endFrame - fishAniMap.startFrame) / 30.0f);
	tempModel->runAction(cocos2d::RepeatForever::create(aniAction));
	tempModel->setName("PreviewModel");

	this->addChild(tempModel, 16);
	//�������ߵĳ���
	float  length = getSpiralLength();
	auto &winSize = Director::getInstance()->getWinSize();
	//
	float timeCost = length / winSize.width * 6.0f;
	SpiralAction *action = SpiralAction::create(timeCost,_rotateAxis, _controlPoints[_CONTROL_POINT_MOVE_]->getPosition3D(),
		_radius0,_radius1,_spiralHeight,_windCount, _clockwise);
	tempModel->runAction(cocos2d::Sequence::create(
		action,
		CallFuncN::create([=](cocos2d::Node *sender) {
			sender->removeFromParentAndCleanup(true);
			if (callback)
				callback();
			}),
		nullptr
	));
}
//�����ص�����
bool  SpiralNode::onTouchBegan(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{
	_lastSelectIndex = -1;
	float lastZOrder = 0.0f;
	//���㴥��������
	auto &pointSize = _controlPoints[0]->getContentSize();
	float   halfWidth = pointSize.width/2.0f;
	float   halfHeight = pointSize.height / 2.0f;
	for (int j = 0; j < _CONTROL_POINT_COUNT_; ++j)
	{
		Vec3    point = _controlPoints[j]->getPosition3D();
		Vec3     nowPoint = _rotateMatrix * point;
		Vec3     glPosition;
		//ת����OpenGL��������ϵ
		projectToOpenGL(camera, nowPoint, glPosition);

		if (touchPoint.x >= glPosition.x - halfWidth && touchPoint.x <= glPosition.x + halfWidth
			&& touchPoint.y >= glPosition.y - halfHeight && touchPoint.y <= glPosition.y + halfHeight)
		{
			//ѡ�������
			if (_lastSelectIndex >= 0)//Zorder����
			{
				if (glPosition.z < lastZOrder ||
					(glPosition.z == lastZOrder &&  _controlPoints[j]->getLocalZOrder() >  _controlPoints[_lastSelectIndex]->getLocalZOrder())
					)//����Zorder����
				{
					_lastSelectIndex = j;
					lastZOrder = glPosition.z;
				}
			}
			else
			{
				_lastSelectIndex = j;
				lastZOrder = glPosition.z;
			}
		}
	}
	_lastOffsetPoint = touchPoint;
	return true;
}

void SpiralNode::onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{
	if (_lastSelectIndex < 0)
		return;
	Vec2  offsetVec = touchPoint - _lastOffsetPoint;
	//�������
	cocos2d::Mat4  inverseMat4 = _rotateMatrix.getInversed();
	//
	Vec3   afterPoint;
	inverseMat4.transformPoint(cocos2d::Vec3(offsetVec.x, offsetVec.y, 0.0f ), &afterPoint);
	Vec3 centerPoint = _controlPoints[_CONTROL_POINT_MOVE_]->getPosition3D();
	//�Ƿ���Ҫ���¶�������
	bool   needUpdateVertex = false;
	//���ѡ��������ƽ�ƿ��Ƶ�
	if (_lastSelectIndex == _CONTROL_POINT_MOVE_)
	{
		_controlPoints[_CONTROL_POINT_MOVE_]->setPosition3D(centerPoint + afterPoint);
	}
	else if (_lastSelectIndex == _CONTROL_POINT_ROTATE_)//��ת��,�˴������Ƚϸ���
	{
		//���������ߵ���ת����
		Vec3 point = _controlPoints[_CONTROL_POINT_ROTATE_]->getPosition3D();
		_rotateAxis = (point + afterPoint - centerPoint).getNormalized();//���뵥λ��
		//��ת����
		Vec3  axis; 
		Vec3::cross(Vec3(0.0f, 1.0f, 0.0f), _rotateAxis,&axis);
		axis.normalize();
		const float dotValue = Vec3::dot(_rotateAxis, Vec3(0.0f, 1.0f, 0.0f));
		const float angle = acosf(dotValue);
		Mat4::createRotation(axis, angle,&_curveRotateMatrix);
	}
	else if (_lastSelectIndex == _CONTROL_POINT_RADIUS0_)//�޸��·��İ뾶
	{
		//������Ҫ���������С�İ뾶�ķ�Χ
		Vec3 point = _controlPoints[_CONTROL_POINT_RADIUS0_]->getPosition3D();
		Vec3 centerRadiusPoint = centerPoint - (0.5f * _spiralHeight * _windCount) * _rotateAxis;//���Ű뾶�ķ���������ߵ����ĵ�
		//�϶��ķ��������뾶�ķ���һ����仯��Ϊ����
		Vec3 direction = (point - centerRadiusPoint).getNormalized();
		float dotValue = Vec3::dot(direction,afterPoint);
		float newRadius = _radius0 + dotValue * afterPoint.length() * 0.067;
		//�ض�
		if (newRadius < _ORIGIN_RADIUS_)
			newRadius = _ORIGIN_RADIUS_;
		if(newRadius != _radius0)
			needUpdateVertex = true;
		_radius0 = newRadius;
	}
	else if (_lastSelectIndex == _CONTROL_POINT_RADIUS1_)//�Ϸ��İ뾶
	{
		//������Ҫ��С��������İ뾶�ķ�Χ
		Vec3 point = _controlPoints[_CONTROL_POINT_RADIUS1_]->getPosition3D();
		Vec3 centerRadiusPoint = centerPoint + (0.5f * _spiralHeight * _windCount) * _rotateAxis;
		//�����϶��ķ���
		Vec3 direction = (point - centerRadiusPoint).getNormalized();
		float dotValue = Vec3::dot(direction,afterPoint);
		float radius = _radius1 +  dotValue * afterPoint.length() * 0.067f;
		//���ݽض�
		if (radius < 50.0f)
			radius = 50.0f;
		//ֻ�����Ҫ������²Ż���¶�������
		if (_radius1 != radius)
			needUpdateVertex = true;
		_radius1 = radius;
	}
	else if (_lastSelectIndex == _CONTROL_POINT_WIND_)//�޸������ߵ�����,Ŀǰ���������ӿ��Բ���һ������ֵ
	{
		Vec3 point = _controlPoints[_CONTROL_POINT_WIND_]->getPosition3D();
		//����������İ뾶
		Vec3 direction = (point - centerPoint).getNormalized();
		float dotValue = Vec3::dot(direction,afterPoint);
		float newWind = _windCount + dotValue * afterPoint.length() * 0.0007f;
		//�ض�
		if (newWind < 1.0f)
			newWind = 1.0f;
		//ֻ�����Ҫ��ʱ��Ż���¶�������
		if(newWind != _windCount)
			needUpdateVertex = true;
		_windCount = newWind;
	}
	else if (_lastSelectIndex == _CONTROL_POINT_SPIRAL_)//�޸������ߵĵ���
	{
		Vec3 point = _controlPoints[_CONTROL_POINT_SPIRAL_]->getPosition3D();
		//������ת��
		Vec3 direction = (point - centerPoint).getNormalized();
		float dotValue = Vec3::dot(direction, afterPoint);
		float newHeight = _spiralHeight + dotValue * afterPoint.length() * 0.015f;
		if (newHeight < _ORIGIN_RADIUS_)
			newHeight = _ORIGIN_RADIUS_;
		if (newHeight != _spiralHeight)
			needUpdateVertex = true;
		_spiralHeight = newHeight;
	}
	updateVertexData(needUpdateVertex);
	_lastOffsetPoint = touchPoint;
}

void SpiralNode::onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{
	_lastSelectIndex = -1;
}

void SpiralNode::onMouseClick(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
{

}

void SpiralNode::onMouseMoved(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
{

}

void SpiralNode::onMouseReleased(const cocos2d::Vec2 &clickPoint, cocos2d::Camera *camera)
{

}

void SpiralNode::onCtrlKeyRelease()
{
	_lastSelectIndex = -1;
}
/*
  *���ݵĸ�ʽ����
  *cpoints[0](x,y,z)===>{��ת��(��λ��)}
  *cpoints[1](x,y,z)===>{��������}
  *cpoints[2](x,y,z)===>{�°뾶,�ϰ뾶,����(һ�������������ڵĸ߶�)}
  *cpoints[3](x,y,z)===>{����,���ߵķ���,0}
  */
void SpiralNode::getControlPoint(ControlPointSet &cpoints)
{
	//����
	cpoints.setType(CurveType::CurveType_Spiral);
	//����0
	cpoints.addNewPoint(_rotateAxis);
	//����1
	cpoints.addNewPoint(_controlPoints[_CONTROL_POINT_MOVE_]->getPosition3D());
	//����2
	cpoints.addNewPoint(Vec3(_radius0,_radius1,_spiralHeight));
	//����3
	cpoints.addNewPoint(Vec3(_windCount, _clockwise,0));
}
///////////////////////�������߶���////////////////////
void SpiralAction::initWithControlPoint(float duration,const cocos2d::Vec3 &rotateAxis, const cocos2d::Vec3 &centerPoint, float bottomRadius, float topRadius, float spiralHeight, float windCount,float clockwise)
{
	_rotateAxis = rotateAxis;
	_centerPoint = centerPoint;
	_bottomRadius = bottomRadius;
	_topRadius = topRadius;
	_spiralHeight = spiralHeight;
	_windCount = windCount;
	_clockwise = clockwise;
	updateRotateMatrix();
	cocos2d::ActionInterval::initWithDuration(duration);
}

void SpiralAction::initWithControlPoint(float duration,const std::vector<cocos2d::Vec3> &controlPoints)
{
	_rotateAxis = controlPoints[0];
	_centerPoint = controlPoints[1];
	auto &point = controlPoints[2];
	_bottomRadius = point.x;
	_topRadius = point.y;
	_spiralHeight = point.z;
	_windCount = controlPoints[3].x;
	_clockwise = controlPoints[3].y;
	updateRotateMatrix();
	cocos2d::ActionInterval::initWithDuration(duration);
}

void SpiralAction::updateRotateMatrix()
{
	const Vec3 upVec(0.0f,1.0f,0.0f);
	Vec3 axis;
	cocos2d::Mat4 translateM, rotateM;
	Vec3::cross(upVec,_rotateAxis,&axis);
	//////////////////////////////////////////
	Mat4::createTranslation(_centerPoint,&translateM);
	const float dotValue = Vec3::dot(_rotateAxis,upVec);
	float   angle = acosf(dotValue);
	Mat4::createRotation(axis, angle, &rotateM);
	_modelMatrix = translateM * rotateM;
}

SpiralAction *SpiralAction::create(float duration,const cocos2d::Vec3 &rotateAxis, const cocos2d::Vec3 &centerPoint, float bottomRadius, float topRadius, float spiralHeight, float windCount,float clockwise)
{
	SpiralAction * action = new SpiralAction();
	action->initWithControlPoint(duration,rotateAxis, centerPoint, bottomRadius, topRadius, spiralHeight, windCount,clockwise);
	return action;
}

SpiralAction *SpiralAction::create(float duration,const std::vector<cocos2d::Vec3> &controlPoints)
{
	SpiralAction *action = new SpiralAction();
	action->initWithControlPoint(duration,controlPoints);
	return action;
}
/*
  *ʵʱ����λ���Լ���ת����
 */
void SpiralAction::update(float rate)
{
	//λ��
	const float height = _spiralHeight *_windCount;
	const float halfHeight = height *0.5f;
	const float paix2 = 2.0f *M_PI * _clockwise;
	const float totalAngle = paix2 * _windCount;
	float  angle = rate * totalAngle;
	float  radius = _bottomRadius + (_topRadius - _bottomRadius)*angle / totalAngle;
	float  y = _spiralHeight * angle / paix2 - halfHeight;
	float  sinValue = sinf(angle);
	float  cosValue = cosf(angle);
	float  x = radius * sinValue;
	float  z = radius * cosValue;
	//�任����ϵ
	Vec4 newPoint = _modelMatrix * Vec4(x,y,z,1.0f);
	_target->setPosition3D(Vec3(newPoint.x,newPoint.y,newPoint.z));
	//��������
	const float c = paix2 * _windCount;
	const float dx = radius * cosValue * c;
	const float dy = _spiralHeight / paix2 * c;
	const float dz = -radius * sinValue * c;
	Vec3 tangent = _modelMatrix * Vec3(dx,dy,dz);


	float rotY = atan2f(-tangent.z, tangent.x);
	float rotZ = atanf(tangent.y / sqrtf(tangent.x * tangent.x + tangent.z * tangent.z));

	cocos2d::Quaternion quatY = cocos2d::Quaternion(Vec3(0, 1, 0), rotY);
	cocos2d::Quaternion quatZ = cocos2d::Quaternion(Vec3(0, 0, 1), rotZ);

	const cocos2d::Quaternion q = quatY * quatZ;
	_target->setRotationQuat(q);
}
