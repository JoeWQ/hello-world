#include<stdio.h>
#include<stdlib.h>
#define null NULL
typedef struct LinkedList
{
	int bin;
	struct LinkedList *next;
}Link;
Link *push(Link *,int);
Link *pop(Link *,int *);
Link *create();
void init(Link *);
int main()
{
	int aimed_number;
	int bin=0;
	Link *p=null;
	do
	{
	    puts("Please inpu a positive number !");
		scanf("%d",&aimed_number);
	}while(aimed_number<=0);
    p=create();
	while(aimed_number!=0)
	{
		p=push(p,aimed_number%2);
		aimed_number/=2;
	}
	do
	{
       p=pop(p,&bin);
	   if(bin!=-1)
	     printf("%d ",bin);

	 }while(p!=null);
	putchar('\n');
    getchar();
	return 0;
}
Link *create()
{
	Link *p=(Link *)malloc(sizeof(Link));
	init(p);
	return p;
}
void init(Link *p)
{
	if(p!=null)
	{
		p->bin=-1;
		p->next=null;
	}
}
Link *push(Link *p,int e)
{
	Link *pp=null;
	pp=(Link *)malloc(sizeof(Link));
	if(pp!=null)
	{
		init(pp);
		pp->bin=e;
		pp->next=p;
	}
	return pp;
}
Link *pop(Link *p,int *adre)
{
	Link *pp=null;
    if(p->bin!=-1)
	{
		*adre=p->bin;
		pp=p->next;
		free(p);
		return pp;
	}
	else
	{
		*adre=p->bin;
		free(p);
		return null;
	}
}



