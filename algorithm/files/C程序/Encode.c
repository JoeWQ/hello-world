#include<stdio.h>
int main()
{
	char *c="С���ܣ�������";
	char *p=c;
	int i;
	for(i=0;*p!='\0';++p)
		printf("% d ",*p);
	putchar('\n');
	return 0;
}
