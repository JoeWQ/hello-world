#include<stdio.h>
#include<windows.h>
int fabona(const int index);
int recurveFabona(int);
void test(int);
int main()
{
    test(10);
	test(20);
	test(30);
	test(40);
	test(50);
}
void test(int value)
{
	int time;
    int i=0;
	puts("**********************************************");
	printf("测试的索引值为%u时，函数调用所花费的时间\n",value);	
   	printf("非递归调用时间: ");
	time=GetTickCount();
	for(i=0;i<200000;++i)
       fabona(value);

	printf("%u \n",(GetTickCount()-time));
	//.........................................  
	printf("递归调用时间: ");
	time=GetTickCount();
	for(i=0;i<200000;++i)
        recurveFabona(value);
//	printf("函数值为: %u \n",recurveFabona(value));
    printf("%u \n",(GetTickCount()-time));
}
int fabona(const int index)
{
	int a,b,c;
	int i;
	for(i=0,a=1,b=1;i<index;++i)
	{
		c=a+b;
		a=b;
		b=c;
	}
	return c;
}
int recurve(int cycle,int a,int b)
{
   int c=a+b;
   if(--cycle>0)
   {
       return recurve(cycle,b,c);
   }
   return c;
}

int recurveFabona( int index)
{
	 return recurve(index,1,1);
}