#include<stdio.h>
int main()
{
	int i=11;
	int j=89;
	int *p=&i;
	unsigned int max=0;
	int a[10]={0};
	int *pp=a;
	printf("����ĵ�ַΪ  %u \n",a);
	printf("����ָ�븳ֵ���ֵΪ :  %u \n",&pp);
	printf("����i�ĵ�ַΪ :  %u  \n",p);
	--p;
	printf("�Ƿ��Ǳ���j�ĵ�ַ ? &j= %u,  p= %u \n",&j,p);
	p+=3;
	printf("��Խ�ڴ����Ȩ�޵ķ����Ƿ����� i=%d,j=%d,*p=%d, \n",i,j,*p);
    max=~max;
	printf("32δ�ڴ������Ϊ : %u \n ",max);
	return 0;
}