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
	MessageBox(NULL,TEXT("��ʼѧϰwindows������ƣ�"),TEXT("��Ϣ�Ի���"),MB_OK);
	return 0;
}