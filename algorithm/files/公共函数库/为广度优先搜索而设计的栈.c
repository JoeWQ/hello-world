//2013��4��15��11:33:11
//Ϊ���������������Ƶ�ջ
  typedef  struct  _Stack
 {
        ST               *data;
        struct  _Stack  *next;
  }Stack;

  typedef  struct  _StackHeader
 {
        struct  _Stack  *front;
        int              size;
  }StackHeader;
//��ʼ��ջ
  void  initStackHeader(StackHeader *h)
 {
        h->front=NULL;
        h->size=NULL;
  }
//��ջ�����Ԫ��
  void  addElems(h,ST  data)
 {
        Stack  *s=(Stack *)malloc(sizeof(Stack));
        s->data=data;
        s->next=h->front;
        h->front=s;
        ++h->size;
  }
//��ջ�е���Ԫ��
  ST   *removeFirst(h)
 {
        Stack  *s=h->front;
        ST     *data=NULL;

        if( s )
       {
              data=s->data;
              h->front=s->next;
              --h->size;
             free(s);
        }
        return data;
  }
//�ж�ջ�Ƿ�Ϊ��
  int  IsStackEmpty(StackHeader *h)
 {
        return !h->size;
  }