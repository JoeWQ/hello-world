//2013年4月15日10:13:42
//动态双端队列
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
//获取队列的头元素结点(这个函数是为了其它目的而设计的)
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
//项队列中添加结点元素
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
//从队列中删除它的头元素结点
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
//将给定的结点移动到队列的头部
  void  moveToHead(QueueHeader  *h,Queue  *p)
 {
//首先将这个结点从队列中移除掉
        Queue  *q,*t;
        t=p->next;
        q=p->prev;
//首先判断一些特殊的情况
        if(! q)  //如果p已经是头结点，直接退出
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
//测试代码
  int  main(int  argc,char  *argv[])
 {
        QueueHeader  hQueue,*h=&hQueue;
        Queue        *p,*q;
        int          i,len=16;
        
        h->front=NULL;
        h->rear=NULL;
        printf("项队列中添加元素!\n");
        for(i=0;i<len;++i)
            addElem(h,i);
        printf("输出结点中的数据:\n");
        
        q=h->front;
        i=0;
        p=NULL;
        while( q )
       {
               printf("顶点:%d \n",q->vertex);
               q=q->next;
               if(++i==8)
                  p=q;
        }
//**********************************************************
        printf("将队列中的结点翻转");
//        printf("p==%d",p);
        moveToHead(h,p);
        printf("再次翻转队列\n");
        q=h->front;
        while( q )
       {
                printf("顶点:%d \n",q->vertex);
                q=q->next;
        }
//*****************************************************
        printf("第二次翻转\n");
        p=h->rear;
        moveToHead(h,p);
        q=h->front;
        while( q )
       {
               printf("顶点:%d \n",q->vertex);
               q=q->next;
        }
        return 0;
  }
*/