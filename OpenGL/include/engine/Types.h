/*
  *有关类型的定义
  *@date:2017-4-15
  @Author:xiaohuaxiong
 */
#ifndef __TYPES_H__
#define __TYPES_H__
#include "engine/Object.h"
#include "engine/Geometry.h"
#include "engine/event/KeyCode.h"
//回调函数类型定义,周期回调函数
typedef void (glk::Object::*GLKUpdateCallback)(const float );
//触屏起始
typedef bool (glk::Object::*GLKTouchCallback)(const glk::GLVector2 *);
//移动
typedef void (glk::Object::*GLKTouchMotionCallback)(const glk::GLVector2 *);
//结束
typedef void (glk::Object::*GLKTouchReleaseCallback)(const glk::GLVector2 *);

////////////////键盘按键事件回调函数////////////////
typedef bool (glk::Object::*GLKKeyPressCallback)(const glk::KeyCodeType keyCode);
typedef void (glk::Object::*GLKKeyReleaseCallback)(const glk::KeyCodeType keyCode);

#define  glk_touch_selector(selector)     static_cast<GLKTouchCallback >(&selector)
#define  glk_move_selector(selector)     static_cast<GLKTouchMotionCallback >(&selector)
#define  glk_release_selector(selector)  static_cast<GLKTouchReleaseCallback >(&selector)

//定义简化使用键盘回调函数的宏
#define glk_key_press_selector(selector) static_cast<GLKKeyPressCallback>(&selector)
#define glk_key_release_selector(selector) static_cast<GLKKeyReleaseCallback>(&selector)
#endif