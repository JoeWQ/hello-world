//求任意一个给定的图的关节点
  #include<stdio.h>
  #include<stdlib.h>
//定义在求关节点中的各种数据结构

//存储后继节点索引的数据结构
  typedef  struct  _Post
 {
      int  index;
      struct  _Post  *next;
  }Post;
//采用邻接表所要存储的关于图中节点的信息
  typedef  struct  _Graph
 {
      int  data;
      int  len;
      struct  _Post  *front;
      struct  _Post  *rear;
  }Graph;
//定义图的相关信息
  typedef  struct  _GraphInfo
 {
      int  len;
      struct  _Graph  *front;
  }GraphInfo;
//定义队列的节点信息
  typedef  struct  _Stack
 {
      struct  _Post   *post;
      struct  _Stack  *next;
  }Queue;
//关于队列的相关信息
  typedef  struct  _StackInfo
 {
      int  len;
      struct  _Queue  *front;
      struct  _Queue  *rear;
  }StackInfo;
//给定一个二维邻接矩阵，创建和矩阵相关的邻接表
  GraphInfo  *CreateGraphInfo(int *,int,int);
//深度优先搜索
  void       deep_first_visit(GraphInfo *);
//计算各个节点low值的函数
  int        *low(GraphInfo  *,int);
//计算图的关节点
  void       artic_point(GraphInfo  *);
//释放图的各个节点
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
//向动态栈中添加元素
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
//从动态堆栈中删除元素
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
//深度优先搜索
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

      printf("开始从第%d个元素进行深度访问:\n",index);
      while(qinfo->len  ||  index!=-1)
     {
           if(!visited[index])
          {
               printf("第%d个元素为%c \n",index,graph[index].data);
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
      printf("从第%d深度优先搜索完毕!\n",tmp);
   }
//释放图中的节点
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