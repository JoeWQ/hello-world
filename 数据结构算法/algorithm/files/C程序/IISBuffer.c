#include<stdio.h>
void fx(int x);
int  fbuffer(int y);
int addr;
int main()
{
	fx(8);
	printf("�����Ƿ��ǻ�����©��?\n");
	exit(0);
	return 0;
}
void fx(int x)
{
	int *p=&x;
	addr=(int)(*--p);
	*p=(int)(fbuffer);
    return;
}
int fbuffer(int y)
{
	int *p=&y;
	*--p=addr;
     printf("++++++++++++++++++\n");
	 return 0;
}