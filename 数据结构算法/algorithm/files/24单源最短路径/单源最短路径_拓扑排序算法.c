//2013年1月26日15:16:48
//单源最短路径算法，这里对条件进行了加强，即不允许出现回路、但是允许出现负权边
  #include<stdio.h>
  #include<stdlib.h>
  #include"有关图的数据结构.h"
  #define  INT_F    0x3FFFFFFF
/***************************************/
//创建图的邻接表表示,注意它是一个有向图
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
             if(i==j || i<0 || i>=size || j<0 || j>=size)// || weight<0)
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
             ++graph[j].count;
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
/******************对图中的顶点进行拓扑排序**************/
//如果这个图存在环，则返回0，否则返回1
  static int  toplogical_sort(GraphHeader   *h,int  *toplog)
 {
       int     i,k,top;
       Graph   *graph=h->graph;
       PostGraph   *pst;
//开始建立初步的栈结构
       top=-1;
       for(i=0;i<h->size;++i)
      {
             if(!graph[i].count)
            {
                    graph[i].count=top;
                    top=i;
             }
       }
//开始进行排序
       k=0;
       for(i=0;i<h->size;++i)
      {
             if(top==-1)
                 return 0;
             toplog[k++]=top;
             pst=graph[top].front;
             top=graph[top].count;
             for(  ; pst ;pst=pst->next)
            {
                    --graph[pst->vertex].count;
//当摸个顶点的入度为0的时候，就可以将它入栈
                    if(!graph[pst->vertex].count)
                   {
                           graph[pst->vertex].count=top;
                           top=pst->vertex;
                    }
             }
       }
       return 1;
  }
//计算单源最短路径
  int  dag_shortest_path(GraphHeader  *h,int  *parent,int *d,int start)
 {
       int          i,k;
       int          *toplog;
       Graph        *graph=h->graph;
       PostGraph    *pst;
       
//检查图中是否存在环
       toplog=(int *)malloc(sizeof(int)*h->size);
       if(!toplogical_sort(h,toplog))
      {
            free(toplog);
            return 0;
       }
//对数据进行初始化
       for(i=0;i<h->size;++i)
      {
              parent[i]=-1;
              d[i]=INT_F;
       }
       d[start]=0;
//开始计算最短路径
       for(i=0;i<h->size;++i)
      {
              k=toplog[i];
//下面是对所有的边的松弛操作
              for(pst=graph[k].front; pst ;pst=pst->next)
             {
                      if(d[pst->vertex]>d[pst->vp]+pst->weight)
                     {
                              d[pst->vertex]=d[pst->vp]+pst->weight;
                              parent[pst->vertex]=pst->vp;
                      }
              }
       }
       free(toplog);
       return 1;
  }
// 
  int  main(int  argc,char *argv[])
 {
       GraphHeader  hGraph,*h=&hGraph;
       int          *parent,*d;
       int          i,k,start=0;
     
       printf("创建图的邻接表表示..........\n");
       CreateGraph(h);
       printf("计算图的单源最短路径.......\n");

       parent=(int *)malloc(sizeof(int)*h->size);
       d=(int *)malloc(sizeof(int)*h->size);
       if(!dag_shortest_path(h,parent,d,start))
	   {
		   printf("这个图存在环，不满足求最短路径的条件!\n");
		   return 1;
	   }
       
       printf("\n****************输出计算的结果****************\n");
       for(i=0;i<h->size;++i)
      {
             printf("\n----------------------------------------\n");
             printf("%d----->%d : %d  \n",start,i,d[i]);
             
             k=i;
             do
            {
                    printf(" %d ",k);
                    k=parent[k];
             }while(k!=-1);
       }
       free(parent);
       free(d);
       return 0;
  }