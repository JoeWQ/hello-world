/*
  *键盘按键编码
  *2017-5-26 09:59:51
  *@Author:xiaohuaxiong
 */
#ifndef __KEY_CODE_H__
#define __KEY_CODE_H__
#include "engine/GLState.h"
__NS_GLK_BEGIN
//键盘按键的类型,目前支持的类型并不全面
enum KeyCodeType
{
	KeyCode_NONE = 0,//无效的按键
	KeyCode_W = 1,//W
	KeyCode_S = 2, //S
	KeyCode_A = 3,//A
	KeyCode_D = 4,//D
	KeyCode_CTRL = 5,//Ctrl
	KeyCode_SHIFT = 6,//Shift
	KeyCode_SPACE = 7,//空格键
};
//键盘按键的状态 
enum KeyCodeState
{
	KeyCodeState_None=0,//无效的按键状态
	KeyCodeState_Pressed=1,//键盘按键按下
	KeyCodeState_Released=2,//键盘按键被释放
};
__NS_GLK_END
#endif