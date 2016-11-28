//23������ȱ���
  typedef  struct  _Queue
 {
      struct  _Tree234  *node;
      struct  _Queue    *next;
  }Queue;

  typedef  struct  _QueueInfo
 {
      struct  _Queue  *front;
      struct  _Queue  *rear;
      int     len;
  }QueueInfo;
//*******************************************
  static void  push(QueueInfo *info,Tree234 *item)
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
  void  dvisit234(Tree234Info *info)
 {
      QueueInfo    queue;
      Queue        q;
      Tree234      *p;

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
               printf("�ڵ�:%x,ldata:%d,mdata:%d,rdata:%d,��������%x,��������%x,��������:%x\n,������:%x",p,p->ldata,p->mdata,p->rdata,p->lchild,p->lmchild,p->mrchild,p->rchild,p->rchild);
               if(p->lchild)
              {
                    push(&queue,p->lchild); 
                    push(&queue,p->lmchild);
               }
               if(p->mrchild)
                    push(&queue,p->mrchild);
               if(p->rchild)
                    push(&queue,p->rchild); 
          }
          else if(p->mdata!=M_INT)
         {
               printf("���:%x,ldata:%d,mdata:%d,������%x,��������:%x,��������%x\n",p,p->ldata,p->mdata,p->lchild,p->lmchild,p->mrchild);
               if(p->lchild)
              {
                    push(&queue,p->lchild);
                    push(&queue,p->lmchild);
               }
               if(p->mrchild)
                    push(&queue,p->mrchild);
               if(p->rchild)
                    push(&queue,p->rchild);
          }
          else
         {
               printf("���:%x,ldata:%d,������:%x,��������:%x\n",p,p->ldata,p->lchild,p->lmchild);
               if(p->lchild)
              {
                    push(&queue,p->lchild);
                    push(&queue,p->lmchild);
               }
               if(p->mrchild)
                    push(&queue,p->mrchild);
               if(p->rchild)
                    push(&queue,p->rchild);
          }
      }
  }
               