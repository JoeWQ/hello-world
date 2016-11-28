//2013年4月15日11:33:11
//为广度优先搜索而设计的栈
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
//初始化栈
  void  initStackHeader(StackHeader *h)
 {
        h->front=NULL;
        h->size=NULL;
  }
//项栈中添加元素
  void  addElems(h,ST  data)
 {
        Stack  *s=(Stack *)malloc(sizeof(Stack));
        s->data=data;
        s->next=h->front;
        h->front=s;
        ++h->size;
  }
//从栈中弹出元素
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
//判断栈是否为空
  int  IsStackEmpty(StackHeader *h)
 {
        return !h->size;
  }