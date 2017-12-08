#include<stdio.h>
#include "jni.h"
class _JavaHeader{};
int main(int count,char **p)
{
	int i=0;
	printf("The size of jobject is : %d \n",sizeof(jobject));
	printf("The size of _jclass is %d \n", sizeof(_jclass));
	printf("Java Header 'size is : %d \n",sizeof(_JavaHeader));
	return 0;
}