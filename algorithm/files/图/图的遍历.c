//遍历图,图采用邻接矩阵和邻接表存储
  #include<stdio.h>
  #include<stdlib.h>
  #define  ROW_SIZE  7
  #define  _IDATA     '0'

//记录其后继节点的索引结构  
  typedef  struct  _Post
 {
     int  index;
     struct  _Post  *next;
  }Post;

  typedef  struct  _Graph
 {
     int  data;
     int  len;
     struct  _Post  *rear;
     struct  _Post  *front;
  }Graph;
//记录关于整个数据结构的信息
  typedef  struct  _GraphInfo
 {
     int    len;
     struct  _Graph  *front;
  }GraphInfo;

//**************************************************
  int  graph[7][7]={{0,1,1,0,0,0,0},
             {1,0,0,1,1,0,0},
             {1,0,0,0,0,1,1},
             {0,1,0,0,0,0,0},
             {0,1,0,0,0,0,0},
             {0,0,1,0,0,0,0},
             {0,0,1,0,0,0,0}};

  GraphInfo  *CreateGraphInfo(int *,int,int);
  void       VisitGraph(GraphInfo  *);
  void       releaseGraph(GraphInfo  *);
//创建和图相关的信息以及图的邻接表表示
  GraphInfo  *CreateGraphInfo(int *agraph,int row,int idata)
 {
      GraphInfo  *info;
      Graph      *gh;
      Post       *post;
      int        *tmp;
      int        i,k,size;
      info=(GraphInfo *)malloc(sizeof(GraphInfo));
      info->len=row;
      info->front=(Graph *)malloc(sizeof(Graph)*row);    
      size=row*row;

      for(i=0,tmp=agraph;i<row;++i)
     {
          gh=&info->front[i];

          gh->data=idata++;
          gh->len=0;
          gh->rear=NULL;
          gh->front=NULL;      
          for(k=0;k<row;++k,++tmp)
         {
              if(*tmp)
             {
                  post=(Post *)malloc(sizeof(Post));
                  post->index=k;
                  post->next=NULL;
                  if(gh->len)
                 {
                     gh->rear->next=post;
                     gh->rear=post;
                  }
                  else
                 {
                     gh->front=post;
                     gh->rear=post;
                  }
                 ++gh->len;
              }
           }
       }
      return  info;
  }
//遍历邻接表表示的图,一般来说采用递归法访问更简单，但是烤炉到效率和通用性
//我们不采用那种方法
  void  VisitGraph(GraphInfo  *info)
 {
      Post   *post;
      Graph  *graph;
      int    *visited;
      int   i;
      
      visited=(int *)malloc(sizeof(int)*info->len);
//初始清零
      for(i=0;i<info->len;++i)
          visited[i]=0;
 
      graph=info->front;
      for(i=0;i<info->len;++i)
     {
//如果该节点已经被访问过，那么就从下一个循环开始
          if(visited[i])
              continue;
          visited[i]=1;
          post=graph[i].front;
          printf("从节点%c 开始访问,依次为:",graph[i].data);
          while(post)
         {
              if(!visited[post->index])
			  {
				  visited[post->index]=1;
                  printf("%c ",graph[post->index].data);
			  }
              post=post->next;

          }
          putchar('\n');
      }
      free(visited);
  }
//释放所有动态申请的空间
  void  releaseGraph(GraphInfo  *info)
 {
      Graph  *graph;
      Post   *post,*tmp;
      int    i=0;
      for(graph=info->front;i<info->len;++i)
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
      printf("已经成功地释放掉所有的空间\n");
  }
  int main(int argc,char  *argv[])
 {
      GraphInfo  *info=CreateGraphInfo((int *)graph,ROW_SIZE,_IDATA);
      printf("现在开始遍历给定的图的轨迹!\n");
      VisitGraph(info);
      printf("开始释放所有的已经申请的空间!\n");
      releaseGraph(info);
      info=NULL;
      return  0;
  }