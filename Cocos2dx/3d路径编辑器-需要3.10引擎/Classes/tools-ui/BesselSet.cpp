/*
  *贝塞尔控制点集合实现
  *2017-2-23
  *@Author:xiaoxiong
 */
#include "BesselSet.h"

BesselSet::BesselSet()
{
	_realSize = 0;
	_pointsSet.reserve(6);
	_curveId = 0;
}

BesselSet::BesselSet(std::vector<cocos2d::Vec3> &points)
{
	_pointsSet = points;
	_realSize = points.size();
}

BesselSet::BesselSet(std::vector<cocos2d::Vec3> &points, int realSize)
{
	if (realSize > _pointsSet.capacity())
		_pointsSet.reserve(realSize);
	assert(realSize<=points.size());
	for (int j = 0; j < realSize; ++j)
	{
		_pointsSet[j] = points.at(j);
	}
	_realSize = realSize;
}
//格式化输出,输出的结果会生成一个xml中间格式
void       BesselSet::format(std::string &result)
{
	char   buffer[128];
	auto   &winSize = cocos2d::Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	const  float   zPositive = winSize.height / 1.1566f;
	//Z轴的总长度
	const float    nearPlane = 0.1f;
	const float    farPlane = zPositive +winSize.height / 2.0f + 400;
	const  float   zAxis = farPlane - nearPlane;
	//统一Z平面
	result.clear();
	result.reserve(60+ _realSize * 60);
	sprintf(buffer, "	<Path id=\"%d\" Type=\"1\" Next=\"0\" Delay=\"0\">",_curveId);
	result.append(buffer);
	result.append("\n");
	for (int j = 0; j < _realSize; ++j)
	{
		const  cocos2d::Vec3  &other = _pointsSet.at(j);
		result.append("		<Position ");
		//x,y,z缩放到屏幕空间
		//x
			sprintf(buffer, "x=\"%.8f\"", other.x/ halfWidth*0.5f+0.5f);
			result.append(buffer);
		//y
			sprintf(buffer," y=\"%.8f\"",other.y/halfHeight*0.5f+0.5f);
			result.append(buffer);
		//注意，这里需要将Z坐标变换到左手坐标系中
			sprintf(buffer," z=\"%.8f\"",(-other.z + zPositive -  nearPlane)/zAxis);
			result.append(buffer);

			sprintf(buffer," realZ=\"%.8f\" />\n",other.z);
			result.append(buffer);
	}
	result.append("	</Path>\n");
}

int BesselSet::getProbablyCapacity()const
{
	return 60 + _realSize * 60;
}

void    BesselSet::addNewPoint(cocos2d::Vec3 &point)
{
	_realSize += 1;
	_pointsSet.push_back(point);
}

void    BesselSet::setId(int id)
{
	_curveId = id;
}