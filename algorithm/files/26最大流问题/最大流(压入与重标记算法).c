//2013年4月11日10:15:51
//最大流的压入与重标记算法实现
  #include<stdio.h>
  #include<stdlib.h>
  #include"为压入与标记算法而设计的队列.c"
  #include"有关图的数据结构.h"
  #define   MIN(a,b)   a<b?a:b
//建立动态二维数组的相关数据结构
  typedef  struct  _dl2array
 {
//记录二维数组的首地址
        int          **dlary;
//记录二维数组的行的数目
        int          row;
//记录二维数组的列的数目
        int          col;
  }dlarray;
//
//  static  int  height[16];
static void init_preflow(GraphHeader *,QueueHeader *,int,int (*c)[12],int (*f)[12],int  *,int*);
//创建图的邻接表表示,它的邻接矩阵表示是一个实对称矩阵
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("请输入图的顶点数目(>1 && <=12)!\n");
       do
      {
             size=1;
             printf("请输入符合要求的顶点数:\n");
             scanf("%d",&size);
       }while(size<=1 || size>12);
       h->size=size;
       graph=(Graph *)malloc(sizeof(Graph)*size);
       h->graph=graph;
       for(i=0;i<size;++i,++graph)
      {
             graph->count=0;
             graph->v=0;
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
             if(i==j || i<0 || i>=size || j<0 || j>=size || weight<0)
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

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
//压入算法
//参数c代表残留网络中，记录边(u,v)的权值矩阵
  static void  push(int  u,int  v,int(*c)[12],int (*f)[12],int  *e)
 {
         int    min;
//更新各个数据域中的数据
         min=c[u][v]-f[u][v];//先计算出残留流量 
         min=MIN(e[u],min);
         f[u][v]+=min;
         f[v][u]=-f[u][v];
         e[u]-=min;
         e[v]+=min;
  }
//重标记操作
//e记录着各个顶点的溢出流的值
//记录着各个顶点的高度
//调用的前提条件e[u]>0 && 对于u所有的后继结点v c[u][v]-f[u][v]>0 &&  height[u]<=height[v]
  static  int  relabel(GraphHeader  *h,int  u,int  *height,int (*c)[12],int (*f)[12])
 {
         PostGraph   *p,*q;
         p=h->graph[u].front;
         q=NULL;
         while( p )
        {
//如果残留值 大于0
               if(c[u][p->vertex]-f[u][p->vertex]>0)
              {

                     if(! q || height[p->vertex]<height[q->vertex])
                            q=p;
               }
//在u的后继顶点中，查找高度最小的顶点
               p=p->next;
         }
//防止u没有后继结点
         if( q && height[u]<=height[q->vertex])
        {
               height[u]=height[q->vertex]+1;
               return 1;
         }
         return 0;
  }
//压入与重标记算法   的结合
//src代表着源点
//dst代表着汇点
//dlc指向动态二维数组的头结构(代表着残留网络中变得权值矩阵)
//dlf代表着图中各个边的 前置流矩阵
  int  *push_relabel(GraphHeader  *h,int (*c)[12],int (*f)[12],int  src,int dst)
 {
         int     *height,*e;
         int     k,u;
         PostGraph    *p;
         Graph    *graph;
         QueueHeader  hqueue,*hq=&hqueue;

//先对所有的数据进行初始化
         height=(int *)malloc(sizeof(int)*h->size);
         e=(int *)malloc(sizeof(int)*h->size);
         initQueue(hq,h->size);
         graph=h->graph;
         init_preflow(h,hq,src,c,f,height,e);
//下面将进入压入与重标记操作的 循环操作中
         while( hq->size>0 )
        {
               u=removeQueue(hq);
               graph[u].v=0;
//检测对顶点 u 应该选用哪一种操作
               p=graph[u].front;
               while( p )
              {
                      k=p->vertex;
                      if(c[u][k]-f[u][k]>0 && height[u]==height[k]+1)
                     {
                           push(u,k,c,f,e);
                      
                           if(!graph[k].v && k!=src && k!=dst)
                          {
                                  addQueue(hq,k);
                                  graph[k].v=1;
                           }
                      }
                     p=p->next;
               }
//下面是重标记操作
               if(e[u]>0 && u!=src && u!=dst)
              {
//查找具有最小高度的 顶点
                     if( relabel(h,u,height,c,f) )
                    {
                          graph[u].v=1;
                          addQueue(hq,u);
                     }
//                     printf("^^^^^^^^^^^^^^\n");
                }
         }
         for(k=0;k<h->size;++k)
                printf("height[%d]--->%d\n",k,height[k]);
         return e;
   }
//对与压入与重标记算法 相关的数据进行初始化
   static  void  init_preflow(GraphHeader  *h,QueueHeader *hq,int src,int (*c)[12],int (*f)[12],
                               int  *height,int *e)
  {
         Graph  *graph=h->graph;
         PostGraph   *p;
         int    i,k;
         
         for(i=0;i<h->size;++i)
        {
                height[i]=0;
                e[i]=0;
                graph[i].v=0;
         }
         for(i=0;i<h->size;++i)
        {
                for(k=0;k<h->size;++k)
                      f[i][k]=0;
         }
//初始化和源点src项邻接的顶点，并更新前置流f
         height[src]=h->size;
         graph[src].v=1;
         p=graph[src].front;

         while( p )
        {
                k=p->vertex;
                e[k]=p->weight;
                e[src]-=p->weight;
                i=c[src][k];
                f[src][k]=i;
                f[k][src]=-i;
                graph[k].v=1;
                addQueue(hq,k);
                p=p->next;
         }
  }
//
  int  main(int  argc,char  *argv[])
 {
/*
//测试队列
         QueueHeader  hqueue,*h=&hqueue;
         int          length=16;
         int          i,k;
         initQueue(h,length);

         for(i=0;i<length;++i)
               addQueue(h,i);
         printf("输出队列!\n");
         while( h->size )
        {
               i=removeQueue(h);
               printf(" %d ",i);
         }
         return 0;
*/

         GraphHeader    hGraph,*h=&hGraph;
         PostGraph      *p;
         int            i,j,*e;
         int           c[12][12],f[12][12];
//创建动态数组
         printf("创建图的临街表表示:\n");
         CreateGraph(h);
         for(i=0;i<h->size;++i)
        {
            for(j=0;j<h->size;++j)
                      c[i][j]=0;
         }
         for(i=0;i<h->size;++i)
        {
                p=h->graph[i].front;
                while( p )
               {
                       c[i][p->vertex]=p->weight;
                       p=p->next;
                }
         }
         printf("执行压入与重标记算法.......\n");
         e=push_relabel(h,c,f,0,h->size-1);
//打印出执行结果
         for(i=0;i<h->size;++i)
        {
               for(j=0;j<h->size;++j)
                      printf("%4d ",f[i][j]);
               printf("\n");
         }
         printf("输出溢出顶点流:\n");
         for(i=0;i<h->size;++i)
               printf("%d----->%d\n",i,e[i]);
         printf("给定的图的最大流为: %d\n",e[h->size-1]);
         return 0;
  }