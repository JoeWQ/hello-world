/*
  *���̰�������
  *2017-5-26 09:59:51
  *@Author:xiaohuaxiong
 */
#ifndef __KEY_CODE_H__
#define __KEY_CODE_H__
#include "engine/GLState.h"
__NS_GLK_BEGIN
//���̰���������,Ŀǰ֧�ֵ����Ͳ���ȫ��
enum KeyCodeType
{
	KeyCode_NONE = 0,//��Ч�İ���
	KeyCode_W = 1,//W
	KeyCode_S = 2, //S
	KeyCode_A = 3,//A
	KeyCode_D = 4,//D
	KeyCode_CTRL = 5,//Ctrl
	KeyCode_SHIFT = 6,//Shift
	KeyCode_SPACE = 7,//�ո��
};
//���̰�����״̬ 
enum KeyCodeState
{
	KeyCodeState_None=0,//��Ч�İ���״̬
	KeyCodeState_Pressed=1,//���̰�������
	KeyCodeState_Released=2,//���̰������ͷ�
};
__NS_GLK_END
#endif