//2013年4月11日10:34:53
//为压入与标记算法而设计的队列(底层用数组实现)
  typedef  struct  _QueueHeader
 {
//记录队列当前已经使用的空间大小，当它的值大于length时，队列将溢出
       int        size;
//记录队列的总的空间大小
       int        length;
//记录队列的头指针
       int        head;
//记录队列的尾指针
       int        tail;
       int        *queue;
  }QueueHeader;
//对队列进行进行初始化
  void   initQueue(QueueHeader  *h,int   length)
 {
       h->size=0;
       h->length=length;
       h->head=0;
       h->tail=0;
       h->queue=(int *)malloc(sizeof(int)*length);
  }
//将元素添加到队列的尾部
  int  addQueue(QueueHeader  *h,int  elem)
 {
       int  flag=0;
       if(h->size<h->length)
      {
              h->queue[(h->tail++)%(h->length)]=elem; 
              ++h->size;
              flag=1;
       }
       else
              printf("队列溢出错误!\n");
       return flag;
  }
//从队列的头部删除首元素
  int  removeQueue(QueueHeader  *h)
 {
       int   elem=-1;
       if( h->size )
      {
            elem=h->queue[(h->head++)%(h->length)];
            --h->size;
       }
       else
           printf("队列已经为空，不能再次执行删除操作!\n");
       return elem;
  }
//判断队列是否为空
  int  isQueueEmpty(QueueHeader  *h)
 {
       return ! h->size;
  }