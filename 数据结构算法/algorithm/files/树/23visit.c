//23树的深度遍历
  typedef  struct  _Queue
 {
      struct  _Tree23  *node;
      struct  _Queue   *next;
  }Queue;

  typedef  struct  _QueueInfo
 {
      struct  _Queue  *front;
      struct  _Queue  *rear;
      int     len;
  }QueueInfo;
//*******************************************
  static void  push(QueueInfo *info,Tree23 *item)
 {
      Queue   *p=(Queue *)malloc(sizeof(Queue));
      p->node=item;
      p->next=NULL;

      if(! info->front)
           info->front=p;
      else
           info->rear->next=p;
      info->rear=p;
      ++info->len;
  }
  static  int pop(QueueInfo  *info,Queue *p)
 {
      Queue  *tmp;
      if(info->len)
     {
          tmp=info->front;
          p->node=tmp->node;
          info->front=tmp->next;
          --info->len;
          free(tmp);
          return 1;
      }
      else
         return 0;
  }
  void  dvisit23(Tree23Info *info)
 {
      QueueInfo   queue;
      Queue       q;
      Tree23      *p;

      if(! info->root)
         return;
      queue.front=NULL;
      queue.rear=NULL;
      queue.len=0;

      push(&queue,info->root);
      while(queue.len)
     {
           pop(&queue,&q);
           p=q.node;

           if(p->rdata!=M_INT)
          {
               printf("节点:%x,ldata:%d,rdata:%d,左子树：%x,中子树%x,右子树:%x\n",p,p->ldata,p->rdata,p->lchild,p->mchild,p->rchild);
               if(p->lchild)
              {
                   push(&queue,p->lchild); 
                   push(&queue,p->mchild);
               }
               if(p->rchild)
                  push(&queue,p->rchild);
          }
          else
         {
               printf("结点:%x,ldata:%d,左子树%x,中子树:%x\n",p,p->ldata,p->lchild,p->mchild);
               if(p->lchild)
              {
                    push(&queue,p->lchild);
                    push(&queue,p->mchild);
               }
          } 
      }
  }
               