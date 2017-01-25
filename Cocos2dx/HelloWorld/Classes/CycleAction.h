//环形精灵滚动动作
//2017-1-22 19:31:29
//@Author:小花熊
#ifndef __CYCLE_ACTION_H__
#define __CYCLE_ACTION_H__
#include "SpriteCycle.h"
class CycleAction :public cocos2d::ActionInterval
{
protected:
	//初始角度
	float _originAngle;
	//需要额外旋转的角度
	float _totalAngle;
public:
	//经过duration时间,旋转的角度
	static CycleAction *create(float duration, float angle);
	//从当前的角度,经过time时间转动N圈到指定的数字,如果当前的数字比转动后的数字要大,则视为一圈
	//比如,现在的数字是7,要滚动到最近的1,则这个被认为是一圈
	static CycleAction *createWithCycle(SpriteCycle *target,float duration, int _NCycle, int targetNum);
	virtual void startWithTarget(cocos2d::Node *target)override;
	virtual  void update(float deltaTime)override;
private:
	//初始化,将会计算成统一的数据
	void     initWithCycle(SpriteCycle *target,float duration,int _NCycle,int targetNum);
	void     initWithAngle(float duration,float angle);
};
#endif