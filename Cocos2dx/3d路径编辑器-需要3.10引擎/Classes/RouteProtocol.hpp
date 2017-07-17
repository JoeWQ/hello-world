//
//  RouteProtocol.hpp
//  BoneTest
//
//  Created by charlie on 2017/3/16.
//
//

#ifndef RouteProtocol_hpp
#define RouteProtocol_hpp

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

#endif /* RouteProtocol_hpp */
