//
//  BezierRoute.hpp
//  BoneTest
//
//  Created by charlie on 2017/3/10.
//
//

#ifndef BezierRoute_hpp
#define BezierRoute_hpp

#include "cocos2d.h"

class RouteProtocol {
    
public:
    RouteProtocol() {}
    virtual ~RouteProtocol() {}
    virtual void addPoints(std::vector<cocos2d::Vec3>& points) = 0;
    virtual cocos2d::Vec3 getDirection(float t) = 0;
    virtual cocos2d::Vec3 getLocation(float t) = 0;
    virtual cocos2d::Vec3 getCurrentDirection() = 0;
    virtual cocos2d::Vec3 getCurrentLocation() = 0;
    virtual void advanceTo(float t) = 0;
    virtual void advanceBy(float deltaDist) = 0;
    virtual void reset() = 0;
    virtual void clear() = 0;
    virtual void calculateDistance() = 0;
    virtual float getDistance() = 0;
    virtual bool isEnded() = 0;
    
};

class BezierRoute : public cocos2d::Node, public RouteProtocol
{
public:
    BezierRoute();
    virtual ~BezierRoute() {};
    
public:
    virtual void addPoints(std::vector<cocos2d::Vec3>& points) override;
    virtual cocos2d::Vec3 getDirection(float t) override;
    virtual cocos2d::Vec3 getLocation(float t) override;
    virtual cocos2d::Vec3 getCurrentDirection() override;
    virtual cocos2d::Vec3 getCurrentLocation() override;
    virtual void advanceTo(float t) override;
    virtual void advanceBy(float deltaDist) override;
    virtual bool isEnded() override;
    
protected:
    virtual void buildParameters() = 0;
    virtual cocos2d::Vec3 caculateTangent(float position) = 0;
    virtual cocos2d::Vec3 caculateValue(float position) = 0;
    virtual float getPositionByDeltaDistance(float deltaDistance) = 0;
    
protected:
    float _precision;
    float _position;
    cocos2d::Vec3 _valueCache;
    cocos2d::Vec3 _tangentCache;
    std::vector<cocos2d::Vec3> _points;
    bool _ended;
    unsigned int _distance;
};

class CubicBezierRoute : public BezierRoute
{
public:
    struct CaculatedParameter
    {
        cocos2d::Vec3 a;
        cocos2d::Vec3 b;
        cocos2d::Vec3 c;
        cocos2d::Vec3 d;
        cocos2d::Vec3 da;
        cocos2d::Vec3 db;
        cocos2d::Vec3 dc;
    };
    
public:
    CubicBezierRoute();
    virtual ~CubicBezierRoute() {};
    static CubicBezierRoute* create();

public:
    void setWeight(float weight);
    void setPrecision(float precision);
    void relativeAdvance(int index, float& tCurrent, float& deltaDistance, cocos2d::Vec3& currentPosition, cocos2d::Vec3& currentDirection);
    void retrieveState(cocos2d::Vec3& position, cocos2d::Vec3& direction, float& overflow, float distance);
    
    std::vector<CaculatedParameter>& getParameters();
    
public:
    virtual void reset() override;
    virtual void clear() override;
    virtual void calculateDistance() override;
    virtual float getDistance() override;
    
private:
    virtual void buildParameters() override;
    virtual cocos2d::Vec3 caculateTangent(float position) override;
    virtual cocos2d::Vec3 caculateValue(float position) override;
    virtual float getPositionByDeltaDistance(float deltaDistance) override;
    
private:
    std::vector<cocos2d::Vec3> _controlPoints;
    std::vector<CaculatedParameter> _caculatedParameters;
    std::vector<cocos2d::Vec3> _cachedPosition;
    std::vector<cocos2d::Vec3> _cachedDirection;
    int _currentStartIndex;
    float _weight;
};

#endif /* BezierRoute_hpp */
