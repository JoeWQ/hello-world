#include<stdio.h>
void move(int ,char ,char);
void hanoi(int ,char ,char ,char);
int index=0;
int main()
{
	hanoi(2,'A','B','C');
	return 0;
}
void move(int n,char x,char y)
{
	printf("%dst move %c ---> %c \n",++index,x,y);
}
void hanoi(int n,char x,char y,char z)
{
	if(n==1)
		move(1,x,z);
	else
	{
		hanoi(n-1,x,z,y);
		move(n,x,z);
		hanoi(n-1,y,x,z);
	}
}