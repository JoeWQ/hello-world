#include<stdio.h>
void fx(int x);
void printMessage();
unsigned int addr=0;
int main()
{
	fx(6);
	printf("������Ӵ�ȥ��·������!\n");
	return 0;
}
void fx(int x)
{
	void (*p)();
	int *pp=&x;	
	p=printMessage;
	--pp;
	addr=(unsigned int)(*pp);
	*pp=(int *)p;
}
void printMessage()
{
/*	__asm push addr*/
	printf("����һ�����������������!\n");
	return;
}