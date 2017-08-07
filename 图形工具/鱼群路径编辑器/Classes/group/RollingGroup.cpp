/*
  *RollingGroup.cpp
  *@2017-8-4
  *@Author:xiaohuaxiong
 */
#include "RollingGroup.h"
#include "common/Common.h"
USING_NS_CC;
//关于绕X轴旋转的椭圆时候分隔圆周的最小/最大次数
#define    _MIN_H_WIND_COUNT_   3
#define    _MAX_H_WIND_COUNT_  24
//关于环绕椭圆的圆环序列的最大/最小次数
#define   _MIN_V_WIND_COUNT_    2
#define   _MAX_V_WIND_COUNT_   16
//纵向圆的最小半径
const float MinRadius = 100.0f;
RollingRoute::RollingRoute() :GroupRoute(GroupType::GroupType_Rolling)
,_tangent(1.0f,0,0)
,_location(0,0,0)
,_xoyVertex(nullptr)
,_xoyVertexSize(0)
,_yozVertex(nullptr)
,_yozVertexSize(0)
,_windHCount(_MIN_H_WIND_COUNT_)
,_windVCount(_MIN_V_WIND_COUNT_)
, _glProgram(nullptr)
,_color(1.0f,0.9f,0.8f,1.0f)
, _lastSelectedIndex(-1)
{

}

RollingRoute::~RollingRoute()
{
	delete[] _xoyVertex;
	delete[] _yozVertex;

	_xoyVertex = nullptr;
	_yozVertex = nullptr;

	_glProgram->release();
}

RollingRoute *RollingRoute::create()
{
	RollingRoute *route = new RollingRoute();
	route->initWithLayer();
	route->autorelease();
	return route;
}

bool RollingRoute::initWithLayer()
{
	GroupRoute::init();
	auto &winSize = Director::getInstance()->getWinSize();
	_abEquation = Vec2(winSize.width/4.0f,winSize.height/4.0f);
	//直线
	_originLocation = Vec3(-winSize.width/2.0f,0.0f,0.0f);
	_finalLocation = Vec3(winSize.width/2.0f,0.0f,0.0f);
	updateVertex(true);
	//Shader
	_glProgram = GLProgram::createWithByteArrays(_static_common_model_vertex_shader, _static_common_model_frag_shader);
	_glProgram->retain();

	_positionLoc = _glProgram->getAttribLocation("a_position");
	_colorLoc = _glProgram->getUniformLocation("g_Color");
	_modelMatrixLoc = _glProgram->getUniformLocation("g_ModelMatrix");
	return true;
}

static Sprite3D *_static_genSprite3D(const FishInfo &fishInfo)
{
	std::string imageName = "3d/"+fishInfo.name+"/"+fishInfo.name+".c3b";
	Sprite3D *sprite=Sprite3D::create(imageName);
	sprite->setScale(fishInfo.scale);
	sprite->setPosition3D(Vec3::ZERO);
	sprite->setRotation3D(Vec3::ZERO);
	sprite->setTag(fishInfo.fishId);
	//Animation
	Animation3D *animation = Animation3D::create(imageName);
	Animate3D *animate = Animate3D::create(animation,fishInfo.startFrame/30.0f,(fishInfo.endFrame-fishInfo.startFrame)/30.0f);
	sprite->runAction(RepeatForever::create(animate));
	return sprite;
}

void RollingRoute::updateVertex(bool needCheck)
{
	if (needCheck)
	{
		delete _xoyVertex;
		delete _yozVertex;
		/*
		 *只计算出两条曲线的顶点数据,其他的使用矩阵变换计算出来
		 *并且,这两条分别是XOY平面的椭圆,YOZ平面的圆
		 */
		 //计算椭圆的长度
		float L = 2.0f * M_PI * _abEquation.y + 4.0f*(_abEquation.x - _abEquation.y);
		//
		const float pixelStep = 4.0f;//每4像素一个步长
		_xoyVertexSize = ceil(L / pixelStep);
		_xoyVertex = new cocos2d::Vec3[_xoyVertexSize];
		float  C = _abEquation.y *_abEquation.y / (_abEquation.x*_abEquation.x);
		for (int i = 0; i < _xoyVertexSize; ++i)
		{
			float angle = 2.0f *M_PI *i / (_xoyVertexSize - 1);
			float sinValue = sinf(angle);
			float cosValue = cosf(angle);
			float  s2 = sinValue * sinValue;
			float  c2 = cosValue * cosValue;

			float    b = sqrtf(C*c2 + s2);
			_xoyVertex[i].x = _abEquation.y*cosValue / b;
			_xoyVertex[i].y = _abEquation.y *sinValue / b;
			_xoyVertex[i].z = 0.0f;
		}
		//计算最长的圆周的顶点数据
		float    LC = 2.0f * M_PI * _abEquation.y;
		_yozVertexSize = ceil(LC / pixelStep);
		_yozVertex = new cocos2d::Vec3[_yozVertexSize];
		for (int i = 0; i < _yozVertexSize; ++i)
		{
			float angle = 2.0f *M_PI * i / (_yozVertexSize - 1);
			_yozVertex[i].x = 0.0f;
			_yozVertex[i].y = _abEquation.y * sinf(angle);
			_yozVertex[i].z = _abEquation.y * cosf(angle);
		}
	}
	//计算横向变换矩阵
	_modelHMatrixVector.clear();
	for (int i = 0; i < _windHCount; ++i)
	{
		float angle = -2.0f * M_PI * i/ _windHCount;
		//只计算旋转矩阵就可以了
		Mat4 rm,tm;
		Mat4::createRotationX(angle,&rm);
		Mat4::createTranslation(_location,&tm);
		_modelHMatrixVector.push_back(tm*rm);
	}
	//计算纵向变换矩阵
	_modelVMatrixVector.clear();
	_cycleEquations.clear();
	for (int i = 0; i < _windVCount; ++i)
	{
		//缩放,半径
		float x = (1.0+i)/(_windVCount+1) * 2*_abEquation.x - _abEquation.x;
		float c = x / _abEquation.x;
		float r = _abEquation.y * sqrtf(1.0 - c*c);
		float scale = r / _abEquation.y;
		//缩放
		Mat4 scaleMatrix,tm;
		Mat4::createScale(Vec3(scale,scale,scale),&scaleMatrix);
		//平移
		Mat4::createTranslation(Vec3(x, 0, 0) + _location,&tm);
		_modelVMatrixVector.push_back(tm * scaleMatrix);
		CycleEquation  equation;
		equation.centerPoint = Vec3(x,0,0) + _location;
		equation.radius = r;
		_cycleEquations.push_back(equation);
	}
	//直线
	_lineVertex[0] = _originLocation;
	_lineVertex[1] = _finalLocation;
	_modelLineMatrix.setIdentity();
	Mat4::createTranslation(_location, &_modelLineMatrix);
	//求所有空间圆与椭圆的交点,注意,交点的数目是椭圆曲线分量的2倍
	_intersectPointMap.clear();
	//_cycleEquations.size()>1
	for (int i = 0; i < _cycleEquations.size(); ++i)
	{
		//计算旋转矩阵
		//求出最基本的交点,就是圆周的Y轴的最顶点
		Vec3 basicPoint(0.0f,_cycleEquations[i].radius,0.0f);
		std::vector<Vec3>   points;
		points.reserve(_windHCount<<1);
		points.push_back(basicPoint + _cycleEquations[i].centerPoint);
		for (int j = 1; j < _windHCount<<1; ++j)
		{
			Mat4   rotateX;
			Mat4::createRotationX(-2 * j * M_PI / (_windHCount*2.0f), &rotateX);
			Vec3 newPoint = rotateX * basicPoint + _cycleEquations[i].centerPoint;
			points.push_back(newPoint);
		}
		_intersectPointMap[i] = points;
	}
	//清理所有的鱼模型
	std::map<int, std::vector<Sprite3D*>>::iterator itModel = _intersectSprite3DMap.begin();
	for (; itModel != _intersectSprite3DMap.end(); ++itModel)
	{
		std::vector<Sprite3D*> &modelSprites = itModel->second;
		//先清理
		for (std::vector<Sprite3D*>::iterator it = modelSprites.begin(); it != modelSprites.end(); ++ it)
		{
			if (*it)
			{
				(*it)->removeFromParent();
			}
		}
	}
	_intersectSprite3DMap.clear();
	//创建空模型
	for (int i = 0; i < _cycleEquations.size(); ++i)
	{
		//求出最基本的交点,就是圆周的Y轴的最顶点
		std::vector<Sprite3D*>  modelSprites;
		modelSprites.reserve(_windHCount<<1);
		for (int j = 0; j < _windHCount<<1; ++j)
		{
			modelSprites.push_back(nullptr);
		}
		_intersectSprite3DMap[i] = modelSprites;
	}
	//清除原来的交叉点精灵
	for (std::map<int, std::vector<Sprite*>>::iterator it = _intersectSpriteMap.begin(); it != _intersectSpriteMap.end(); ++it)
	{
		std::vector<Sprite*>  &intersectSprite = it->second;
		for (std::vector<Sprite*>::iterator ott = intersectSprite.begin(); ott != intersectSprite.end(); ++ott)
			(*ott)->removeFromParent();
	}
	_intersectSpriteMap.clear();
	//创建交叉点精灵
	for (int i = 0; i <_cycleEquations.size(); ++i)
	{
		//原来的交点
		std::vector<Vec3> &intersectPoint = _intersectPointMap[i];
		std::vector<Sprite*>  intersectSprite;
		intersectSprite.reserve(_windHCount<<1);
		for (int j = 0; j < _windHCount << 1; ++j)
		{
			Sprite *sprite = Sprite::create("tools-ui/layer-ui/radio_button_on.png");
			sprite->setCameraMask((short)CameraFlag::USER1);
			sprite->setPosition3D(intersectPoint[j]);
			this->addChild(sprite, 2);
			intersectSprite.push_back(sprite);
		}
		_intersectSpriteMap[i] = intersectSprite;
	}
	/////清理以前的控制点
	for (std::vector<ControlPoint *>::iterator it = _cycleControlPoints.begin(); it != _cycleControlPoints.end(); ++it)
	{
		(*it)->removeFromParent();
	}
	_cycleControlPoints.clear();
	_cycleControlPoints.reserve(_cycleEquations.size());
	for (int j = 0; j < _cycleEquations.size(); ++j)
	{
		ControlPoint *pointSprite = ControlPoint::createControlPoint(j+1);
		pointSprite->setPosition3D(_cycleEquations[j].centerPoint);
		pointSprite->setCameraMask((short)CameraFlag::USER1);
		this->addChild(pointSprite,j+1);
		_cycleControlPoints.push_back(pointSprite);
	}
	//最后一个是中心坐标点
	ControlPoint *centerPoint = ControlPoint::createControlPoint(0);
	centerPoint->setPosition3D(_location);
	centerPoint->setCameraMask((short)CameraFlag::USER1);
	this->addChild(centerPoint);
	_cycleControlPoints.push_back(centerPoint);
}
//更新已经存在的矩阵的数据
void RollingRoute::updateTranformMatrix(const cocos2d::Vec3 &offsetVec3)
{
		//计算横向变换矩阵
		for (int i = 0; i < _windHCount; ++i)
		{
			float angle = -2.0f * M_PI * i / _windHCount;
			//只计算旋转矩阵就可以了
			Mat4 rm,tm;
			Mat4::createRotationX(angle, &rm);
			Mat4::createTranslation(_location, &tm);
			_modelHMatrixVector[i]=tm * rm;
		}
		//计算纵向变换矩阵
		for (int i = 0; i < _windVCount; ++i)
		{
			//缩放,半径
			float r = _cycleEquations[i].radius;
			float scale = r / _abEquation.y;
			//缩放
			Mat4 scaleMatrix,tm;
			Mat4::createScale(Vec3(scale, scale, scale), &scaleMatrix);
			//平移
			Mat4::createTranslation(_cycleEquations[i].centerPoint+ offsetVec3,&tm); //scaleMatrix.translate(_cycleEquations[i].centerPoint + offsetVec3);
			_modelVMatrixVector[i]=tm * scaleMatrix;
			CycleEquation  equation;
			equation.centerPoint = _cycleEquations[i].centerPoint + offsetVec3;
			equation.radius = r;
			_cycleEquations[i]=equation;
		}
		//直线
		_lineVertex[0] = _originLocation;
		_lineVertex[1] = _finalLocation;
		_modelLineMatrix.setIdentity();
		Mat4::createTranslation(_location, &_modelLineMatrix);
		//求所有空间圆与椭圆的交点
		for (int i = 0; i < _cycleEquations.size(); ++i)
		{
			//求出最基本的交点,就是圆周的Y轴的最顶点
			Vec3 basicPoint(0.0f, _cycleEquations[i].radius, 0.0f);
			std::vector<Vec3> &intersectPoints = _intersectPointMap[i];
			std::vector<Sprite3D*> &intersectSprite3D = _intersectSprite3DMap[i];//更新模型
			std::vector<Sprite*> &intersectSprite = _intersectSpriteMap[i];
			intersectPoints[0]=basicPoint + _cycleEquations[i].centerPoint;
			if (intersectSprite3D[0])
				intersectSprite3D[0]->setPosition3D(intersectPoints[0]);
			intersectSprite[0]->setPosition3D(intersectPoints[0]);
			for (int j = 1; j < _windHCount<<1; ++j)
			{
				Mat4   rotateX;
				Mat4::createRotationX(-2 * j * M_PI / (_windHCount*2.0f), &rotateX);
				Vec3 newPoint = rotateX * basicPoint + _cycleEquations[i].centerPoint;
				intersectPoints[j]=newPoint;
				if (intersectSprite3D[j])
				{
					intersectSprite3D[j]->setPosition3D(intersectPoints[j]);
				}
				intersectSprite[j]->setPosition3D(intersectPoints[j]);
			}
		}
		for (int j = 0; j < _cycleEquations.size(); ++j)
		{
			_cycleControlPoints[j]->setPosition3D(_cycleEquations[j].centerPoint);
		}
		//中心坐标点
		_cycleControlPoints[_cycleControlPoints.size()-1]->setPosition3D(_location);
}

void RollingRoute::updateSomeCycle(int selectIndex,cocos2d::Vec3 &offsetVec3)
{
	//纵向圆的中心坐标点
	Vec3 position = _cycleControlPoints[selectIndex]->getPosition3D();
	Vec3 afterPosition = position + Vec3(offsetVec3.x,0,0);//只能沿着X轴
	//关于该圆的方程式,以及半径
	float  x = afterPosition.x - _location.x;
	//计算
	float c = x / _abEquation.x;
	float r = _abEquation.y * sqrtf(1.0 - c*c);
	//r的最小半径不能小于MinRadius
	if (r <= MinRadius)
	{
		//此时,需要修正坐标
		float t = MinRadius*MinRadius / (_abEquation.y*_abEquation.y);
		x = _signfloat(x) * _abEquation.x*sqrtf(1.0f  - t);
		r = MinRadius;
	}
	afterPosition.x = x+_location.x;
	//修正其方程式
	float scale = r / _abEquation.y;
	//缩放
	Mat4 scaleMatrix,translateMatrix;
	Mat4::createScale(Vec3(scale, scale, scale), &scaleMatrix);
	//平移
	Mat4::createTranslation(afterPosition, &translateMatrix);// .translate(afterPosition);
	_modelVMatrixVector[selectIndex] = translateMatrix * scaleMatrix;
	CycleEquation  equation;
	equation.centerPoint = afterPosition;
	equation.radius = r;
	_cycleEquations[selectIndex] = equation;
	//控制点的坐标
	_cycleControlPoints[selectIndex]->setPosition3D(afterPosition);
	//与横向交点的坐标
	//求出最基本的交点,就是圆周的Y轴的最顶点
	Vec3 basicPoint(0.0f, _cycleEquations[selectIndex].radius, 0.0f);
	std::vector<Vec3> &intersectPoints = _intersectPointMap[selectIndex];
	intersectPoints[0]=basicPoint + _cycleEquations[selectIndex].centerPoint;
	for (int j = 1; j < _windHCount<<1; ++j)
	{
		Mat4   rotateX;
		Mat4::createRotationX(-2 * j * M_PI / (_windHCount*2.0f), &rotateX);
		Vec3 newPoint = rotateX * basicPoint + _cycleEquations[selectIndex].centerPoint;
		intersectPoints[j]=newPoint;
	}
	//更新Sprite3D/Sprite的坐标
	std::vector<Sprite3D*>  &intersectSprite3Ds = _intersectSprite3DMap[selectIndex];
	std::vector<Sprite*>       &intersectSprite = _intersectSpriteMap[selectIndex];
	for (int j = 0; j < _windHCount<<1; ++j)
	{
		if(intersectSprite3Ds[j])
			intersectSprite3Ds[j]->setPosition3D(intersectPoints[j]);
		intersectSprite[j]->setPosition3D(intersectPoints[j]);
	}
}

bool   RollingRoute::onTouchBegan(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{
	//计算选中的坐标点
	_lastOffsetVec2 = touchPoint;
	//检测是否某一个贝塞尔曲线控制点被选中了
	const cocos2d::Size  &pointSize = _cycleControlPoints.at(0)->getContentSize();
	const float  halfWidth = pointSize.width / 2.0f;
	const float  halfHeight = pointSize.height / 2.0f;
	_lastSelectedIndex = -1;
	float        _lastZorder = 0.0f;
	for (int j = 0; j < _cycleControlPoints.size(); ++j)
	{
		ControlPoint    *other = _cycleControlPoints.at(j);
		Vec3     nowPoint = _rotateMatrix * other->getPosition3D();
		Vec3     glPosition;
		//转换到OpenGL世界坐标系
		this->project2d(camera, nowPoint, glPosition);

		if (touchPoint.x >= glPosition.x - halfWidth && touchPoint.x <= glPosition.x + halfWidth
			&& touchPoint.y >= glPosition.y - halfHeight && touchPoint.y <= glPosition.y + halfHeight)
		{
			//选择的条件
			if (_lastSelectedIndex >= 0)//Zorder更大
			{
				if (glPosition.z < _lastZorder ||
					(glPosition.z == _lastZorder && other->getLocalZOrder() > _cycleControlPoints.at(_lastSelectedIndex)->getLocalZOrder())
					)//或者Zorder更大
				{
					_lastSelectedIndex = j;
					_lastZorder = glPosition.z;
				}
			}
			else
			{
				_lastSelectedIndex = j;
				_lastZorder = glPosition.z;
			}
		}
	}
	return true;
}

void RollingRoute::onTouchMoved(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{
	Vec2 offsetPoint =( touchPoint - _lastOffsetVec2)*0.5f;
	//计算其3d常规坐标系之下的平移向量
	Vec3	projectCoord = _rotateMatrix.getInversed() * Vec3(offsetPoint.x,offsetPoint.y,0);
	  //判断,是否需要操纵某一个控制点
	if (_lastSelectedIndex != -1)
	{
		bool   needCheck = false;
		//如果不是最后一个向量,此时平移整个对象的中心
		if (_lastSelectedIndex != _cycleControlPoints.size() - 1)
		{
			updateSomeCycle(_lastSelectedIndex, projectCoord);
		}
		else
		{
			_location += projectCoord;
			updateTranformMatrix(projectCoord);
		}
	}
	_lastOffsetVec2 = touchPoint;
}

void RollingRoute::onTouchEnded(const cocos2d::Vec2 &touchPoint, cocos2d::Camera *camera)
{

}

void RollingRoute::onMouseClick(const cocos2d::Vec2 &clickPoint,cocos2d::Camera *camera)
{
	//转换为NDC
	auto &winSize = Director::getInstance()->getWinSize();
	float ndcx = clickPoint.x / winSize.width * 2.0f;
	float ndcy = clickPoint.y / winSize.height * 2.0f;
	//还原摄像机空间中的点的坐标到世界空间
	Vec4  worldPosition;
	Mat4 mvpMatrix = camera->getViewProjectionMatrix();//注意,节点本身还有一个旋转矩阵
	Mat4 inverseMatrix = mvpMatrix.getInversed();
	inverseMatrix.transformVector(Vec4(ndcx, ndcy, 1.0f, 1.0f), &worldPosition);
	Vec3   worldPoint(worldPosition.x / worldPosition.w, worldPosition.y / worldPosition.w, worldPosition.z / worldPosition.w);
	//
	Vec3 cameraPosition = camera->getPosition3D();
	//求取射线
	Vec3 ray = (worldPoint - cameraPosition).getNormalized();
	//计算是否和点坐标交叉
	_intersectCycleIndex = -1;
	float        minDistance = 0x7FFFFFFF;
	std::map<int, std::vector<Vec3>>::iterator it = _intersectPointMap.begin();
	for (; it != _intersectPointMap.end(); ++it)
	{
		const std::vector<Vec3> &intersectPoint = it->second;
		//遍历所有的交叉点
		std::vector<Vec3>::const_iterator lit = intersectPoint.begin();
		int   index = 0;
		for (; lit != intersectPoint.cend(); ++lit,++index)
		{
			Vec3    point = _rotateMatrix * *lit;
			//检测point是否在直线上
			Vec3     unitVec = point - cameraPosition;
			float D = unitVec.length();
			Vec3    normal = unitVec.getNormalized();
			float     cosValue = Vec3::dot(normal, ray);
			//如果平行,则一定在直线上
			int        S = -1;
			float d = D * sqrtf(1.0 - cosValue * cosValue);
			//检测d的取值范围,如果很小,则可以认为在这条直线上
			if (d < 12)//方圆6像素之内
			{
				if (_intersectCycleIndex != -1)//如果已经有某一点满足上述条件,比较最短距离
				{
					if (d < minDistance)
					{
						minDistance = d;
						_intersectCycleIndex = (it->first << 8) | index;
					}
				}
				else
					_intersectCycleIndex = (it->first<<8)|index;
			}
		}
	}
	if (_intersectCycleIndex != -1)//如果有目标点,调用上层的函数
	{
		//检测相关位置是否有Sprite3D对象
		std::vector<Sprite3D*>  &intersectSprite3Ds = _intersectSprite3DMap[_intersectCycleIndex>>8];
		Sprite3D *targetSprite = intersectSprite3Ds[_intersectCycleIndex & 0xFF];
		if (targetSprite)
		{
			targetSprite->removeFromParent();
			intersectSprite3Ds[_intersectCycleIndex & 0xFF] = nullptr;
		}
		else
		{
			//click position转换成上层的UI坐标
			Vec2   xy = convertUICoord(clickPoint);
			_chooseDialogUICallback(_groupType, 0, Vec3(xy.x, xy.y, 0), CC_CALLBACK_1(RollingRoute::onChooseDialogConfirmCallback, this));
		}
	}
}

void RollingRoute::onChooseDialogConfirmCallback(const FishInfo &fishInfo)
{
	if (_intersectCycleIndex != -1)
	{
		std::vector<Sprite3D*>  &intersectSprites = _intersectSprite3DMap[_intersectCycleIndex>>8];
		Sprite3D *targetSprite = intersectSprites[_intersectCycleIndex & 0xFF];
		assert(! targetSprite);
		targetSprite = _static_genSprite3D(fishInfo);
		//设置坐标
		std::vector<Vec3>   &intersectPoints = _intersectPointMap[_intersectCycleIndex >>8];
		targetSprite->setPosition3D(intersectPoints[_intersectCycleIndex & 0xFF]);
		targetSprite->setCameraMask((short)CameraFlag::USER1);
		this->addChild(targetSprite);
		intersectSprites[_intersectCycleIndex & 0xFF] = targetSprite;
		_intersectCycleIndex = -1;
	}
}

void RollingRoute::draw(cocos2d::Renderer *renderer, const cocos2d::Mat4& transform, uint32_t flags)
{
	_drawGroupCommand.init(_globalZOrder);
	_drawGroupCommand.func = CC_CALLBACK_0(RollingRoute::drawGroup,this,transform,flags);
	renderer->addCommand(&_drawGroupCommand);
}

void RollingRoute::drawGroup(const cocos2d::Mat4 &transform, uint32_t flags)
{
	GL::bindVAO(0);
	//获取原始缓冲区对象
	int defaultVertexId;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING,&defaultVertexId);
	if (defaultVertexId != 0)
		glBindBuffer(GL_ARRAY_BUFFER,0);
	//横向曲线
	_glProgram->use();
	_glProgram->setUniformsForBuiltins(transform);
	//椭圆数据
	glEnableVertexAttribArray(_positionLoc);
	glVertexAttribPointer(_positionLoc,3,GL_FLOAT,GL_FALSE,0,_xoyVertex);

	glUniform4fv(_colorLoc,1,&_color.x);
	glLineWidth(1.0f);
	//计算旋转矩阵
	for (int i = 0; i < _windHCount; ++i)
	{
		glUniformMatrix4fv(_modelMatrixLoc, 1, GL_FALSE, _modelHMatrixVector[i].m);
		glDrawArrays(GL_LINE_STRIP, 0, _xoyVertexSize);
	}
	//纵向曲线
	glEnableVertexAttribArray(_positionLoc);
	glVertexAttribPointer(_positionLoc,3,GL_FLOAT,GL_FALSE,0,_yozVertex);

	for (int i = 0; i < _windVCount; ++i)
	{
		glUniformMatrix4fv(_modelMatrixLoc,1,GL_FALSE,_modelVMatrixVector[i].m);
		glDrawArrays(GL_LINE_STRIP, 0, _yozVertexSize);
	}
	//画出最后的直线
	glEnableVertexAttribArray(_positionLoc);
	glVertexAttribPointer(_positionLoc,3,GL_FLOAT,GL_FALSE,0,_lineVertex);
	glUniformMatrix4fv(_modelMatrixLoc,1,GL_FALSE,_modelLineMatrix.m);
	glDrawArrays(GL_LINES, 0, 2);

	if (defaultVertexId != 0)
		glBindBuffer(GL_ARRAY_BUFFER,defaultVertexId);
}

void RollingRoute::getGroupData(GroupData &output)
{

}

Layer *RollingRoute::getControlLayer()
{
	return _controlLayer;
}
/////////////////////////////////////LayerRolling////////////////////////////////
LayerRolling::LayerRolling(RollingRoute *rollingGroup) :
	_scrollViewEllipse(nullptr)
	,_scrollViewCycle(nullptr)
	,_hideSpreadButton(nullptr)
	,_rollingRouteGroup(rollingGroup)
{

}

LayerRolling *LayerRolling::create(RollingRoute *rollingGroup)
{
	LayerRolling *layer = new LayerRolling(rollingGroup);
	layer->init();
	layer->autorelease();
	return layer;
}

bool LayerRolling::init()
{
	Layer::init();
	//ScrollView
	_scrollViewEllipse = ui::ScrollView::create();
}