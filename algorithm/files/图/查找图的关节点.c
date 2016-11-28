//*查找图的关节点*,这里假设给定的图是单连通的
//一个失败的作品,注意
  #include<stdio.h>
  #include<stdlib.h>
  #define  ROW_SIZE  8
  #define  IDATA     '0'
  #define  I_START   7

  typedef  struct  _Post
 {
//记录下一个连接节点的索引
     int  index;
//记录连接此节点的索引
     int  preindex;
//为了便于进行删除操作,引入了prev指针
     struct  _Post  *prev;
     struct  _Post  *next;
  }Post;
//记录关于图节点的相关连接点信息
  typedef  struct  _Graph
 {
//此节点所包含的数据项
     short    data;
	 short    mark;
//和此节点相连接的节点数目
     int  len;
     struct  _Post  *front;
     struct  _Post  *rear;
  }Graph;
//关于所有节点的统计项
  typedef  struct  _GraphInfo
 {
     int  len;
     struct  _Graph  *front;
  }GraphInfo;
//在计算关节点时所要用到的栈结构的定义信息
  typedef  struct  _Stack
 {
     struct  _Post   *post;
     struct  _Stack  *next;
  }Stack;
//统计栈结构的所有信息
  typedef  struct  _StackInfo
 {
     int  len;
     int  unuse;
     struct  _Stack  *front;
     struct  _Stack  *rear;
  }StackInfo;
//定义全局数据
  int  len;
//  int  *visited;
  int  *dfsn;
  int  *low;
  int  *prenode;
  GraphInfo  *ginfo;
  int  index;
//图的邻接矩阵表示
  int mat_0[10][10]={{0,1,0,0,0,0,0,0,0,0},
                   {1,0,0,1,1,0,0,0,0,0},
                   {0,1,0,0,1,0,0,0,0,0},
                   {0,1,0,0,1,1,0,0,0,0},
                   {0,0,1,1,0,0,0,0,0,0},
                   {0,0,0,1,0,0,1,1,0,0},//5
                   {0,0,0,0,0,1,0,1,0,0},
                   {0,0,0,0,0,1,1,0,1,1},//7
                   {0,0,0,0,0,0,0,1,0,0},//8
                   {0,0,0,0,0,0,0,1,0,0}};
   int mat[8][8]={{0,1,1,0,0,0,0,0},
                  {1,0,1,1,0,0,0,0},
                  {1,0,0,0,0,1,1,0},//2
                  {0,1,0,0,0,0,0,1},//3
                  {0,1,0,0,0,0,0,1},
                  {0,0,1,0,0,0,0,1},//5
                  {0,0,1,0,0,0,0,1},
                  {0,0,0,1,1,1,1,0}};//7
                                    
  GraphInfo  *CreateGraphInfo(int *mat,int row,int idata);
  
  void  addStack(StackInfo *,Post *);
  
  Post  *removeStack(StackInfo *);
//判断根节点是否为关节点
  void  is_root_artic(GraphInfo  *,int);
//判断其他节点是否为关节点
  void  judge_node(GraphInfo  *,int);
//计算图的关节点
  void  dfsnlow(int ,int );
//根据给定的邻接矩阵，创建相应的邻接表
  GraphInfo  *CreateGraphInfo(int *mat,int row,int idata)
 {
      GraphInfo  *info;
      Graph      *graph;
      Post       *post;
      int        *tmp;
      int        i,k;
//初始化邻接矩阵图的相关信息
      info=(GraphInfo *)malloc(sizeof(GraphInfo));
      info->len=row;
      info->front=(Graph *)malloc(sizeof(Graph)*row);
      graph=info->front;

      for(i=0,tmp=mat;i<row;++i,++graph)
     {
          graph->len=0;
          graph->data=idata++;
		  graph->mark=0;
          graph->front=NULL;
          graph->rear=NULL;
          for(k=0;k<row;++k,++tmp)
         {
               if(*tmp)
              {
                  post=(Post *)malloc(sizeof(Post));
                  post->preindex=i;
                  post->prev=NULL;
                  post->next=NULL;
                  post->index=k;
                  if(graph->len)
                 {
                       graph->rear->next=post;
                       post->prev=graph->rear;
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
      for(graph=info->front,i=0;i<row;++i)
     {
          printf("第%d行节点的链接情况:\n",i);
          post=graph[i].front;
          while(post)
         {
              printf("%d ,",post->index);
              post=post->next;
          }
          putchar('\n');
      }
      printf(".........................................\n");
     return  info;
  }
//向栈中添加新的项(ˇ?ˇ） 想～
  void  addStack(StackInfo  *info,Post  *post)
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
//从栈中删除项
  Post  *removeStack(StackInfo  *info)
 {
      Post   *post=NULL;
      Stack  *item;
      if(info->len)
     {
          item=info->front;
          info->front=item->next;
          --info->len;
          post=item->post;
          free(item);
      }
      return post;
  }

//采用深度优先搜索,计算图中的所有关节点
  void  dfsnlow(int u,int v)
 {
       Post  *post;
       int    w;
       dfsn[u]=index;
       low[u]=index;
       ++index;
       for(post=ginfo->front[u].front;post;post=post->next)
      {
           w=post->index;
           if(dfsn[w]<0)
          {
                dfsnlow(w,u);
                low[u]=low[u]<low[w] ? low[u]:low[w];
           }
           else if(w!=v)
                low[u]=low[u]<dfsn[w]? low[u]:dfsn[w];
       }
       printf("节点%d的low值为%d,dfsn值为%d\n",u,low[u],dfsn[u]);
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
//*****************************************
  int main(int argc,char *argv[])
 {
       printf("初始化开始.....\n");
       ginfo=CreateGraphInfo((int *)mat,ROW_SIZE,IDATA);
       len=ROW_SIZE;
//       visited=(int *)malloc(sizeof(int)*ROW_SIZE);
       dfsn=(int *)malloc(sizeof(int)*ROW_SIZE);
       low=(int *)malloc(sizeof(int)*ROW_SIZE);
       prenode=(int *)malloc(sizeof(int)*ROW_SIZE);
    
       for(index=0;index<ROW_SIZE;++index)
      {
//           visited[index]=-1;
           dfsn[index]=-1;
           low[index]=-1;
           prenode[index]=-1;
       }
       index=0;
       printf("开始计算图的关节点...\n");
       dfsnlow(I_START,-1);
	   printf("--------------------------------------------------\n");
//判断根节点是否为关节点
       is_root_artic(ginfo,I_START);
//开始判断其他节点
       judge_node(ginfo,I_START);
       releaseGraph(ginfo);
//       free(visited);
       free(dfsn);
       free(low);
       free(prenode);
       return 0;
  }
//深度优先搜索,判断从节点索引index处是否能生成两棵以上的深度优先树
  void  is_root_artic(GraphInfo  *info,int  root_index)
 {
      int     *visited;
      Graph   *graph;
      Post    *post,*tmp;
      StackInfo  *sinfo;
      int     i,index=0,mark=0;
      
      visited=(int *)malloc(sizeof(int)*info->len);
      for(i=0;i<info->len;++i)
         visited[i]=0;
      graph=info->front;
      sinfo=(StackInfo *)malloc(sizeof(StackInfo));
      sinfo->len=0;
      sinfo->front=NULL;
      sinfo->rear=NULL;
 
      printf("开始从第%d个元素进行深度访问:\n",root_index);
	    if(graph[root_index].len<=1)
     {
          printf("..根节点%d不是一个关节点!\n",root_index);
		      return;
      }
//如果根节点右两个或者两个以上的后继节点，那么如果从每一个节点深度优先搜索出发都不能
//访问到根节点，那么这个根节点将使一个关节点
      for(tmp=graph[root_index].front;tmp;tmp=tmp->next)
     {
           addStack(sinfo,tmp);
           post=tmp->next;
           while(post)
          {
               if(post->index!=root_index && post->preindex!=root_index)
                   addStack(sinfo,post);
               post=post->next;
           }
           while(sinfo->len)
          {
               post=removeStack(sinfo); 
               if(!visited[post->index])
              {
                   visited[post->index]=1;
                   post=graph[post->index].front;
                   while(post)
                  {
                       if(!visited[post->index])
                           addStack(sinfo,post);
                       post=post->next;
                   }
               }
               else if(post->index==root_index)
              {
                   printf("根节点%d不是一个关节点\n",root_index);
                   return;
               }
          }
         for(i=0;i<info->len;++i)
             visited[i]=0;
         while(sinfo->len)
        {
             removeStack(sinfo);
         }
     }
     free(visited);
     printf("根节点%d是一个关节点!\n",root_index);
     printf("从第%d深度优先搜索完毕!\n",root_index);
   }
//判断其他节点是否为关节点
  void  judge_node(GraphInfo  *info,int root_index)
 {
      int    *visited;
      Graph  *graph;
      StackInfo  *sinfo;
      Post   *post;
      int    index,k;
 
      index=root_index;
      sinfo=(StackInfo *)malloc(sizeof(StackInfo));
      sinfo->len=0;
      sinfo->front=NULL;
      sinfo->rear=NULL;
      graph=info->front;
      visited=(int *)malloc(sizeof(int)*info->len);
      for(k=0;k<info->len;++k)
          visited[k]=0;
      visited[root_index]=1;

      post=graph[root_index].rear;
      while(post)
     {
          addStack(sinfo,post);
          post=post->prev;
      }
      while(sinfo->len)
     {
           post=removeStack(sinfo);
           if(post->preindex!=root_index && !visited[post->preindex] && low[post->index]>=dfsn[post->preindex])
		   {
                 printf("节点%d是一个关节点.\n",post->preindex);
				 graph[post->preindex].mark=1;
		    }
           else if(post->preindex!=root_index && visited[post->preindex] && !graph[post->preindex].mark && low[post->index]>=dfsn[post->preindex])
           {
                printf("节点%d是一个关节点.\n",post->preindex);
				graph[post->preindex].mark=1;
		   }  
            visited[post->preindex]=1;
		    if(!visited[post->index])
			{
				post=graph[post->index].front;
                while(post)
				{
				     if(!visited[post->index])
					 {
			//			 printf("加入节点%d前驱%d\n",post->index,post->preindex);
                         addStack(sinfo,post);
					 }
                     post=post->next;
				}
			}
      }
      free(visited);
      printf("所有的节点都判断完毕!\n");
  }
      