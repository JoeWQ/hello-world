#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "SpriteCycle.h"
class HelloWorld : public cocos2d::Layer
{
public:
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* createScene();
	~HelloWorld();

    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();
    
    // a selector callback
    void menuCloseCallback(cocos2d::Ref* pSender);
    
    // implement the "static create()" method manually
    CREATE_FUNC(HelloWorld);

	void update(float time);
	cocos2d::CCProgressTimer    *m_pt;
	SpriteCycle             *_CycleSprite;
	int                             _nowDigit;
	bool          HelloWorld::onTouchBegan(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	void          HelloWorld::onTouchMoved(cocos2d::Touch *touch, cocos2d::Event *unused_event);
	void          HelloWorld::onTouchEnded(cocos2d::Touch *touch, cocos2d::Event *unused_event);
};

#endif // __HELLOWORLD_SCENE_H__
