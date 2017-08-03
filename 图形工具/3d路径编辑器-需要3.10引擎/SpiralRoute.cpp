//
//  SpiralRoute.cpp
//  swtest
//
//  Created by charlie on 2017/7/1.
//
//

#include "SpiralRoute.hpp"

using namespace cocos2d;

SpiralRoute::SpiralRoute(cocos2d::Vec3 axis,
            cocos2d::Vec3 center,
            float radius,
            float stepR,
            float stepH,
            float maxAngle,
            float precision,
            int mode)
{
    _axisC = axis;
    _radius = radius;
    _deltaR = stepR;
    _deltaH = stepH;
    _maxAngle = maxAngle;
    _mode = mode;
    _distance = 0;
    _precision = precision;
    _offset = Vec3(0, 0, 0);
    
    // 计算参数方程所需的三个坐标轴，计算时圆心位置位于世界坐标系的原点
    
    if(_axisC.x == 0 && _axisC.z == 0) // 如果c轴垂直于y轴，特殊处理
    {
        _axisA = Vec3(0, 0, 1);
        _axisB = Vec3(1, 0, 0);
    }
    else
    {
        float axisLength = sqrtf(_axisC.x * _axisC.x + _axisC.z * _axisC.z);    // a轴为圆与xoz平面的交线
        _axisA = Vec3(-_axisC.z / axisLength, 0, _axisC.x / axisLength);
        
        Vec3::cross(_axisC, _axisA, &_axisB);   // b轴通过a轴与c轴叉乘得出
        _axisB.normalize();
    }
    
    calculate();    // 预计算路径点数据
}

SpiralRoute::~SpiralRoute()
{
    
}

void SpiralRoute::calculate()
{
    if(_mode == STEP_MODE::LINEAR) // 以固定线速前进的方式进行计算
    {
        calculateWithLinearStep();
    }
    else if(_mode == STEP_MODE::ANGULAR)  // 以固定角速前进的方式进行计算
    {
        calculateWithAngularStep();
    }
}

void SpiralRoute::calculateWithLinearStep()
{
    float currentRotation = 0;
    float currentRadius = _radius;
    Vec3 currentCenter = _center;
    Vec3 currentPosition = calculatePosition(currentRotation, currentRadius, currentCenter);
    Vec3 currentDirection = calculateDirection(currentRotation, currentRadius, currentCenter);
    
    _cachedPosition.push_back(currentPosition);
    _cachedDirection.push_back(currentDirection);
    _offset = currentPosition;
    
    do
    {
        Vec3 prevVec = currentPosition - _center;                   // 计算当前位置与圆心之间的线段
        Vec3 nextVec = prevVec + currentDirection * _precision;     // 按照_precision定义的步长以及当前的切线方向计算下一位置与圆心之间的线段
        
        Vec3 prevProj = prevVec - _axisC * _axisC.dot(prevVec);     // 为了引入圆心的变化率这里需要计算线段在圆心所在平面的投影
        prevProj.normalize();
        
        Vec3 nextProj = nextVec - _axisC * _axisC.dot(nextVec);
        nextProj.normalize();
        
        float rotationDelta = acosf(prevProj.dot(nextProj));        // 计算两个投影线段之间的夹角作为参数方程中角度的变化
        currentRotation += rotationDelta;                           // 计算下一状态
        currentRadius += rotationDelta * _deltaR;
        currentCenter += rotationDelta * _axisC * _deltaH;
        currentPosition = calculatePosition(currentRotation, currentRadius, currentCenter);
        currentDirection = calculateDirection(currentRotation, currentRadius, currentCenter);
        
        _cachedPosition.push_back(currentPosition - _offset);
        _cachedDirection.push_back(currentDirection);
        
        _distance = _distance + _precision;
    }
    while(currentRotation < _maxAngle);
}

void SpiralRoute::calculateWithAngularStep()
{
    float currentRotation = 0;
    float currentRadius = _radius;
    Vec3 currentCenter = _center;
    Vec3 currentPosition = calculatePosition(currentRotation, currentRadius, currentCenter);
    Vec3 currentDirection = calculateDirection(currentRotation, currentRadius, currentCenter);
    
    _cachedPosition.push_back(currentPosition);
    _cachedDirection.push_back(currentDirection);
    _offset = currentPosition;
    
    do
    {
        float rotationDelta = _precision;
        currentRotation += rotationDelta;
        currentRadius += rotationDelta * _deltaR;
        currentCenter += rotationDelta * _axisC * _deltaH;
        currentPosition = calculatePosition(currentRotation, currentRadius, currentCenter);
        currentDirection = calculateDirection(currentRotation, currentRadius, currentCenter);
        
        _cachedPosition.push_back(currentPosition - _offset);
        _cachedDirection.push_back(currentDirection);
        
        _distance = _distance + _precision;
    }
    while(currentRotation < _maxAngle);
}

std::vector<cocos2d::Vec3>& SpiralRoute::getCachedPosition()
{
    return _cachedPosition;
}

std::vector<cocos2d::Vec3>& SpiralRoute::getCachedDirection()
{
    return _cachedDirection;
}

// 获取路径点数据（数据包括：currentPosition 当前位置， currentDirection 当前的切线方向）
// 当步进模式为固定角速度时，currentDistance 代表当前转过的角度
// 当步进模式为固定线速度时，currentDistance 代表当前走过的距离

void SpiralRoute::retrieveState(float &currentDistance, cocos2d::Vec3& currentPosition, cocos2d::Vec3& currentDirection)
{
    if(currentDistance < _distance)
    {
        float fIndex = currentDistance / _precision;
        int prevIndex = floor(fIndex);
        int nextIndex = ceil(fIndex);
        int t = (currentDistance - currentDistance * prevIndex) / _precision;
        
        currentPosition = _cachedPosition[prevIndex] * (1 - t) + _cachedPosition[nextIndex] * t + _offset;
        currentDirection = _cachedDirection[prevIndex] * (1 - t) + _cachedDirection[nextIndex] * t;
        
        currentDistance = 0;
    }
    else
    {
        int index = _distance / _precision;
        
        currentPosition = _cachedPosition[index] + _offset;
        currentDirection = _cachedDirection[index];
        
        currentDistance = currentDistance - _distance;
    }
}


cocos2d::Vec3 SpiralRoute::calculatePosition(float rotation, float radius, cocos2d::Vec3 center)
{
    return center + radius * (cos(rotation) * _axisA + sin(rotation) * _axisB); // 使用三维空间圆的参数方程计算位置
}

cocos2d::Vec3 SpiralRoute::calculateDirection(float rotation, float radius, cocos2d::Vec3 center)
{
    Vec3 ret =
    
    _axisC * _deltaH                                                // 使用三维空间圆的参数方程的导数计算当前切线方向
    + _deltaR * (_axisA * cos(rotation) + _axisB * sin(rotation))
    + radius * (_axisB * cos(rotation) - _axisA * sin(rotation));
    
    ret.normalize();
    
    return ret;
}
