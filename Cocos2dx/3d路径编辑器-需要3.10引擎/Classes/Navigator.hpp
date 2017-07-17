//
//  Navigator.hpp
//  BoneTest
//
//  Created by charlie on 2017/3/10.
//
//

#ifndef Navigator_hpp
#define Navigator_hpp

#include "cocos2d.h"
#include "BezierRoute.hpp"

class Navigator : public cocos2d::Node
{
public:
    static Navigator* create();
    virtual bool init();
    virtual void onEnter();
    virtual void onExit();

public:
    void start();
    void stop();
    void reset();
    void update(float dt);
    
private:
    void startScheduler();
    void stopScheduler();
    
private:
    BezierRoute* _route;
    float _parentOriginalScale;
};

#endif /* Navigator_hpp */
