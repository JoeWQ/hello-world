/*
  *���������������㷨,���2d����,
  *�㷨ʹ�ñ��������ߵ���ѧ�����������ߵ���ɢ�ĵ�
  *date:2017��12��24��
  *@author:xiaoxiong
 */
#ifndef __FISH_PATH_H__
#define __FISH_PATH_H__
#include "cocos2d.h"
class FishPath
{
	//���ߵ���ɢ�ĵ�,�����ֵ
	std::vector<cocos2d::Vec2>  _dispersePosition;
	std::vector<cocos2d::Vec4>  _disperseDirection;//����,�������ٶ�����ϵ��,
	float                                             _curveDistance;//���ߵĳ���
private:
	/*
	*�������ߵĳ���,�˺���ֻ�ᱻ����һ��
	*/
	void		calculate(const std::vector<cocos2d::Vec2> &controlPoints);
public:
	FishPath(float distance);
	/*
	  *ʹ����ɢ�Ŀ��Ƶ����ɱ���������
	  *sw:�ͻ�����Ļ�����������Ļ��ȵı���
	  *sh:�ͻ�����Ļ�߶���������Ļ�߶ȵı���
	 */
	void    initWithControlPoint(const std::vector<cocos2d::Vec2>  &controlPoints,float sw,float sh);
	/*
	  *��ȡ���ߵĳ���
	 */
	float    getCurveDistance()const { return _curveDistance; };
	/*
	  *������ǰ�ı���[0-1]��ȡ�����ߵ���صĲ�ֵ���Լ���صķ���
	  *�ٶȵ�����ϵ��
	  *�����������ֵ
	 */
	void     extract(float distance,cocos2d::Vec2 &position,cocos2d::Vec4 &dspeeddxdy);
};
#endif