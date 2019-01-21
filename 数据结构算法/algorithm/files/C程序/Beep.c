#include<stdio.h>
#include<stdlib.h>
#define sleep _sleep
int main()
{
	int i=0;
	for(i=0;i<16;++i)
	{
		putchar(0x7);
		sleep(1800);
	}
	return 0;
}