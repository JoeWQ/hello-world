#include<stdio.h>
#include<stdlib.h>
#define null NULL
#define Capacity 16
typedef struct list
{
	int score;
	struct list *next;
}Link;
typedef struct List
{
	Link *front;
	Link *tail;
	int length;
}QList;
QList *initial(int );
void giveValue(Link *);
int del_Link(QList  *,const int );
void print(QList *);
void insert(QList *,const int index);
//id append(const QListint *,int value);
void freeAll(QList *);
int main()
{
	QList *p=null;
	int i=0;
	//...........................................
	p=initial(Capacity);
	puts("The first links as below !");
	print(p);
	//...........................................
    puts("As example ,We will insert some data !");
	for(i=0;i<5;++i)
		insert(p,i);
	puts("After inserted !");
	print(p);
	//*****************************.........
	puts("............................");
    for(i=0;i<4;++i)
		del_Link(p,i);
	puts("After deleted !");
	print(p);
	freeAll(p);
	return 0;
}
void giveValue(Link *p)
{
	if(p!=null)
	{
		p->score=rand();
		p->next=null;
	}
}
QList *initial(int limit)
{
	int i=0;
	QList *p=null;
	Link *key=null,*pkey=null;
	p=(QList *)malloc(sizeof(QList));
	if(p!=null)
		p->length=limit;
	/*

  */
	key=(Link *)malloc(sizeof(Link));
	if(key!=null)
	{
	   giveValue(key);
	   pkey=key;
	   p->front=key;
	}
    for(i=1;i<limit;++i)
	{
       key=(Link *)malloc(sizeof(Link));
	   giveValue(key);
	   pkey->next=key;
	   pkey=key;
	}
	p->tail=key;
	return p;
}
void print(QList *p)
{
	Link *key=null;
	int index=0;
	if(p->front!=null)
	{
		key=p->front;
		while(key!=null)
		{
			printf("The %dth score is %d \n",++index,key->score);
	    	key=key->next;
		}
	}
}
void freeAll(QList *p)
{
	Link *key=null,*pkey=null;
	if(p!=null)
	{
		key=p->front;
		pkey=key;
		while(key!=null)
		{
			key=key->next;
			free(pkey);
			pkey=key;
		}
		free(p);
        p=null;
	}
}
int del_Link( QList  *p,const int index)
{
	Link *key=null,*pkey=null;
	int flag=0;
	int i=1;
	if(p==null)
		return 0;
	key=p->front;
	if(index>0&&index<p->length-1)
	{
		while(i++<index)
		  key=key->next;
		pkey=key->next;
		key->next=pkey->next;
		free(pkey);
		p->length-=1;
		flag=1;
	}	
	else if(index==0)
	{
		p->front=key->next;
		free(key);
		p->length-=1;
        flag=1;
	}
	else if(index==p->length-1)
	{
		while(key->next!=p->tail)
			key=key->next;
		free(key->next);
		p->tail=key;
		p->length-=1;
		flag=1;
	}
	else
	    flag=0;
	return flag;
}
void insert(QList *p,const int index)
{
   Link *key=null,*pkey=null;
   Link *media=null;
   int i=1;
   if(p==null)
	   return ;
   key=p->front;
   pkey=key;
   if(index>=0&&index<p->length-1)
  {
     while(i++<index)
  	 key=key->next;
     pkey=key->next;
     media=(Link *)malloc(sizeof(Link));
     giveValue(media);
     key->next=media;
     media->next=pkey;
     p->length+=1;
  }
  else if(index==p->length)
 {
    media=(Link *)malloc(sizeof(Link));
    giveValue(media);
    p->tail->next=media;
    p->tail=media;
    p->length+=1;
  }
  else 
    return ;
 }