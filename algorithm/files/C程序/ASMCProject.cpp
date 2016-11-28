#include<stdio.h>
#include "MyASM.h"
int main()
{
    int pp[10]={0,8,9,7,6,5,4,3,2,1};
	showArray(pp,10);
	putchar('\n');
	WriteMesg();
	return 0;
}