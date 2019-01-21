//
//  Navigator.cpp
//  BoneTest
//
//  Created by charlie on 2017/3/10.
//
//

#include "Navigator.hpp"
#include "GlobalValue.hpp"
#include "tools-ui/DrawNode3D.h"

using namespace cocos2d;

Navigator* Navigator::create()
{
    Navigator* pRet = new Navigator();
    pRet->init();
    pRet->autorelease();
    return pRet;
}

bool Navigator::init()
{
    Node::init();
    
    _route = CubicBezierRoute::create();
    _route->retain();
    
    std::vector<Vec3> points = {
        
        Vec3(-50, 150, -340),
        Vec3(300, 250, 200),
        Vec3(700, 900, -350),
        Vec3(1000, 300, 200),
        Vec3(1300, 400, 50),
        Vec3(1500, 100, 100),
        
    };
//    _route->addPoints(points);
    ((CubicBezierRoute*)_route)->setWeight(1.5);
    
    return true;
}

void Navigator::onEnter()
{
    Node::onEnter();
}

void Navigator::onExit()
{
    Node::onExit();
}

void Navigator::start()
{
    Navigator::reset();
    _parentOriginalScale = _parent->getScale();
    startScheduler();
}

void Navigator::stop()
{
    stopScheduler();
}

void Navigator::reset()
{
    _route->reset();
    getParent()->setPosition3D(_route->getCurrentLocation());
}

void Navigator::startScheduler()
{
    this->getScheduler()->schedule(schedule_selector(Navigator::update), this, 0.016, CC_REPEAT_FOREVER, 0, false);
}

void Navigator::stopScheduler()
{
    this->getScheduler()->unschedule(schedule_selector(Navigator::update), this);
}

void Navigator::update(float dt)
{
    _route->advanceBy(4);
    
    Vec3 direction = _route->getCurrentDirection();
    Vec3 face = Vec3(1, 0, 0);
    
    float rotY = atan2f(direction.x, direction.z);
    float rotZ = atanf(direction.y / sqrtf(direction.x * direction.x + direction.z * direction.z));
    
    Quaternion quatY = Quaternion(Vec3(0, 1, 0), rotY - M_PI / 2);
    Quaternion quatZ = Quaternion(Vec3(0, 0, 1), rotZ);
    
    _parent->setRotationQuat(quatY * quatZ);
    _parent->setPosition3D(_route->getCurrentLocation());
}
