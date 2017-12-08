#include<stdio.h>
#include<stdlib.h>
#define Volum 16
#define null NULL
typedef struct student
{
	int score;
	struct student *next;
}Link;
Link *create(int );
void print(Link *);
Link *reverseLink(Link *);
void freeLink(Link *);
int main()
{
	Link *p=create(Volum);
	printf("Before reversed !\n");
	print(p);
	p=reverseLink(p);
	printf("After reversed !\n");
	print(p);
	freeLink(p);
	return 0;
}
Link *create(int volum)
{
	int i;
	Link *key=null;
	Link *head=null,*p=null;      
	head=(Link *)malloc(sizeof(Link));
	if(!head)
	  return head;
	 key=head,p=head;
	for(i=1;i<volum;++i)
	{
       p=(Link *)malloc(sizeof(Link));
	   key->next=p;
	   key->score=rand();
	   key=p;
	}
     key->next=null;
	 key->score=rand();
	 return head;
}
void freeLink(Link *p)
{
	Link *key=p;
	while(p!=null)
	{
		p=p->next;
		free(key);
		key=p;
	}
	printf("----------\n");
}
void print(Link *p)
{
	int i=1;
	while(p!=null)
	{
		printf("The %dth score is : %d\n",i,p->score);
		++i;p=p->next;
	}
}
Link *reverseLink(Link *p)
{
	Link *key=p;Link **array=null;
	int i=0,j=0;
	while(p!=null)
	{
		p=p->next;
		++i;
	}
   if(i>1)
   {
	   array=(Link **)malloc(sizeof(Link *)*i);
	   p=key;
           j=i-1;
		i=0;
       while(p!=null)
	   {
		   array[i]=p;
		   ++i;
		   p=p->next;
	   }
	   key=array[j];
	   while(j>0)
	   {
		   array[j]->next=array[j-1];
		   --j;
	   }
	   array[j]->next=null;
	   free(array);
   }
   return key;
}