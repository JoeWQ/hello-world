#include<stdio.h>
//�����н��������������ַ������н���������windows����ϵͳ�ķ�����ͬ

int GetArgCount(char *lpc)
{
	int i=0;
	int length=0;
	int j=0;
	int flag=0;
	while(lpc[i]!='\0')
	{
		flag=0;
		while(lpc[i]==' ')
			++i;
		++length;
		while(lpc[i]!='\0'&&lpc[i]!='\"'&&lpc[i]!=' ')
		{
			++flag;
			++i;
		}
		if(lpc[i]=='\"')
		{
			++i;
			j=i; 
                        ++flag;
			while(lpc[j]!='\0'&&lpc[j]!='\"')
				++j;
			if(lpc[j]=='\0')
			{
				j=i;
				while(lpc[j]!=' ')
					++j;
				i=j;
			}
	    	else if(lpc[j]=='\"')
			{
		    	++j;
				if(lpc[j]==' ')
					i=j;
		        else if(lpc[j]!='\0')
				{
			    	while(lpc[j]!='\0'&&lpc[j]!=' ')
				    	++j;
			    	i=j;
				}
			}
		}
	}
	if(!flag)
		--length;
	return length;
}
int main(int alpha,char **argv)
{
	int i=0;
	char *lpc0="Test aaa bbb ccc   \0";
    char *lpc1="Test.exe aaa bbb ccc !\0";
	char *lpc2="Te\"st\".exe aaa bbb ccc !\0";
	char *lpc3="C:/Program\" \"Files/Test aaa bbb ccc !\0";
	char *lpc4="\"Progrm Files Test \" \"aaa bbb ccc\" \0";
	char *lpc5="test a\"aa bbb ccc  \0";
	char *lpc6="Test \" aaa bbb ccc \0";
		printf("�� %d  ���ַ����������в����ĸ����� : %d    .\n",0,GetArgCount(lpc0));
		printf("�� %d  ���ַ����������в����ĸ����� : %d    .\n",1,GetArgCount(lpc1));
		printf("�� %d  ���ַ����������в����ĸ����� : %d    .\n",2,GetArgCount(lpc2));
		printf("�� %d  ���ַ����������в����ĸ����� : %d    .\n",3,GetArgCount(lpc3));
		printf("�� %d  ���ַ����������в����ĸ����� : %d    .\n",4,GetArgCount(lpc4));
		printf("�� %d  ���ַ����������в����ĸ����� : %d    .\n",5,GetArgCount(lpc5));
		printf("�� %d  ���ַ����������в����ĸ����� : %d    .\n",6,GetArgCount(lpc6));
	return 0;
}

