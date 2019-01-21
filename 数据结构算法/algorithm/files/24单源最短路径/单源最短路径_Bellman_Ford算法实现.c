//2013年1月26日9:48:10
//计算图的 单源最短路径 Bellman_Ford算法实现
  #include<stdio.h>
  #include<stdlib.h>
/**************************************************/
  #include"有关图的数据结构.h"
//定义无穷大
  #define  INT_F    0x3FFFFFFF
//创建图的邻接表表示
 void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("请输入图的顶点数目(>1 && <17)!\n");
       do
      {
             size=1;
             printf("请输入符合要求的顶点数:\n");
             scanf("%d",&size);
       }while(size<=1 || size>16);
       h->size=size;
       graph=(Graph *)malloc(sizeof(Graph)*size);
       h->graph=graph;
       for(i=0;i<size;++i,++graph)
      {
             graph->count=0;
             graph->v=0;
             graph->finish=0;
             graph->front=NULL;
       }
       graph=h->graph;
       printf("请输入顶点之间的关联 (-1 -1)表示退出!\n");
       do
      {
             printf("请输入顶点与顶点之间的关联:\n");
             i=j=0;
             weight=-1;
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                  break;
             if(i==j || i<0 || i>=size || j<0 || j>=size )//|| weight<0)
            {
                    printf("非法的输入!\n");
                    continue;
             }
             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=j;
             pst->vp=i;
             pst->weight=weight;
             pst->next=graph[i].front;
             graph[i].front=pst;
             ++graph[i].count;
/*
             pst=(PostGraph *)malloc(sizeof(PostGraph));
             pst->vertex=i;
             pst->vp=j;
             pst->weight=weight;
             pst->next=graph[j].front;
             graph[j].front=pst;
*/

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
//Bellman_Ford算法实现/计算从顶点start到各个顶点的最短距离，以及最短路径
//parent记录的是 s->v的完整路径,d记录的是s到相应顶点v的距离,如果这个图中存在负权回路，则返回0,否则返回1
  int  bellman_ford_shortest_path(GraphHeader  *h,int  *parent,int *d,int  start)
 {
       int          i,k,size=h->size;
       int          len;
       Graph        *graph=h->graph;
       PostGraph    *pst;
//进行数据的初始化操作
       for(i=0;i<size;++i)
      {
              d[i]=INT_F;
              parent[i]=-1;
       }
       d[start]=0;
       len=size-1;
//对所有的边，进行松弛操作size遍
       for(i=0;i<len;++i)
      {
             for(k=0;k<size;++k)
            {
                   pst=graph[k].front;
                   for(  ; pst ;pst=pst->next)
                  {
                           if(d[pst->vertex]>d[pst->vp]+pst->weight)
                          {
                                  d[pst->vertex]=d[pst->vp]+pst->weight;
                                  parent[pst->vertex]=pst->vp;
                           }
                   }
            }
       }
//检测是否有负权回路
      for(i=0;i<size;++i)
     {
            for(pst=graph[i].front; pst ;pst=pst->next)
           {
                         if(d[pst->vertex]>d[pst->vp]+pst->weight)
                                return 0;
            }
      }
      return 1;
  }
/***********************************************************/
  int  main(int  argc,char *argv[])
 {
      GraphHeader  hGraph,*h=&hGraph;
      int          *parent,*d;
      int          i,j;

      printf("创建图的邻接表表示..........\n");
      CreateGraph(h);
      printf("\n计算生成的图的单源最短路径.........\n");
      parent=(int *)malloc(sizeof(int)*h->size);
      d=(int *)malloc(sizeof(int)*h->size);

      if(!bellman_ford_shortest_path(h,parent,d,0))
	  {
		  printf("这个图中存在负权回路!\n");
		  return 1;
	  }
//以下是输出计算出的结果
      for(i=0;i<h->size;++i)
     {
           printf("\n-------------------------------------------------\n");
           printf("顶点0----->%d 的路径长度为%d\n",i,d[i]);
           printf("路径:");
           j=i;
           do
          {
                printf("  %d   ",j);
                j=parent[j];
           }while(j!=-1);
      }
      free(parent);
      free(d);
      return 0;
  }