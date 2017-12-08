//将链表项的指针进行翻转
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
//****************************************
  #define  MAX_SIZE    16
  typedef struct _Link
 {
     int data;
     struct _Link *next;
  }Link;
  
  Link *CreateLink(int );
  void printLink(Link *);
  Link *reverseLink(Link *);
//
//  Link *front;
//  int  size;
  int main(int argc,char *argv[])
 {
     Link *tmp;
     Link *front=CreateLink(MAX_SIZE); 
     printf("翻转前的链表:\n");
     printLink(front);
     printf("\n翻转后的链表:\n");
     front=reverseLink(front);
     printLink(front);
//释放申请的空间
     while(front)
    {
        tmp=front;
        front=front->next;
        free(tmp);
     } 
     return 0;
  }
//************************************************8
  Link  *CreateLink(int size)
 {
     Link *tmp,*front;
     int i;
     int seed;
     if(!size)
       return NULL;
     front=(Link *)malloc(sizeof(Link));
     seed=time(NULL);
     srand(seed);
     front->data=rand();
     front->next=NULL;
     for(i=1;i<size;++i)
    {
        tmp=(Link *)malloc(sizeof(Link));
        tmp->data=rand();
        tmp->next=front;
        front=tmp;
     }
     return front;
  }
//******************************************************8
//翻转链表
  Link *reverseLink(Link *front)
 {
     Link *middle,*rear;
     rear=NULL;
     middle=NULL;
     while(front)
    {
         rear=middle;
         middle=front;
         front=front->next;
         middle->next=rear;
     }
     return middle;
  }
//输出链表
  void printLink(Link *front)
 {
//     Link *tmp;
     int i=0;
     while(front)
    {
        printf("第 %d 个元素为:%d \n",i,front->data);
        front=front->next;
		++i;
     }
  }