#include<stdio.h>
#include<windows.h>
#pragma comment(lib,"User32.lib")
int WINAPI WinBegin();
int main()
{
	printf("+++++++++++++++++++\n");
	WinBegin();
	return 0;
}
int WINAPI WinBegin()
{
	MessageBox(NULL,TEXT("开始学习windows程序设计！"),TEXT("消息对话框"),MB_OK);
	return 0;
}