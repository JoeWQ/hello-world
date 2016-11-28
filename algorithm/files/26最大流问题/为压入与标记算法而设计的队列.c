//2013��4��11��10:34:53
//Ϊѹ�������㷨����ƵĶ���(�ײ�������ʵ��)
  typedef  struct  _QueueHeader
 {
//��¼���е�ǰ�Ѿ�ʹ�õĿռ��С��������ֵ����lengthʱ�����н����
       int        size;
//��¼���е��ܵĿռ��С
       int        length;
//��¼���е�ͷָ��
       int        head;
//��¼���е�βָ��
       int        tail;
       int        *queue;
  }QueueHeader;
//�Զ��н��н��г�ʼ��
  void   initQueue(QueueHeader  *h,int   length)
 {
       h->size=0;
       h->length=length;
       h->head=0;
       h->tail=0;
       h->queue=(int *)malloc(sizeof(int)*length);
  }
//��Ԫ����ӵ����е�β��
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
              printf("�����������!\n");
       return flag;
  }
//�Ӷ��е�ͷ��ɾ����Ԫ��
  int  removeQueue(QueueHeader  *h)
 {
       int   elem=-1;
       if( h->size )
      {
            elem=h->queue[(h->head++)%(h->length)];
            --h->size;
       }
       else
           printf("�����Ѿ�Ϊ�գ������ٴ�ִ��ɾ������!\n");
       return elem;
  }
//�ж϶����Ƿ�Ϊ��
  int  isQueueEmpty(QueueHeader  *h)
 {
       return ! h->size;
  }