//2013��4��15��10:13:42
//��̬˫�˶���
//  #include<stdio.h>
//  #include<stdlib.h>
  typedef  struct  _Queue
 {
        int              vertex;
        struct  _Queue   *prev;
        struct  _Queue   *next;
  }Queue;
//
  typedef  struct  _QueueHeader
 {
        struct  _Queue   *front;
        struct  _Queue   *rear;
  }QueueHeader;
//��ȡ���е�ͷԪ�ؽ��(���������Ϊ������Ŀ�Ķ���Ƶ�)
  int  GetTopq(QueueHeader  *h)
 {
        Queue  *p=h->front;
        int    vertex=0;
        if( p )
            vertex=p->vertex;
        return vertex;
  }
  int  IsQueueEmpty(QueueHeader *h)
 {
        return !h->front;
  }
//���������ӽ��Ԫ��
  Queue   *addElemq(QueueHeader  *h,int  vertex)
 {
        Queue  *p=(Queue  *)malloc(sizeof(Queue));
        p->vertex=vertex;
        p->next=NULL;
        if(!h->front)
       {
            h->front=p;
            p->prev=NULL;
        }
        else
       {
            p->prev=h->rear;
            h->rear->next=p;
        }
        h->rear=p;
        return p;
  }
//�Ӷ�����ɾ������ͷԪ�ؽ��
  int  removeTopq(QueueHeader  *h)
 {
        int  vertex=-1;
        Queue   *p=h->front;
        if( p )
       {
              vertex=p->vertex;
              h->front=p->next;
              if( p->next )
                   h->front->prev=NULL;
              else
				           h->rear=NULL;
              free(p);
        }
        return vertex;
  }
//�������Ľ���ƶ������е�ͷ��
  void  moveToHead(QueueHeader  *h,Queue  *p)
 {
//���Ƚ�������Ӷ������Ƴ���
        Queue  *q,*t;
        t=p->next;
        q=p->prev;
//�����ж�һЩ��������
        if(! q)  //���p�Ѿ���ͷ��㣬ֱ���˳�
            return;
        if(! t)
       {
            h->rear=q;
            q->next=NULL;
            p->next=h->front;
            h->front->prev=p;
        }
        else
       {
            q->next=t;
            t->prev=q;
            p->next=h->front;
        }
        p->prev=NULL;
        h->front=p;
  }
/*
//���Դ���
  int  main(int  argc,char  *argv[])
 {
        QueueHeader  hQueue,*h=&hQueue;
        Queue        *p,*q;
        int          i,len=16;
        
        h->front=NULL;
        h->rear=NULL;
        printf("����������Ԫ��!\n");
        for(i=0;i<len;++i)
            addElem(h,i);
        printf("�������е�����:\n");
        
        q=h->front;
        i=0;
        p=NULL;
        while( q )
       {
               printf("����:%d \n",q->vertex);
               q=q->next;
               if(++i==8)
                  p=q;
        }
//**********************************************************
        printf("�������еĽ�㷭ת");
//        printf("p==%d",p);
        moveToHead(h,p);
        printf("�ٴη�ת����\n");
        q=h->front;
        while( q )
       {
                printf("����:%d \n",q->vertex);
                q=q->next;
        }
//*****************************************************
        printf("�ڶ��η�ת\n");
        p=h->rear;
        moveToHead(h,p);
        q=h->front;
        while( q )
       {
               printf("����:%d \n",q->vertex);
               q=q->next;
        }
        return 0;
  }
*/