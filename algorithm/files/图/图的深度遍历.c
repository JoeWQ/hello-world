//������һ��������ͼ�Ĺؽڵ�
  #include<stdio.h>
  #include<stdlib.h>
//��������ؽڵ��еĸ������ݽṹ

//�洢��̽ڵ����������ݽṹ
  typedef  struct  _Post
 {
      int  index;
      struct  _Post  *next;
  }Post;
//�����ڽӱ���Ҫ�洢�Ĺ���ͼ�нڵ����Ϣ
  typedef  struct  _Graph
 {
      int  data;
      int  len;
      struct  _Post  *front;
      struct  _Post  *rear;
  }Graph;
//����ͼ�������Ϣ
  typedef  struct  _GraphInfo
 {
      int  len;
      struct  _Graph  *front;
  }GraphInfo;
//������еĽڵ���Ϣ
  typedef  struct  _Stack
 {
      struct  _Post   *post;
      struct  _Stack  *next;
  }Queue;
//���ڶ��е������Ϣ
  typedef  struct  _StackInfo
 {
      int  len;
      struct  _Queue  *front;
      struct  _Queue  *rear;
  }StackInfo;
//����һ����ά�ڽӾ��󣬴����;�����ص��ڽӱ�
  GraphInfo  *CreateGraphInfo(int *,int,int);
//�����������
  void       deep_first_visit(GraphInfo *);
//��������ڵ�lowֵ�ĺ���
  int        *low(GraphInfo  *,int);
//����ͼ�Ĺؽڵ�
  void       artic_point(GraphInfo  *);
//�ͷ�ͼ�ĸ����ڵ�
  void       releaseGraph(GraphInfo *);

  GraphInfo  *CreateGraphInfo(int  *mat,int  row,int  idata)
 {
      GraphInfo  *info;
      Graph      *graph;
      Post       *post;
      int        *tmp;
      int        i,k;
      
      info=(GraphInfo *)malloc(sizeof(GraphInfo));
      info->len=row;
      info->front=(Graph *)malloc(sizeof(Graph)*row);
      
      for(tmp=mat,i=0;i<row;++i)
     {
          graph=&info->front[i];
          graph->data=idata++;
          graph->len=0;
          graph->front=NULL;
          graph->rear=NULL;
          
          for(k=0;k<row;++k)
         {
              if(*tmp)
             {
                  post=(Post *)malloc(sizeof(Post));
                  post->index=k;
                  post->next=NULL;
                  if(graph->len)
                 {
                      graph->rear->next=post;
                      graph->rear=post;
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
       return  info;
  }
//��̬ջ�����Ԫ��
  void  addStack(StackInfo  *info,Post *post)
 {
      Stack  *item=(Stack *)malloc(sizeof(Stack));
      item->post=post;
      item->next=NULL;
      if(info->len)
     {
         item->next=info->front;
         info->front=item;
      }
      else
     {
         info->front=item;
         info->rear=item;
      }
      ++info->len;
  }
//�Ӷ�̬��ջ��ɾ��Ԫ��
  int  removeStack(StackInfo  *info)
 {
      int  index=-1;
      Stack  item;
      if(info->len)
     {
          item=info->front;
          info->front=item->next;
          --info->len;
          index=item->index;
          free(item);
      }
      return  index;
  }         
//�����������
  void  deep_first_visit(GraphInfo  *info,int  index)
 {
      int     *visited;
      Graph   *graph;
      Post    *post;
      StackInfo  *sinfo;
      int     i,tmp;
      
      visited=(int *)malloc(sizeof(int)*info->len);
      for(i=0;i<info->len;++i)
         visited[i]=0;
      graph=info->front;
      sinfo=(StackInfo *)malloc(sizeof(StackInfo));
      sinfo->len=0;
      sinfo->front=NULL;
      sinfo->rear=NULL;
      tmp=index;

      printf("��ʼ�ӵ�%d��Ԫ�ؽ�����ȷ���:\n",index);
      while(qinfo->len  ||  index!=-1)
     {
           if(!visited[index])
          {
               printf("��%d��Ԫ��Ϊ%c \n",index,graph[index].data);
               visited[index]=1;
               post=graph[index].front;
               while(post)
              {
                   addStack(sinfo,post);
                   post=post->next;
               }
           }
           index=removeStack(sinfo);
       }
      while(sinfo->len)
         removeStack(sinfo);
      free(sinfo);
      free(visited);
      printf("�ӵ�%d��������������!\n",tmp);
   }
//�ͷ�ͼ�еĽڵ�
  void  releaseGraph(GraphInfo  *info)
 {
       Graph  *graph;
       Post   *post,*tmp;
       int   i;
       graph=info->front;
       for(i=0;i<info->len;++i)
      {
          post=graph[i].front;
          while(post)
         {
              tmp=post;
              post=post->next;
              free(tmp);
          }
       }
       free(graph);
       free(info);
  } 