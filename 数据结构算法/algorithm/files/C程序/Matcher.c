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
	//num1ΪԲ���ŵ���Ŀ��num2Ϊ�����ŵ���Ŀ,num3Ϊ�����ŵ���Ŀ
	typematch num1,num2,num3;
	int hasChanged=0;
	char c;
	puts("������һ�����ű��ʽ!");
loops:
	while((c=getchar())!='\n')
	{
		p[i]=c;
		++i;
		if(i==128)
		{
			puts("��������ַ����ܳ���128�� ,����������!");
			i=0;
			goto loops;
		}
	}
	if(match(p,&num1,&num2,&num3))
	{
		if(num1.num || num2.num ||num3.num)
		{
	    	puts("����������ű��ʽ��ȫƥ��!����:");
	    	printf("Բ���ŵ���ĿΪ: %d ��\n",num1);
	    	printf("�����ŵ���ĿΪ: %d ��\n",num2);
	    	printf("�����ŵ���ĿΪ: %d ��\n",num3);
		}else
		{
			puts("������ı��ʽ��û���κ�����!");
		}
	}else
	{
		puts("����������ű��ʽ��������ȫƥ��!���еĴ�������: ");
		if(!num1.matches)
		{
			printf("Բ���Ų�����ȫƥ�䣬����ƥ�����ĿΪ %d \n",num1.num);
			hasChanged=1;
		}
		if(!num2.matches)
		{
			printf("�����ŵ���Ŀ����ƥ�䣬�����Ѿ���Ե���ĿΪ %d \n",num2.num);
			hasChanged=1;
		}
		if(!num3.matches)
		{
			printf("�����ŵ���Ŀ����ƥ��,���е��Ѿ���Ե���Ŀ %d \n",num3.num);
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