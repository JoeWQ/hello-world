#include<stdio.h>
int main()
{
	char *pp="С���ܣ�����123";
	char *p=pp;
	int i=0;
	for(i=0;*p!='\0';++p)
		printf("%d  ",*p);
	return 0;
}