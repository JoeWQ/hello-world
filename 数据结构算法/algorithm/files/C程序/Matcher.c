#include<stdio.h>
#include<stdlib.h>
#define  TYPE_MATCH      1
#define  TYPE_NOT_MATCH  0
typedef struct _typematch
{
	int num;
	int matches;
}typematch;

int match(char *,typematch *,typematch *,typematch *);
int strlengthof(char *);
int main()
{
	char p[128];
	int i=0;
	//num1为圆括号的数目，num2为方括号的数目,num3为大括号的数目
	typematch num1,num2,num3;
	int hasChanged=0;
	char c;
	puts("请输入一个括号表达式!");
loops:
	while((c=getchar())!='\n')
	{
		p[i]=c;
		++i;
		if(i==128)
		{
			puts("您输入的字符不能超过128个 ,请重新输入!");
			i=0;
			goto loops;
		}
	}
	if(match(p,&num1,&num2,&num3))
	{
		if(num1.num || num2.num ||num3.num)
		{
	    	puts("您输入的括号表达式完全匹配!其中:");
	    	printf("圆括号的数目为: %d 对\n",num1);
	    	printf("方括号的数目为: %d 对\n",num2);
	    	printf("大括号的数目为: %d 对\n",num3);
		}else
		{
			puts("您输入的表达式中没有任何括号!");
		}
	}else
	{
		puts("您输入的括号表达式不能能完全匹配!其中的错误在于: ");
		if(!num1.matches)
		{
			printf("圆括号不能完全匹配，其中匹配的数目为 %d \n",num1.num);
			hasChanged=1;
		}
		if(!num2.matches)
		{
			printf("中括号的数目不能匹配，其中已经配对的数目为 %d \n",num2.num);
			hasChanged=1;
		}
		if(!num3.matches)
		{
			printf("大括号的数目不能匹配,其中的已经配对的数目 %d \n",num3.num);
			hasChanged=1;
		}
	}
	return 0;
	}
int match(char *p,typematch *yuan,typematch *zh,typematch *da)
{
	int illegal=0;
	int x1=0,x2=0,x3=0;
	int i=0,k=0;
	int length=strlengthof(p);
	int iL1=0,iL2=0,iL3=0;
	int matches=1;
	char *temp=(char *)malloc(length);
	for(i=0;i<length;++i)
        temp[i]=p[i];

	for(i=0;i<length;++i)
	{
		if(temp[i]=='(')
		{
			iL1=1;
			k=i+1;
			while(k<length&&temp[k]!=')')
			   ++k;
			if(k<length&&temp[k]==')')
			{
				temp[k]='\0';
				++x1;
				iL1=0;
			}
		}
	}
	for(i=0;i<length;++i)
	{
		if(temp[i]=='[')
		{
			iL2=1;
			k=i+1;
			while(k<length&&temp[k]!=']')
				++k;
			if(k<length&&temp[k]==']')
			{
				temp[k]='\0';
				++x2;
				iL2=0;
			}
		}
	}
	for(i=0;i<length;++i)
	{
		if(temp[i]=='{')
		{
			iL3=1;
			k=i+1;
			while(k<length&&temp[k]!='}')
				++k;
			if(k<length&&temp[k]=='}')
			{
				temp[k]='\0';
				iL3=0;
				++x3;
			}
		}
	}
   yuan->num=x1;
   yuan->matches=1;
   if(iL1)
   {
	   yuan->matches=0;
	   matches=0;
   }
   zh->num=x2;
   zh->matches=1;
   if(iL2)
   {
	   zh->matches=0;
	   matches=0;
   }
   da->num=x3;
   da->matches=1;
   if(iL3)
   {
	   da->matches=0;
	   matches=0;
   }
  return matches;
}
int strlengthof(char *p)
{
	int i=0;
	while(p[i]!='\0')
		++i;
	return i;
}