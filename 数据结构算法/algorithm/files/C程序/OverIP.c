#include<stdio.h>
void fx(int x);
void printMessage();
unsigned int addr=0;
int main()
{
    int p=(int)fx;
	int *pp=&addr;
	printf("����fx�ĵ�ַ�ǣ�%x\n",p);
    printf("ȫ�ֱ���addr�ĵ�ַ��: %x\n",pp);
	//printf("������Ӵ�ȥ��·������!\n");
	return 0;
}
void fx(int x)
{

}
void printMessage()
{
/*	__asm push addr*/
//	printf("����һ�����������������!\n");
	return;
}