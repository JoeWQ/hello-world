/*
  *���������Ƶ㼯��ʵ��
  *2017-2-23
  *@Author:xiaoxiong
 */
#include "ControlPointSet.h"
#include "CurveNode.h"
//��ʽ������������
 void  _static_spiral_format(ControlPointSet *input,std::string &output);
//��ʽ����������������
 void  _static_bessel_format(ControlPointSet *input,std::string &output);
//������
typedef void (*FormatFunc)(ControlPointSet *,std::string &);
static std::map<CurveType, FormatFunc> _static_format_table = { 
			{ CurveType::CurveType_Bessel,_static_bessel_format},
			{ CurveType::CurveType_Spiral,_static_spiral_format},
		};
ControlPointSet::ControlPointSet(CurveType type):
_type(type)
{
	_realSize = 0;
	_pointsSet.reserve(6);
	_curveId = 0;
    weight = 0.5;
}

ControlPointSet::ControlPointSet(CurveType type, std::vector<CubicBezierRoute::PointInfo> &points):
_type(type)
{
	_pointsSet = points;
	_realSize = points.size();
}

ControlPointSet::ControlPointSet(CurveType type, std::vector<CubicBezierRoute::PointInfo> &points, int realSize):
_type(type)
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
//��ʽ�����,����Ľ��������һ��xml�м��ʽ
void       ControlPointSet::format(std::string &result)
{
	//���ҷ�����
	if (_static_format_table.find(_type) != _static_format_table.end())
	{
		FormatFunc func = _static_format_table[_type];
		func(this,result);
	}
}

int ControlPointSet::getProbablyCapacity()const
{
	return 60 + _realSize * 60;
}

void    ControlPointSet::addNewPoint(CubicBezierRoute::PointInfo &point)
{
	_realSize += 1;
	_pointsSet.push_back(point);
}

void    ControlPointSet::addNewPoint(cocos2d::Vec3 position, float speedCoef)
{
    _realSize += 1;
    
    CubicBezierRoute::PointInfo info;
    info.position = position;
    info.speedCoef = speedCoef;
    
    _pointsSet.push_back(info);
}

void    ControlPointSet::setId(int id)
{
	_curveId = id;
}

void ControlPointSet::setType(CurveType type)
{
	_type = type;
}
///////////////////////////static function//////////////////////
 void  _static_bessel_format(ControlPointSet *input, std::string &output)
{
	char   buffer[128];
	auto   &winSize = cocos2d::Director::getInstance()->getWinSize();
	const  float halfWidth = winSize.width / 2.0f;
	const  float halfHeight = winSize.height / 2.0f;
	//const  float   zPositive = winSize.height / 1.1566f;
	//Z����ܳ���
	//const float    nearPlane = 0.1f;
	//const float    farPlane = zPositive + winSize.height / 2.0f + 400;
	//const  float   zAxis = farPlane - nearPlane;
	//ͳһZƽ��
	output.clear();
	output.reserve(60 + input->_realSize * 60);
	sprintf(buffer, "	<Path id=\"%d\" Type=\"1\" Next=\"0\" Delay=\"0\" weight=\"%.2f\">", input->_curveId, input->weight);
	output.append(buffer);
	output.append("\n");
	for (int j = 0; j < input->_realSize; ++j)
	{
		CubicBezierRoute::PointInfo  &other = input->_pointsSet.at(j);
		output.append("		<Position ");
		//x,y,z���ŵ���Ļ�ռ�
		//x
		sprintf(buffer, "x=\"%.8f\"", other.position.x );
		output.append(buffer);
		//y
		sprintf(buffer, " y=\"%.8f\"", other.position.y );
		output.append(buffer);
		//ע�⣬������Ҫ��Z����任����������ϵ��
		sprintf(buffer, " z=\"%.8f\"", other.position.z );
		output.append(buffer);
        
        sprintf(buffer, " speedCoef=\"%.8f\"", other.speedCoef);
        output.append(buffer);

		sprintf(buffer," actionIndex=\"%d\"",other.aniIndex);
		output.append(buffer);

		sprintf(buffer," distance=\"%.1f\" />\n",other.aniDistance);
		output.append(buffer);
		//sprintf(buffer, " realZ=\"%.8f\" />\n", other.position.z);
		//output.append(buffer);
	}
	output.append("	</Path>\n");
}
//////////////////
void  _static_spiral_format(ControlPointSet *input, std::string &output)
{
	char buffer[128];
	auto &winSize = cocos2d::Director::getInstance()->getWinSize();
	output.clear();
	output.reserve(60 + input->_realSize * 60);
	sprintf(buffer, "	<Path id=\"%d\" Type=\"4\" Next=\"0\" Delay=\"0\" weight=\"%.2f\">", input->_curveId, input->weight);
	output.append(buffer);
	output.append("\n");
	////��������/////
	for (int i = 0; i < 4; ++i)
	{
		auto point = input->_pointsSet[i];
		//���������������Ҫ�任
		if (i == 1)
		{
			point.position.x += winSize.width *0.5f;
			point.position.y += winSize.height *0.5f;
		}
		sprintf(buffer,"		<Position x=\"%.8f\" y=\"%.8f\" z= \"%.8f\"/>\n", point.position.x, point.position.y, point.position.z);
		output.append(buffer);
	}
	output.append("	</Path>\n");
}
