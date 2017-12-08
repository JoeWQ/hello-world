#include<stdio.h>
#include<stdlib.h>
#define null NULL
#define array_flags 2
int array[array_flags]={16,12};
typedef struct Student
{
	int score;
	struct Student *next;
} Link;
typedef struct RECORD
{
	Link *head;
	int length;
} Record;
Record *achieveArray(int *);
Record *createLinks(Record *);
Record *compareLinks(Record *);
Link *del_Link(Record *,Link *);
void printLinks(Record *);
void freeLinks(Record *);
int main()
{
	Record *record;
	puts("*********************************");
	record=achieveArray(array);
    record=createLinks(record);
	puts("Before compared ,the data as below !");
	printLinks(record);	
	puts("-----------------------------");
    record=compareLinks(record);
	puts("After compared,the data as below !");
    printLinks(record);
	puts("---------------------------------");
	puts("All the data have been compared !");
	freeLinks(record);
    return 0;
}
Record *achieveArray(int *array)
{
	int i;
	Record *head;
	head=(Record *)malloc(sizeof(Record)*array_flags);
	for(i=0;i<array_flags;++i)
	{
        head[i].length=array[i];
		head[i].head=null;
	}
	return head;
}
Record *createLinks(Record *array)
{
	int i,k;
	Link *p,*key;
	for(i=0;i<array_flags;++i)
	{
		p=(Link *)malloc(sizeof(Link));
		array[i].head=p;
		key=p;
		p->score=rand();
		 for(k=1;k<array[i].length;++k)
		 {
			 p=(Link *)malloc(sizeof(Link));
			 key->next=p;
			 key=p;
			 key->score=rand();
		 }
		 p->next=null;
	}
	return array;
}
Link *del_Link(Record *header,Link *p)
{
	Link *head=header->head;
	if(p==head)
	{
      header->head=p->next;
	  free(p);
	}
    else if(p->next!=null)
	{
		while(head->next!=p)
			head=head->next;
		head->next=p->next;
		free(p);
	}
	else
	{
		while(head->next!=p)
			head=head->next;
		free(p);
		head->next=null;
	}
	--header->length;
	return head->next;
}
Record *compareLinks(Record *array)
{
	Link *media=array[0].head;
	Link *key=array[1].head;
	int i;
	int flag;
	if(array[0].length<=array[1].length)
	{
		for(i=0;i<array[0].length;++i)
		{
			while(key!=null)
			{
               flag=0;                          //���ݿ�ıȽϣ�Ϊ�˱��ֲ������е�����һ��//�ԣ������˱�־����flag...
               if(key->score==media->score)     //��flag=1ʱ��˵����ʱ��ǰ���ݿ��Ѿ���ɾ��//���Ѿ���
			   {                                //���Ա����ã���ʱ���ڴ˵���ָ//��key=key->next��������Ա����ֹ�������
				   key=del_Link(&array[1],key); //������һ�µ�ָ��������ͬ//��
				   ++flag;
			   }
			   if(flag==0)
			   {
			      key=key->next;
			   }
			}
			media=media->next;
		}
	}
	else
	{
		for(i=0;i<array[1].length;++i)
		{
			while(media!=null)
			{
				flag=0;
				if(key->score==media->score)
				{
					del_Link(&array[0],media);
					++flag;
				}
				if(flag==0)
				{
				    media=media->next;
				}
			}
			key=key->next;
		}
	}
	return array;
}
void printLinks(Record *array)
{
	int i;
	Link *p;
	for(i=0;i<array_flags;++i)
	{
		printf("The %dst data region as below :\n",i+1);
		p=array[i].head;
		while(p!=null)
		{
			printf("The score is %6d \n",p->score);
			p=p->next;
		}
		printf("As above ,the total number of score is %d \n",array[i].length);
	}
}
void freeLinks(Record *array)
{
	Link *p,*key;
	int i;
	for(i=0;i<array_flags;++i)
	{
		p=array[i].head;
		key=p;
		while(p!=null)
		{
           p=p->next;
		   free(key);
		   key=p;
		}
	}
	free(array);
	puts("All the memory has been freed off !");
}