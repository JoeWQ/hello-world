//���ݸ�����ͼ������С������
  #include<stdio.h>
  #include<stdlib.h>
  #define  ROW_SIZE 7
//
  typedef  struct  _Post
 {
     int  index;
     int  preindex;
     int  data;
     int  visited;
     struct  _Post  *prev;
     struct  _Post  *next;
  }Post;
//
  typedef  struct  _Graph
 {
      int  len;
      int  data;
      struct  _Post  *front;
      struct  _Post  *rear;
  }Graph;
//
  typedef  struct  _GraphInfo
 {
      int  len;
      struct  _Graph  *front;
  }GraphInfo;
//
  typedef  struct  _SortedQueue
 {
      int  from;
      int  to;
      int  data;
      struct  _SortedQueue  *prev;
      struct  _SortedQueue  *next;
  }SortedQueue;
//
  typedef  struct  _SpanTree
 {
//���򼯺ϵĳ̶�
      int  nlen;
//�Ѿ��ź���ļ��ϵĳ̶�
      int  len;
//û������Ķ��нڵ�ͷָ��
      struct  _SortedQueue  *usort;
      struct  _SortedQueue  *rear;
//�Ѿ��ź����������ĸ��ڵ�
      struct  _SortedQueue  *spant;
  }SpanTree;
//����
  int mat[7][7]={{0,28,0,0,0,10,0},
                 {28,0,16,0,0,0,14},//1
                 {0,16,0,12,0,0,0},
                 {0,0,12,0,22,0,18},//3
                 {0,0,0,22,0,25,24},//4
                 {10,0,0,0,25,0,0},//5
                 {0,14,0,18,24,0,0}};

  GraphInfo    *CreateGraphInfo(int *,int row);
  SortedQueue  *CreateSortedQueue(GraphInfo *);
  SpanTree     *CreateSpanningTree(SortedQueue *,int);
  int          find(int *,int,int);
  void         union_v(int *parent,int,int);

  GraphInfo    *CreateGraphInfo(int *mat,int row)
 {
       int    *tmp;
       Post   *post;
       int    i,k;
       GraphInfo  *info;
       Graph      *graph;
       
       info=(GraphInfo *)malloc(sizeof(GraphInfo));
       info->len=row;
       info->front=(Graph *)malloc(sizeof(Graph)*row);
       graph=info->front;

       for(tmp=mat,i=0;i<row;++i,++graph)
      {
           tmp+=i;
           graph->len=0;
           graph->front=NULL;
           graph->rear=NULL;
           graph->data=0;
           for(k=i;k<row;++k,++tmp)
          {
              if(*tmp)
             {
                   post=(Post *)malloc(sizeof(Post));
                   post->data=*tmp;
                   post->index=k;
                   post->preindex=i;
                   post->prev=NULL;
                   post->next=NULL;
                   post->visited=0;
           
                   if(graph->len)
                  {
                       post->next=graph->front;
                       graph->front->prev=post;
                       graph->front=post;
                   }
                   else
                  {
                       graph->front=post;
                       graph->rear=post;
                   }
                   ++graph->len;
              }
           }
       }
       for(graph=info->front,i=0;i<row;++i)
      {
            printf("%d��Ԫ��Ϊ:",i);
            post=graph[i].front;
            while(post)
           {
                 printf("%d:(%d) ,",post->index,post->data);
                 post=post->next;
            }
            putchar('\n');
       }
     return  info;
  }
//�����������
  SortedQueue   *CreateSortedQueue(GraphInfo  *info)
 {
      SortedQueue  *queue,*tmp,*rear;
      Post   *post,*record;
      Graph  *graph; 
      int   len,i,k,tlen;
      int   min;
       
      queue=NULL;
      rear=NULL;
      len=info->len;
      tlen=0;
//�������еıߵ���Ŀ
      for(i=0,graph=info->front;i<len;++i,++graph)
     {
           tlen+=graph->len;
      }
      for(i=0;i<tlen;++i)
     {
           graph=info->front;
           min=0;
           record=NULL;
           for(k=0;k<len;++k,++graph)
          {
                post=graph->front;
                while(post)
               {
                     if(record && min>post->data && !post->visited)
                    {
                         min=post->data;
                         record=post;
                     }
                     else if(!record && !post->visited)
                    {
                         min=post->data;
                         record=post;
                     }
                     post=post->next;
                }
            }
            if(queue)
           {
                tmp=(SortedQueue *)malloc(sizeof(SortedQueue));
                tmp->from=record->preindex;
                tmp->to=record->index;
                tmp->data=record->data;
                tmp->prev=NULL;
                tmp->next=NULL;
                rear->next=tmp;
                tmp->prev=rear;
                rear=tmp;
                record->visited=1;
            }
            else
           {
                queue=(SortedQueue *)malloc(sizeof(SortedQueue));
                queue->from=record->preindex;
                queue->to=record->index;
                queue->data=record->data;
                record->visited=1;
                queue->prev=NULL;
                queue->next=NULL;
                rear=queue;
            }
    }
    printf("-----------���еıߵļ���------------------------------\n");
    tmp=queue;
    while(tmp)
   {
        printf("%d-->%d :%d \n",tmp->from,tmp->to,tmp->data);
        tmp=tmp->next;
    }
	printf("--------------------------------------------------------\n");
    return  queue;
  }
//������С����������
  SpanTree  *CreateSpanningTree(SortedQueue  *queue,int size)
 {
      SortedQueue  *front,*tmp,*sq;
      int          *parent;
      int  i,k;
      SpanTree  *set;
//      SortedQueue  *rear;
      parent=(int *)malloc(sizeof(int)*size);
      set=(SpanTree *)malloc(sizeof(SpanTree));
      set->nlen=0;
      set->len=0;
      set->usort=NULL;
      set->spant=NULL;
      set->rear=NULL;
      
      for(i=0;i<size;++i)
          parent[i]=-1;
      for(front=queue;front;)
     {
          sq=front;
          if(!find(parent,sq->from,sq->to))
         {
//��ѡ�еĽڵ���ӵ�������
               printf("�������ɱ�%d--->%d\n",sq->from,sq->to);
               union_v(parent,sq->from,sq->to);
//�Ӷ�����ɾ����ѡ�еĽڵ�
               if(!sq->prev)
              {
                   if(front==queue)
                      queue=sq->next;
                   front=sq->next;
                   if(front)
                      front->prev=NULL;
                   sq->next=NULL;
               }
               else
              {
                   sq->prev->next=sq->next;
                   front=sq->next;
                   if(sq->next)
                       sq->next->prev=sq->prev;
                   sq->prev=NULL;
                   sq->next=NULL;
               }
               if(set->usort)
              {
                    set->rear->next=sq;
                    sq->prev=set->rear;
                    set->rear=sq;
                    ++set->nlen;
                }
                else
               {
                    set->usort=sq;
                    set->rear=sq;
                    ++set->nlen;
                }
          }
          else
         {
            printf("..���µı�Ϊ:%d--->%d\n",front->from,front->to);
            front=front->next;
          }
      }
      if(set->nlen)
         printf("���ɵıߵ���ĿΪ%d!\n",set->nlen);
//�ͷ�ʣ�µ�û�б�ѡ�еĽڵ�
printf("*****************************************************************\n");
      while(queue)
     {
          tmp=queue;
          printf("%d-->%d :%d \n",tmp->from,tmp->to,tmp->data);
          queue=queue->next;
          free(tmp);
      }
      printf("-------------------------------------------------------\n");
//***********************************************************
//��ʼ������Ķ��нڵ�����
     set->rear=NULL;
//Ѱ����С��
     i=0;
//...........................................
     tmp=set->usort;
     for(;set->nlen>0;)
    {
         sq=set->usort;
         while(sq)
        {
            if(sq->from==i || sq->to==i)
           {
//���ڵ�sqɾ����
                if(sq->prev)
               {
                    sq->prev->next=sq->next;
                    if(sq->next)
                        sq->next->prev=sq->prev;
                    sq->prev=NULL;
                    sq->next=NULL;
                }
                else
               {
                    set->usort=sq->next;
                    if(sq->next)
                        sq->next->prev=NULL;
                    sq->next=NULL;
                }         
                if(set->spant)
               {
                    set->rear->next=sq; 
                    sq->prev=set->rear;
                    set->rear=sq;
                }
                else
               {
                    set->spant=sq;
                    set->rear=sq;
                }
                ++set->len;
                --set->nlen;
				if(i==sq->from)
					i=sq->to;
				else
					i=sq->from;
                break;
            }
            sq=sq->next;
         }
    }
   return  set;
   }
    
//�ж�һ�������Ƿ�������Ѿ����ɵļ�����
  int  find(int *parent,int from,int to)
 {
      int  i,k;
      for(i=from;parent[i]>=0;i=parent[i])
      ;
      for(k=to;parent[k]>=0;k=parent[k])
      ;
      return i==k?1:0;
  }
//����Ĺ鲢����
  void  union_v(int *parent,int from,int to)
 {
      int i,k;
      if(parent[from]<0 && parent[to]<0)
     {
          if(from>to)
             parent[from]=to;
          else
             parent[to]=from;
      }
      else 
     {
          if(parent[from]>=0 && parent[to]>=0)
         {
               for(i=from;parent[i]>=0;i=parent[i])
               ;
               for(k=to;parent[k]>=0;k=parent[k])
               ;
               if(i>k)
                   parent[i]=k;
               else
                   parent[k]=i;
          }
          else
         {
               if(parent[from]>=0)
              {
                   for(i=from;parent[i]>=0;i=parent[i])
                   ;
                   if(i>to)
                       parent[i]=to;
                   else
                       parent[to]=i;
               }
               else
              {
                   for(i=to;parent[i]>=0;i=parent[i])
                   ;
                   if(i>from)
                       parent[i]=from;
                   else
                       parent[from]=i;
               }
           }
      }
  }
//������
   int  main(int  argc,char  *argv[])
  {
       GraphInfo    *info;
       SortedQueue  *queue,*tmp;
       SpanTree     *sptr;
       Graph        *graph;
       Post         *post,*rp;
       int          i;
 
       printf("��ʼ�����ڽӾ������ʽ�洢!\n");
       info=CreateGraphInfo((int *)mat,ROW_SIZE);

       printf("�����������!\n");
       queue=CreateSortedQueue(info);
        
       printf("��ʼ������С������!\n");
       sptr=CreateSpanningTree(queue,info->len);
//��ʼö��ͼ�нڵ�ı�
       printf("���������ɵĽ��:\n");
       queue=sptr->spant;
       if(!queue)
           printf("���ɵ���Ϊ��!\n");
       while(queue)
      {
           printf("%d--->%d :%4d\n",queue->from,queue->to,queue->data);
           tmp=queue;
           queue=queue->next;
           free(tmp);
       }

       graph=info->front;
       for(i=0;i<ROW_SIZE;++i,++graph)
      {
           post=graph->front;
           while(post)
          {
              rp=post;
              post=post->next;
              free(rp);
           }
       }
       free(info->front);
       free(info);
   
      return 0;
  }