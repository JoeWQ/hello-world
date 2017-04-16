/*
  *�й����͵Ķ���
  *@date:2017-4-15
  @Author:xiaohuaxiong
 */
#ifndef __TYPES_H__
#define __TYPES_H__
#include<engine/Object.h>
#include<engine/Geometry.h>
//�ص��������Ͷ���,���ڻص�����
typedef void (glk::Object::*GLKUpdateCallback)(const float );
//������ʼ
typedef bool (glk::Object::*GLKTouchCallback)(const glk::GLVector2 *);
//�ƶ�
typedef void (glk::Object::*GLKTouchMotionCallback)(const glk::GLVector2 *);
//����
typedef void (glk::Object::*GLKTouchReleaseCallback)(const glk::GLVector2 *);

#define  glk_touch_selector(selector)     static_cast<GLKTouchCallback >(&selector)
#define  glk_move_selector(selector)     static_cast<GLKTouchMotionCallback >(&selector)
#define  glk_release_selector(selector)  static_cast<GLKTouchReleaseCallback >(&selector)
#endif