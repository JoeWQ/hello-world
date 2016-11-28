//2012/12/16/14:28
//AOV网的拓扑排序
  #include<stdio.h>
  #include<stdlib.h>

  typedef  struct  _PostGraph
 {
       int      vertex;
       int      vp;
       struct   _PostGraph   *next;
  }PostGraph;
//*********************************************
  typedef  struct  _Graph
 {
//记录这个节点的入度
       int                   count;
       struct  _PostGraph   *link;
  }Graph;
  typedef  struct  _GraphInfo
 {
       int                size;
       struct  _Graph    *graph;
  }GraphInfo; 
//***********************************************/
  void  CreateDirectedGraph(GraphInfo *,int (*p)[10],int );
  void  CreateMatrix(int (*p)[10],int *);
//对途中的结点进行网络拓扑排序
  int  toplogic_sort(GraphInfo *,int *);
  
  static  int  matrix[10][10];
  static  int  vbuf[32];
  
  void  CreateMatrix(int (*matx)[10],int *size)
 {
       int  i,j,n;
       do
      {
             n=-1;
             printf("请输入邻接矩阵的实际行的数目\n");
             scanf("%d",&n);
       }while(n<2 || n>10);
       *size=n;

       for(i=0;i<n;++i)
          for(j=0;j<n;++j)
              matx[i][j]=0;

       printf("请输入有向图的节点的前驱和后继关系,-1 -1表示退出:\n");
       
       do
      {
            i=-1,j=-1;
            printf("请输入前驱节点和后继节点:\n");
            scanf("%d %d",&i,&j); 
            if(i==-1 && j==-1)
                break; 
            if(i<0 || j<0 || i>=n || j>=n)
           {
                 printf("非法的输入!\n"); 
                 continue;
            }
            printf(" %d and %d 建立连接\n",i,j);
            matx[i][j]=1;
       }while( 1 );
  }
//创建有向图的邻接表表示
  void  CreateDirectedGraph(GraphInfo *info,int (*matx)[10],int n)
 {
       Graph       *graph,*g;
       PostGraph   *pst;
       int         i,j;

       info->size=n;
       graph=(Graph *)malloc(sizeof(Graph)*n);
       g=graph;
       info->graph=graph;
//初始化
       for(i=0;i<n;++i,++graph)
      {
           graph->count=0;
           graph->link=NULL;
       }
       graph=g;
       for(i=0;i<n;++i,++graph)
      {
            for(j=0;j<n;++j)
           {
                 if(matx[i][j])
                {
                       pst=(PostGraph *)malloc(sizeof(PostGraph));
                       pst->vertex=j;
                       pst->vp=i;
//记录结点j的入度,为了保持算法的稳定性，使用倒叙式栈结构
                       ++g[j].count;
                       pst->next=graph->link;
                       graph->link=pst;
                 }
            }
       }
  }
//对有向图的节点的网络拓扑排序,若成功，则返回1，否则返回0
  int  toplogic_sort(GraphInfo *info,int *vbuf)
 {
       int     i,k,n;
       int     top;
       Graph   *graph;
       PostGraph   *pst=NULL;;
//注意，这个函数的设计思路优点复杂，理解起来可能优点困难，但是他是高效的
       top=-1;
       k=0;
       n=info->size;
       graph=info->graph;
//将入度为0的节点按count被访问的书序入栈
       for(i=0;i<n;++i,++graph)
      {
           if(!graph->count)
          {
                graph->count=top;
                top=i;
           }
       }
//
       graph=info->graph;
       for(i=0;i<n;++i)
      {
           if(top==-1)
          {
                printf("这个有向图中含有环，拓扑排序失败!\n");
                return 0;
          }
          else
         {
                vbuf[k++]=top;
                pst=graph[top].link;
                top=graph[top].count;
                for( ;pst ;pst=pst->next)
               {
                      --graph[pst->vertex].count;
                      if(!graph[pst->vertex].count)
                     {
                           graph[pst->vertex].count=top;
                           top=pst->vertex;
                      }
                }
          }
      }
      return 1;
  }
//****************************************************************
  int  main(int argc,char *argv[])
 {
      GraphInfo   ginfo,*info;
      PostGraph   *pst,*p;
      Graph       *graph;
      int         size,i;

      info=&ginfo;
      size=0;
      info->graph=NULL;
      info->size=0;

      printf("创建有向图的邻接矩阵表示..........\n");
      CreateMatrix(matrix,&size);
      printf("创建有向图的邻接表表示.....\n");
      CreateDirectedGraph(info,matrix,size);

      printf("现在计算图的拓扑排序...\n");
 
      if(!toplogic_sort(info,vbuf))
            printf("网络拓扑排序失败!\n");
      else
     {
            for(i=0;i<size;++i)
                printf("%d------>",vbuf[i]);
      }
      printf("\n现在开始释放内存...\n");
      graph=info->graph;
      for(i=0;i<size;++i,++graph)
     {
           pst=graph->link;
           while( pst )
          {
               p=pst;
               pst=pst->next;
               free(p); 
           }
     }
     free(info->graph);
     return 0;
  }
      