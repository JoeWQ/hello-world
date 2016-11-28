#include<stdio.h>
void fx(int x);
void printMessage();
unsigned int addr=0;
int main()
{
	fx(6);
	printf("在这里从错去的路径返回!\n");
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
	printf("这是一个缓冲区溢出的例子!\n");
	return;
}