//环形精灵旋转动作
//2017-1-22 20:09:35
//@Author:xiaohuaxiong
#include "CycleAction.h"
//注意使用者最好不要直接使用这个函数,而是用下面的静态封装函数
//因为angle参数是不能随意设置的,除非使用者了解SpriteCycle是如何具体运作的
CycleAction *CycleAction::create( float duration, float angle)
{
	CycleAction *action = new CycleAction();
	action->initWithAngle(duration,angle);
	action->autorelease();
	return action;
}

CycleAction *CycleAction::createWithCycle(SpriteCycle *target,float duration, int _NCycle, int targetNum)
{
	CycleAction *action = new CycleAction();
	action->initWithCycle(target,duration, _NCycle, targetNum);
	action->autorelease();
	return action;
}
void CycleAction::initWithAngle(float duration, float angle)
{
	ActionInterval::initWithDuration(duration);
	_totalAngle = angle;
}

void CycleAction::initWithCycle(SpriteCycle *target,float duration, int _NCycle, int targetNum)
{
	ActionInterval::initWithDuration(duration);
	//计算初始角度和需要旋转的角度
	_originAngle = target->getOriginAngle();
	const int nowDigit = target->getOriginDigit();
	_totalAngle = (targetNum - nowDigit) * 360 / 10 + _NCycle * 360;
}

void CycleAction::startWithTarget(cocos2d::Node *target)
{
	SpriteCycle *_Cycle = dynamic_cast<SpriteCycle *>(target);
	ActionInterval::startWithTarget(target);
	_originAngle = _Cycle->getOriginAngle();
}

void CycleAction::update(float rate)
{
	SpriteCycle *_Cycle = (SpriteCycle *)_target;
	//计算三次插值,插值之后计算出来的值会使得动作出现缓动的行为
	//如果感觉效果不理想,也可以使用5次插值 6*t^5 - 15*t^4 + 10*t ^4
	const float time_rate = rate;
	const float interprolation = 3.0f * time_rate *time_rate - 2.0f*time_rate*time_rate*time_rate;
	_Cycle->setAngle(_originAngle + _totalAngle*interprolation);
}