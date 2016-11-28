#include<stdio.h>
int main()
{
	int i=11;
	int j=89;
	int *p=&i;
	unsigned int max=0;
	int a[10]={0};
	int *pp=a;
	printf("数组的地址为  %u \n",a);
	printf("经过指针赋值后的值为 :  %u \n",&pp);
	printf("变量i的地址为 :  %u  \n",p);
	--p;
	printf("是否是变量j的地址 ? &j= %u,  p= %u \n",&j,p);
	p+=3;
	printf("超越内存访问权限的访问是否被允许？ i=%d,j=%d,*p=%d, \n",i,j,*p);
    max=~max;
	printf("32未内存的上线为 : %u \n ",max);
	return 0;
}