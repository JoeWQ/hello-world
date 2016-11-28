#include<stdio.h>
int main()
{
	char *c="小花熊，花花熊";
	char *p=c;
	int i;
	for(i=0;*p!='\0';++p)
		printf("% d ",*p);
	putchar('\n');
	return 0;
}
