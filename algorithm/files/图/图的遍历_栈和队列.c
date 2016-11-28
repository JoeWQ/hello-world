//2013/1/20/11:11
//Ϊͼ�ı�����������ջ�Ͷ���
//������Ǳ���� ͨ�õĴ������
 // typedef     TEMP    KEY
  typedef   struct  _Queue
 {
       struct   _PostGraph  *pst;
       struct   _Queue      *next;
  }Queue;
//����ͷ
  typedef  struct   _QueueHeader
 {
       struct  _Queue    *front;
       struct  _Queue    *rear;
       int               size;
  }QueueHeader;
//����ջ�����ݽṹ
  typedef  struct  _Stack
 {
       struct  _PostGraph  *pst;
       struct  _Stack      *next;
  }Stack;
//ջͷ
  typedef  struct  _StackHeader 
 {
       struct  _Stack  *front;
       int             size;
  } StackHeader;
//����Ĺ��ڶ��еĲ���
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
//�Ӷ�����һ����Ԫ��
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
//�����ǹ���ջ�Ĳ���
  void  push(StackHeader  *h,PostGraph  *pst)
 {
       Stack  *s=(Stack *)malloc(sizeof(Stack));
       s->pst=pst;
       s->next=h->front;
       h->front=s;
       ++h->size;
  }
//����Ԫ��
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
//�ж�ջ�Ƿ�Ϊ��
  int  IsStackEmpty(StackHeader *h)
 {
       return !h->size;
  }