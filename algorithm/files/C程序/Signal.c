#include<stdio.h>
#include<stdlib.h>
#define null NULL
#define Error -1
#define OK 1
#define EXP 0
typedef struct Sig
{
	char sign;
	struct Sig *next;
} Signal;
int judge(char *);
Signal *del_matcher(Signal *,char,int *);
Signal *increaseMemory(int);
void result(char *);
void _free(Signal *);
int main()
{
	char array[20];
	puts("Please input a serise of signal [ ( or ] )!");
	gets(array);
    result(array);
    puts("--------------------------");
	return 0;
}
int judge(char *array)//判断输入的搭配情况
{
	int flag=0;
	int i=0;
	Signal *key,*media=null;
	Signal *p=(Signal *)malloc(sizeof(Signal));
	key=p;
	p->next=null;
	if(!p)
		return EXP;
	for(i=0;array[i]!='\0';++i)
	{
		if((array[i]=='(')||(array[i]=='['))
		{
			key->sign=array[i];
			p=increaseMemory(sizeof(Signal));
			p->next=key;
			key=p;
			flag=0;
		}
		else if((array[i]==']')||(array[i]==')'))
		{
			if(array[i]==')')
			{
				key=del_matcher(key,'(',&flag);
				if(flag==0)
				{
					_free(key);
					return Error;
				}
			}
			else
			{
				key=del_matcher(key,'[',&flag);
				if(flag==0)
				{   
					_free(key);
					return Error;
				}
			}
		}
		else
			return Error;
	}
    _free(key);
	return OK;
}
/*
 *获取所需的动态内存！
 */
Signal *increaseMemory(int size)
{
	Signal *p;
	p=(Signal *)malloc(size);
	if(!p)
	  return null;
	p->next=null;
	p->sign='\0';
	return p;
}
void result(char *array)
{
	int sign;
	sign=judge(array);
	if(sign==OK)
	{
		printf("The signal you has input is right match !\n");
	}
	else if(sign==Error)
	{
		printf("Error !Please input them again !");
	}
	else
	{
		printf("The memory alloc error !");
	}
}
/*
*删除符合要求的节点！
*/
Signal *del_matcher(Signal *p,char c,int *flag)
{
	Signal *head=p;
	Signal *key=p;
	if(p->sign==c)
	{
		head=p->next;
		++*flag;
		free(p);
	}
	else if(p->next!=null) 
	{
		while(p!=null)
		{
			key=p;		
			p=p->next;	
			if(p->sign==c)
			{
				key->next=p->next;
				++*flag;
				free(p);
				break;
			}
		}
		if(p==null)
			head=null;
	}
	else
		head=null;
	return head;
}
/*
**释放内存
*/
void _free(Signal *p)
{
	Signal *key=p;
	while(p!=null)
	{
		p=p->next;
		free(p);
		key=p;
	}
	puts("All the memory has been freed off !");
}
