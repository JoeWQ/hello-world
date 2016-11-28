//2013/1/20/11:11
//为图的遍历二创建的栈和队列
//下面的是编程中 通用的代码设计
 // typedef     TEMP    KEY
  typedef   struct  _Queue
 {
       struct   _PostGraph  *pst;
       struct   _Queue      *next;
  }Queue;
//队列头
  typedef  struct   _QueueHeader
 {
       struct  _Queue    *front;
       struct  _Queue    *rear;
       int               size;
  }QueueHeader;
//关于栈的数据结构
  typedef  struct  _Stack
 {
       struct  _PostGraph  *pst;
       struct  _Stack      *next;
  }Stack;
//栈头
  typedef  struct  _StackHeader 
 {
       struct  _Stack  *front;
       int             size;
  } StackHeader;
//下面的关于队列的操作
  void  addQueue(QueueHeader  *h,PostGraph *pst)
 {
       Queue  *q=(Queue *)malloc(sizeof(Queue));
       q->pst=pst;
       q->next=NULL;
       
       if( ! h->front)
            h->front=q;
       else
            h->rear->next=q;
       h->rear=q;

       ++h->size;
  }
//从队列中一处首元素
  void  removeQueue(QueueHeader  *h,PostGraph  **pst)
 {
       Queue  *q;
       if( h->size )
      {
              q=h->front;
              h->front=q->next;
              --h->size;
             *pst=q->pst;
			 free(q);
       }
  }
  int  IsQueueEmpty(QueueHeader *h)
 {
      return !h->size;
  }
//下面是关于栈的操作
  void  push(StackHeader  *h,PostGraph  *pst)
 {
       Stack  *s=(Stack *)malloc(sizeof(Stack));
       s->pst=pst;
       s->next=h->front;
       h->front=s;
       ++h->size;
  }
//弹出元素
  void  pop(StackHeader *h,PostGraph **pst)
 {
      Stack  *s;
      if(h->size)
     {
            s=h->front;
            *pst=s->pst;
            h->front=s->next;
            --h->size;
            free(s);
     }
     else
         *pst=NULL;
  }
//判断栈是否为空
  int  IsStackEmpty(StackHeader *h)
 {
       return !h->size;
  }