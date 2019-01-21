#include<stdio.h>
void fx(int x);
void printMessage();
unsigned int addr=0;
int main()
{
    int p=(int)fx;
	int *pp=&addr;
	printf("函数fx的地址是：%x\n",p);
    printf("全局变量addr的地址是: %x\n",pp);
	//printf("在这里从错去的路径返回!\n");
	return 0;
}
void fx(int x)
{

}
void printMessage()
{
/*	__asm push addr*/
//	printf("这是一个缓冲区溢出的例子!\n");
	return;
}