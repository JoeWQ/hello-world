#include<stdio.h>
#include<stdlib.h>
#define null NULL
#define Capacity 24
typedef struct Node
{
	int index;
	int elem;
	struct Node *prev;
	struct Node *next;
}Link;
Link *create(int );
void init(Link *,int *);
void print(Link *);
int selecteNumber();
void rotate();
Link *del_Link(Link *,const int);
int main()
{
	Link *p=create(Capacity);
	puts("Before deleted the node of the clock !");
	rotate(p);
	return 0;
}
void init(Link *p,int *index)
{
	if(p!=null)
	{
		p->index=++*index;
		p->elem=rand();
		p->prev=null;
		p->next=null;
	}
}
void print(Link *p)
{
	if(p!=null)
	{
		printf("The index of %d is : %d   .\n",p->index,p->elem);
	}
}
Link *create(int limit)
{
	Link *head=null,*p=null;
	Link *key=null;
	int i=0,index=0;
	head=(Link *)malloc(sizeof(Link));
	init(head,&index);
	p=head,key=head;
	for(i=1;i<limit;++i)
	{
		p=(Link *)malloc(sizeof(Link));
		init(p,&index);
		key->next=p;
		p->prev=key;
		key=p;
	}
    p->next=head;
	head->prev=p;
	return head;
}
int selecteNumber()
{
	int num=0;
	do
	{
		num=rand();
		num=num%Capacity;
	}while(num<=0);
    return num;
}
Link *del_Link(Link *p,const int index)
{
    Link *head=null,*key=p;
	int i=0;
	while(p!=null)
	{
		p=p->next;
		++i;
        if(i==index)
			break;
	}
	if(p->next!=p)
	{
    	head=p->next;
    	key=p->prev;
		key->next=head;
		head->prev=key;
		print(p);
    	free(p);
		return head;
	}
	else
	{
		print(p);
		free(p);
		return null;
	}
}
void rotate(Link *p)
{
	int index=0;
	int i=0;
   	int const num=selecteNumber();
	do
	{
    	p=del_Link(p,num);
	}while(p!=null);
}