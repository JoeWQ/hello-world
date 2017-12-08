#include<stdio.h>
int main()
{
	char *pp="Ð¡»¨ÐÜ£¬ÐÜÐÜ123";
	char *p=pp;
	int i=0;
	for(i=0;*p!='\0';++p)
		printf("%d  ",*p);
	return 0;
}