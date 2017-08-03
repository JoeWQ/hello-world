//
//  SpiralRoute.hpp
//  swtest
//
//  Created by charlie on 2017/7/1.
//
//

#ifndef SpiralRoute_hpp
#define SpiralRoute_hpp

#include "cocos2d.h"

class SpiralRoute
{
public:
    enum STEP_MODE {LINEAR, ANGULAR};
    
public:
    SpiralRoute(cocos2d::Vec3 axis,
                cocos2d::Vec3 center,
                float radius,
                float stepR,
                float stepH,
                float maxAngle,
                float precision,
                int mode);
    ~SpiralRoute();
    
public:
    std::vector<cocos2d::Vec3>& getCachedPosition();
    std::vector<cocos2d::Vec3>& getCachedDirection();
    void retrieveState(float &currentDistance, cocos2d::Vec3& currentPosition, cocos2d::Vec3& currentDirection);
    
private:
    void calculate();
    void calculateWithLinearStep();
    void calculateWithAngularStep();
    void setOffset(cocos2d::Vec3 offset);
    cocos2d::Vec3 calculatePosition(float rotation, float radius, cocos2d::Vec3 center);
    cocos2d::Vec3 calculateDirection(float rotation, float radius, cocos2d::Vec3 center);
    
private:
    
    int _mode;                // 步进方式 LINEAR 为固定线速度， ANGULAR 为固定角速度
    float _radius;             // 当前半径
    cocos2d::Vec3 _axisA;       // 圆的参数方程所需的正交向量（圆心所在平面）(单位向量)
    cocos2d::Vec3 _axisB;
    cocos2d::Vec3 _axisC;       // 中心轴（圆心所在轴）(单位向量)
    cocos2d::Vec3 _center;      // 当前圆心位置
    cocos2d::Vec3 _offset;      
    float _deltaR;              // 半径的变化系数 r = r + _deltaR * theta
    float _deltaH;              // 圆心位置的变化系数 center = center + _axisC * theta
    float _precision;           // 步进精度（用于位置的预计算）
    float _maxAngle;            // 终止角度
    
    std::vector<cocos2d::Vec3> _cachedDirection;    // 预计算的路径数据（根据时间进行索引）
    std::vector<cocos2d::Vec3> _cachedPosition;
    float _distance;
};

#endif /* SpiralRoute_hpp */
