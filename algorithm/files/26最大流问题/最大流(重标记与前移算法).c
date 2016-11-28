//2013年4月13日11:19:38
//重标记与前移算法实现,算法的基础仍然是压入和重标记
  #include<stdio.h>
  #include<stdlib.h>
  #include"有关图的数据结构.h"
  #include"动态双端队列.c"
//
//创建图的邻接表表示,它的邻接矩阵表示是一个实对称矩阵
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;
       PostVertex  *adj;

       printf("请输入图的顶点数目(>1 && <12)!\n");
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
             graph->adj=NULL;
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
//后继节点 用在图的拓扑排序函数里面,不参与标记前移算法的实现
             adj=(PostVertex *)malloc(sizeof(PostVertex));
             adj->vertex=j;
             adj->next=graph[i].adj;
             graph[i].adj=adj;
//前驱节点
             adj=(PostVertex *)malloc(sizeof(PostVertex));
             adj->vertex=i;
             adj->next=graph[j].adj;
             graph[j].adj=adj;

             printf("%d----->%d : %d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
//压入操作/调用的前提条件是，e[u]>0 && c[u][v]-f[u][v]>0
  static  void  push(int u,int v,int  *e,int (*c)[12],int (*f)[12])
 {
       int  min=c[u][v]-f[u][v];

       min=min<e[u]?min:e[u];
       f[u][v]+=min;
       f[v][u]=-f[u][v];
       e[u]-=min;
       e[v]+=min;
  }
//标记操作
//调用的前提条件e[u]>0
  static  void  relabel(Graph *graph,int u,int *height,int (*c)[12],int (*f)[12])
 {
       PostVertex  *p,*q;
       
       p=graph[u].adj;
       q=NULL;
//查找具有最小高度且满足条件的顶点
       while( p )
      {
             if(c[u][p->vertex]>f[u][p->vertex])
            {
                   if(!q || height[p->vertex]<height[q->vertex])
                         q=p;
             }
             p=p->next;
       }
       if(q && height[u]<=height[q->vertex])
             height[u]=height[q->vertex]+1;
  }
//排除操作/注意，输入的最大流所用的图，必须是强连通的，否则，这个循环将不会结束
  static  void  discharge(Graph *graph,int  u,int *height,int *e,int (*c)[12],int (*f)[12])
 {
        PostVertex  *p=graph[u].adj;
        while( e[u]>0 )
       {
//此时，没有满足条件 cf[u][v]>0 && h[u]=h[p->vertex]+1的结点
                if( ! p )
               {
                       relabel(graph,u,height,c,f);
                       p=graph[u].adj;
                }
                else if(c[u][p->vertex]>f[u][p->vertex] && height[u]==height[p->vertex]+1)
                       push(u,p->vertex,e,c,f);
                else
                      p=p->next;
        }
  }
//对数据进行初始化操作
  static  void  init_preflow(GraphHeader  *h,int src,int *height,int *e,int(*c)[12],
                              int  (*f)[12])
  {
         int         i,k;
         PostGraph   *p;
         Graph       *graph=h->graph;
//初始化数据
         for(i=0;i<h->size;++i)
        {
               height[i]=0;
               e[i]=0;
         }
         height[src]=h->size;
//对所有的边(u,v),进行全职矩阵清零操作
         for(i=0;i<h->size;++i)
        {
               p=graph[i].front;
               while( p )
              {
                     k=p->vertex;
                     f[i][k]=0; 
                     f[k][i]=0;
                     p=p->next;
               }
         }
         p=graph[src].front;
         while( p )
        {
               k=p->vertex;
               i=p->weight;
               f[src][k]=i;
               f[k][src]=-i;
               e[k]=i;
               e[src]-=i;
               p=p->next;
         }
  }
//对所有的顶点进行拓扑排序(使用广度优先搜索)
  static  void  toplog_sort(GraphHeader *h,QueueHeader *hq,int  src,int dst)
 {
         int        i,size;
         PostGraph  *p,*q;
         Graph      *graph=h->graph;
//使用复合队列(因为如果再次建立队列的数据结果，那么他跟已经建立的将发生冲突)
         QueueHeader  hQueue,*queue=&hQueue;
 
         size=h->size;
//首先将所有的顶点标记为 未访问状态
         for(i=0;i<size;++i)
               graph[i].v=0;
//下面使用广度优先搜索对所有的顶点进行排序
         queue->front=NULL;
         queue->rear=NULL;

         hq->front=NULL;
         hq->rear=NULL;
//先将src的后记顶点压入栈中,并将他们添加到拓扑排序 的目标队列中
//因为队列不是为了指针类型而设计的，所以必须使用强制类型转换
//源点和汇点不能添加进队列
         graph[src].v=1;
         graph[dst].v=1;
         p=graph[src].front;
         while( p )
        {
               graph[p->vertex].v=1;
               addElemq(hq,p->vertex); //注意要区分不同的队列
               addElemq(queue,(int)p);
               p=p->next;
         }
//开始进入查找目标顶点循环
         while( ! IsQueueEmpty(queue) )
        {
//下面的一句代码不可少
               q=(PostGraph *)removeTopq(queue);
               p=graph[q->vertex].front;
               while( p )
              {
                     if(!graph[p->vertex].v)
                    {
                           graph[p->vertex].v=1;
                           addElemq(queue,(int)p);
                           addElemq(hq,p->vertex);
                     }
                     p=p->next;
               }
         }
  }
//标记与前移算法的具体实现
  void  relabel_to_front(GraphHeader  *h,int src,int dst,int (*c)[12],int (*f)[12])
 {
         int          *height,*e;
         int          oldheight,u,size;
         QueueHeader  hQueue,*hq=&hQueue;
         Queue        *q,*t;
         Graph        *graph;

         size=h->size;
         graph=h->graph;
//初始化队列
         hq->front=NULL;
         hq->rear=NULL;
//申请动态内存
         height=(int *)malloc(sizeof(int)*size);
         e=(int *)malloc(sizeof(int)*size);
//初始化数据
         init_preflow(h,src,height,e,c,f);
         toplog_sort(h,hq,src,dst);
//查看队列中的元素
         q=hq->front;
         while( q )
        {
                 printf("----%d  ,",q->vertex);
                 q=q->next;
         }
//下一步进入 循环迭代
         q=hq->front;
         while( q )
        {
               u=q->vertex;
               oldheight=height[u];
               discharge(graph,u,height,e,c,f);
               if(oldheight<height[u])
                     moveToHead(hq,q);
               q=q->next;
          }
//输出数组 e 中元素的值
          printf("数组 e 中的值为:\n");
         for(u=0;u<size;++u)
               printf("e[%d]---->%d\n",u,e[u]);
         printf("\n***********************************\n");
         printf("\nheight数组中的值:\n");
         for(u=0;u<size;++u)
               printf("height[%d]----->%d\n",u,height[u]);
         free(e);
         free(height);
//释放队列中的结点
         for(q=hq->front; q ;  )
        {
               t=q;
               q=q->next;
               free(t);
         }
  }

//测试代码
  int  main(int  argc,char *argv[])
 {
       GraphHeader  hGraph,*h=&hGraph;
       PostGraph    *p;
       int          c[12][12],f[12][12];
       int          i,k;
/*
//先测试顶点的拓扑排序
       QueueHeader   hQueue,*hq=&hQueue;
       Queue         *q;
//
       hq->front=NULL;
       hq->rear=NULL;
*/
       printf("创建图的邻接表实现!\n");
       h->size=0;
       h->graph=NULL;
       CreateGraph(h);
/*
       printf("输出点的拓扑排序结果:\n");
       toplog_sort(h,hq,0,h->size-1);
       for(q=hq->front; q ;q=q->next)
              printf(" %d  ",q->vertex);
       printf("\n");
*/

       printf("初始化图的邻接矩阵:\n");
//下面的代码是无关的，只是为了最后一步的 结果输出
       for(i=0;i<h->size;++i)
            for(k=0;k<h->size;++k)
                   c[i][k]=f[i][k]=0;
       for(i=0;i<h->size;++i)
      {
              p=h->graph[i].front;
              while( p )
             {
                      c[i][p->vertex]=p->weight;
                      p=p->next;
              }
       }
//
       printf("调用标记与前移函数:\n");
       relabel_to_front(h,0,h->size-1,c,f);
       printf("\n输出在该函数中生成的数据:\n");
       for(i=0;i<h->size;++i)
      {
             for(k=0;k<h->size;++k)
                   printf("%4d ",f[i][k]);
             printf("\n");
       }
       return 0;
  }