//
//  BezierRoute.cpp
//  BoneTest
//
//  Created by charlie on 2017/3/10.
//
//

#include "BezierRoute.hpp"

using namespace cocos2d;

BezierRoute::BezierRoute() :
_points(std::vector<PointInfo>()),
_position(0),
_valueCache(Vec3(0, 0, 0)),
_tangentCache(Vec3(0, 0, 0)),
_precision(1.0),
_ended(false),
_distance(0)
{}

void BezierRoute::addPoints(std::vector<PointInfo>& points)
{
    clear();
    _points.insert(_points.end(), points.begin(), points.end());
    buildParameters();
}

cocos2d::Vec3 BezierRoute::getDirection(float t)
{
    return caculateValue(t);
}

cocos2d::Vec3 BezierRoute::getLocation(float t)
{
    return caculateTangent(t);
}

cocos2d::Vec3 BezierRoute::getCurrentDirection()
{
    return _tangentCache;
}

cocos2d::Vec3 BezierRoute::getCurrentLocation()
{
    return _valueCache;
}

void BezierRoute::advanceTo(float t)
{
    t = t < 0 ? 0 : t;
    t = t > 1 ? 1 : t;
    
    _position = t;
    
    _valueCache = caculateValue(_position);
    _tangentCache = caculateTangent(_position);
}

void BezierRoute::advanceBy(float deltaDist)
{
    advanceTo(getPositionByDeltaDistance(deltaDist));
}


bool BezierRoute::isEnded()
{
    return _ended;
}

CubicBezierRoute::CubicBezierRoute() :
BezierRoute(),
_controlPoints(std::vector<cocos2d::Vec3>()),
_caculatedParameters(std::vector<CaculatedParameter>()),
_currentStartIndex(1),
_weight(0.5)
{
    
}

CubicBezierRoute* CubicBezierRoute::create()
{
    CubicBezierRoute* pRet = new CubicBezierRoute();
    pRet->init();
    pRet->autorelease();
    return pRet;
}

void CubicBezierRoute::setWeight(float weight)
{
    _weight = weight;
}

std::vector<CubicBezierRoute::CaculatedParameter>& CubicBezierRoute::getParameters()
{
    return _caculatedParameters;
}

void CubicBezierRoute::buildParameters()
{
    size_t pointNumber = _points.size();
    
    if(pointNumber == 0)
    {
        return;
    }
    
    for(size_t i = 0; i < pointNumber; i++)
    {
        size_t index_back = (pointNumber + i - 1) % pointNumber;
        size_t index_forward = (i + 1) % pointNumber;
        Vec3 mid_back = (_points[index_back].position + _points[i].position) / 2;
        Vec3 mid_forward = (_points[index_forward].position + _points[i].position) / 2;
        float dist_back = _points[index_back].position.distance(_points[i].position);
        float dist_forward = _points[index_forward].position.distance(_points[i].position);
        Vec3 control_point_back = (mid_back - mid_forward) * dist_back * _weight / (dist_back + dist_forward) + _points[i].position;
        Vec3 control_point_forward = (mid_forward - mid_back) * dist_forward * _weight / (dist_back + dist_forward) + _points[i].position;
        
        _controlPoints.push_back(control_point_back);
        _controlPoints.push_back(control_point_forward);
    }
    
    for(size_t i = 0; i < pointNumber; i ++)
    {
        Vec3& p0 = _points[i].position;
        Vec3& p1 = _controlPoints[(i * 2 + 1) % (pointNumber * 2)];
        Vec3& p2 = _controlPoints[(i * 2 + 2) % (pointNumber * 2)];
        Vec3& p3 = _points[(i + 1) % pointNumber].position;
        
        CaculatedParameter param;
        
        param.a = -1 * p0 + 3 * p1 - 3 * p2 + p3;
        param.b =  3 * p0 - 6 * p1 + 3 * p2;
        param.c = -3 * p0 + 3 * p1;
        param.d =      p0;
        
        param.da = -3 * p0 +  9 * p1 - 9 * p2 + 3 * p3;
        param.db =  6 * p0 - 12 * p1 + 6 * p2;
        param.dc = -3 * p0 +  3 * p1;
        
        _caculatedParameters.push_back(param);
    }
    
    _points[0].segmentDistance = 0;
    _points[pointNumber - 1].segmentDistance = 0;
    
    if(pointNumber < 4)
    {
        _distance = 0;
        _cachedPosition.push_back(getCurrentLocation());
        _cachedDirection.push_back(getCurrentDirection());
        
        for(int i = 1; i < pointNumber - 1; i++)
        {
            _points[i].segmentDistance = 0;
        }
        
        return;
    }
    else
    {
        int index = 1;
        float t = 0;
        CaculatedParameter p = _caculatedParameters[index];
        Vec3 position = t * t * t * p.a + t * t * p.b + t * p.c + p.d;
        Vec3 direction = t * t * p.da + t * p.db + p.dc;
        _distance = 0;
        _points[index].segmentDistance = _distance;
        _cachedPosition.push_back(position);
        _cachedDirection.push_back(direction);
		_controlPointIndex.push_back(index);
        do
        {
            float base = direction.length();
            t = t + 1 / base;
            _distance++;
            
            if(t > 1)
            {
                index++;
                _points[index].segmentDistance = _distance;
                t = 0;
                p = _caculatedParameters[index];
            }
            
            position = t * t * t * p.a + t * t * p.b + t * p.c + p.d;
            direction = t * t * p.da + t * p.db + p.dc;
            
            _cachedPosition.push_back(position);
            _cachedDirection.push_back(direction);
			_controlPointIndex.push_back(index);
        }
        while(index < pointNumber - 2);
    }
    
    for(int i = 0; i < pointNumber; i++)
    {
        printf("%d\n", _points[i].segmentDistance);
    }
    
    if(pointNumber < 4)
    {
        _cachedSpeedCoef.push_back(_points[0].speedCoef);
    }
    else
    {
        int index = 2;
        int distance = 0;
        _cachedSpeedCoef.push_back(_points[0].speedCoef);
        
        do
        {
            distance = distance + 1;
            
            if(distance >= _points[index].segmentDistance)
            {
                _cachedSpeedCoef.push_back(_points[index].speedCoef);
                index++;
            }
            else
            {
                float prevCoef = _points[index - 1].speedCoef;
                float nextCoef = _points[index].speedCoef;
                float prevDistance = _points[index - 1].segmentDistance;
                float nextDistance = _points[index].segmentDistance;
                float offsetDistance = distance - prevDistance;
                float t = offsetDistance / (nextDistance - prevDistance);
                
                _cachedSpeedCoef.push_back(prevCoef * (1 - t) + nextCoef * t);
            }
        }
        while(index < pointNumber - 1);
    }
    
    return;
}

cocos2d::Vec3 CubicBezierRoute::caculateTangent(float position)
{
    if(_points.size() > 3)
    {
        CaculatedParameter& param = _caculatedParameters[_currentStartIndex];
        
        return _position * _position * param.da + _position * param.db + param.dc;
    }
    else
    {
        return Vec3(0, 0, 0);
    }
}

cocos2d::Vec3 CubicBezierRoute::caculateValue(float position)
{
    if(_points.size() > 3)
    {
        CaculatedParameter& param = _caculatedParameters[_currentStartIndex];
        
        return _position * _position * _position * param.a + _position * _position * param.b + _position * param.c + param.d;
    }
    else
    {
        return Vec3(0, 0, 0);
    }
}

float CubicBezierRoute::getPositionByDeltaDistance(float deltaDistance)
{
    if(_points.size() < 4)
    {
        _ended = true;
        return 0;
    }
    
    float newPosition = _position;
    
    while ((!_ended) && deltaDistance > 0) {
        
        float delta = deltaDistance < _precision ? deltaDistance : _precision;
        float length = getCurrentDirection().length();
        length = length > 0 ? length : 0.0001f;
        
        newPosition = newPosition + delta / length;
        
        if(newPosition >= 1)
        {
            newPosition = 0;
            _currentStartIndex = _currentStartIndex + 1;
        }
        
        deltaDistance = deltaDistance - delta;
        
        if(_currentStartIndex == _points.size() - 2)
        {
            _ended = true;
        }
    }
    
    return newPosition;
}

void CubicBezierRoute::reset()
{
    _position = 0;
    _currentStartIndex = 1;
    _valueCache = caculateValue(_position);
    _tangentCache = caculateValue(_position);
    _ended = false;
}

void CubicBezierRoute::clear()
{
    _points.clear();
    _controlPoints.clear();
    _caculatedParameters.clear();
    _cachedPosition.clear();
    _cachedSpeedCoef.clear();
    _cachedDirection.clear();
    _controlPointIndex.clear();
    _distance = 0;
    
    reset();
}

void CubicBezierRoute::calculateDistance()
{
//    float counter = 0;
//    
//    if(_points.size() < 4)
//    {
//        _distance = 0;
//        _cachedPosition.push_back(getCurrentLocation());
//        _cachedDirection.push_back(getCurrentDirection());
//        return;
//    }
//    
//    advanceBy(0);
//    _cachedPosition.push_back(getCurrentLocation());
//    _cachedDirection.push_back(getCurrentDirection());
//    
//    do
//    {
//        advanceBy(_precision);
//        _cachedPosition.push_back(getCurrentLocation());
//        _cachedDirection.push_back(getCurrentDirection());
//        counter++;
//    }
//    while(!_ended);
//        
//    _distance = counter * _precision;
}

float CubicBezierRoute::getDistance()
{
    return _distance;
}

void CubicBezierRoute::relativeAdvance(int index, float& t, float& deltaDistance, Vec3& currentPosition, Vec3& currentDirection)
{
    CaculatedParameter& p = _caculatedParameters[index];
    currentDirection = (t * t) * p.da + (t) * p.db + p.dc;
    
    while(t < 1 && deltaDistance > 0)
    {
        float tPrevious = t;
        float pace = deltaDistance < _precision ? deltaDistance : _precision;
        float length = currentDirection.length();
        
        length = length > 0 ? length : 0.0001f;
        
        t = tPrevious + pace / length;
        
        if(t >= 1)
        {
            t = 1.0;
            pace = (1.0 - tPrevious) * length;
        }
        
        deltaDistance = deltaDistance - pace;
        currentDirection = (t * t) * p.da + (t) * p.db + p.dc;
    }
    
    currentPosition = (t * t * t) * p.a + (t * t) * p.b + (t) * p.c + p.d;
}

void CubicBezierRoute::retrieveState(cocos2d::Vec3& position, cocos2d::Vec3& direction, float& speedCoef, float& overflow, float distance)
{
    if(distance == 0)
    {
        position = _cachedPosition[0];
        direction = _cachedDirection[0];
        speedCoef = _cachedSpeedCoef[0];
        overflow = 0;
    }
    else if(distance > _distance)
    {
        position = _cachedPosition[_distance];
        direction = _cachedDirection[_distance];
        speedCoef = _cachedSpeedCoef[_distance];
        overflow = distance - _distance;
    }
    else
    {
        int index = distance;
        position = _cachedPosition[index];
        direction = _cachedDirection[index];
        speedCoef = _cachedSpeedCoef[index];
        overflow = 0;
    }
}
