#include<stdio.h>
//#include "jni.h"
struct _jobject;
typedef struct _jobject *jobject;
int main(int count,char **p)
{
	int i=0;
	printf("The size of jobject is : %d \n",sizeof(jobject));
	return 0;
}