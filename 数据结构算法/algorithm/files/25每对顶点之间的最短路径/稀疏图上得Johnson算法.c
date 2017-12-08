//2013年3月5日10:17:18
//稀疏图上的Johnson算法,在底层我们使用最小堆实现
//该算法以 Dijkstra 和 Bellman-Ford算法为基础
  #include<stdio.h>
  #include<stdlib.h>
  #include"有关图的数据结构.h"

  #define   INF_T    0x30000000
  int    paths[10][10];
//创建图的邻接表表示
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j,weight;
       Graph       *graph;
       PostGraph   *pst;

       printf("请输入图的顶点数目(>1 && <10)!\n");
       do
      {
             size=1;
             printf("请输入符合要求的顶点数:\n");
             scanf("%d",&size);
       }while(size<=1 || size>10);
       h->size=size;
       graph=(Graph *)malloc(sizeof(Graph)*size);
       h->graph=graph;
       for(i=0;i<size;++i,++graph)
      {
             graph->count=0;
             graph->front=NULL;
       }
       graph=h->graph;
       printf("请输入顶点之间的关联 (-1 -1,-1)表示退出!\n");
       do
      {
             printf("请输入顶点与顶点之间的关联:\n");
             i=j=0;
             weight=0;
             scanf("%d %d %d",&i,&j,&weight);
             if(i==-1 && j==-1)
                  break;
             if(i<0 || i>=size || j<0 || j>=size)
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
             printf("%d----->%d:%d\n",i,j,weight);
       }while(i!=-1 && j!=-1);
  }
//通过对边重新赋予新的权值，确保所有的边均为非负值，然后运行迪杰斯特拉和 Bellman-Ford 算法
   static void  CreateOtherWeightGraph(GraphHeader  *h,GraphHeader  *gh)
  {
        int  size=h->size,i;
        PostGraph  *pst=NULL,*p;
        Graph   *graph=h->graph;
        Graph   *g,*tg;
      
        gh->size=size+1;
        g=(Graph *)malloc(sizeof(Graph)*(size+1));
        gh->graph=g;
//下面的代码是重新建立给定的图的另一种权值图/将新添加的顶点置于数组的末尾
        tg=g+size;
        tg->count=size;
        tg->front=NULL;

        for(i=0;i<size;++i)
       {
               pst=(PostGraph *)malloc(sizeof(PostGraph));
               pst->vertex=i;
               pst->vp=size;
               pst->weight=0;
               pst->next=tg->front;
               tg->front=pst;
        }
//开始进行复制操作
        for(i=0;i<size;++i,++graph,++g)
       {
               pst=graph->front;
               g->count=graph->count;
               g->front=NULL;
               while(  pst  )
              {
                     p=(PostGraph *)malloc(sizeof(PostGraph));
                     p->vertex=pst->vertex;
                     p->vp=pst->vp;
                     p->weight=pst->weight;
                     p->next=g->front;
                     g->front=p;

                     pst=pst->next;
               }
         }
  }
//Bellman-Ford算法
  static  int  bellman_ford(GraphHeader  *h,int *dstc,int  start)
 {
        int    i,j,lt,flag=1,size=h->size;
        int    **weight,*w;
        Graph  *gh=h->graph;
        PostGraph  *pst;

//        printf("444444444444444444444444\n");
        size=h->size;
//初始化各条路径的距离
        for(i=0;i<size;++i)
             dstc[i]=INF_T;
        dstc[start]=0;
//创建权值的二维存储矩阵
        weight=(int **)malloc(sizeof(int *)*size);
        for(i=0;i<size;++i)
       {
               w=(int *)malloc(sizeof(int)*size);
               weight[i]=w;
               for(j=0;j<size;++j,++w)
              {
                     *w=INF_T;
                     if(j==i)
                        *w=0;
               }
        }
//将权值写入这个矩阵    
        for(i=0;i<size;++i)
       {
               pst=gh[i].front;
               while( pst )
              {
                     w=weight[pst->vp];
                     w[pst->vertex]=pst->weight;
                     pst=pst->next;
               }
        }
//对所有的边进行松弛 (size-1)遍
        for(j=0;j<size-1;++j)
       {
             for(i=0;i<size;++i)
            {
                   pst=gh[i].front;
                   while(  pst  )
                  {
                         w=weight[pst->vp];
                         lt=w[pst->vertex];
                         if(dstc[pst->vertex]>dstc[pst->vp]+lt)
                                 dstc[pst->vertex]=dstc[pst->vp]+lt;
                          pst=pst->next;
                   }
              }
        }
//检测是否存在负权回路
        for(i=0;i<size;++i)
       {
              pst=gh[i].front;
              while( pst )
             {
                    w=weight[pst->vp];
                    lt=w[pst->vertex];
                    if(dstc[pst->vertex]>dstc[pst->vp]+lt)
                   {
                          flag=0;
                          goto label;
                    }
                    pst=pst->next;
              }
        }
    label:
//释放内存
        for(i=0;i<size;++i)
             free(weight[i]);
        free(weight);
//        printf("55555555555555555555555555555555555\n");
        return flag;
  }
//Dijkstra算法
   static  void  dijkstra_shortest_path(GraphHeader  *h,int  *distc,int start)
  {
         int   *tag,size;
         int   i,j,k,min;
         Graph  *graph=h->graph;
         PostGraph  *pst;

         size=h->size;
         tag=(int *)malloc(sizeof(int)*size);
         for(i=0;i<size;++i)
        {
              tag[i]=0;
              distc[i]=INF_T;
         }
         for(pst=graph[start].front; pst ;pst=pst->next)
               distc[pst->vertex]=pst->weight;
         distc[start]=0;

         for(i=0;i<size-1;++i)
        {
//寻找最小距离
               min=INF_T;
               k=0;
               for(j=0;j<size;++j)
              {
                     if(!tag[j] &&   min>=distc[j])
                    {
                            min=distc[j];
                            k=j;
                     }
               }
//找到后做上标记,并对定点k的边进行松弛操作
               tag[k]=1;
               for(pst=graph[k].front; pst ; pst=pst->next)
              {
                      min=distc[k]+pst->weight;
                      if(distc[pst->vertex]>min)
                              distc[pst->vertex]=min;
               }
         }
         free(tag);
  }
//Johnson算法，它是以上各个算法的综合运用
  void  johnson_all_pairs_shortest_paths(GraphHeader  *h,int  (*path)[10])
 {
         int    i,j,k,size;
         int    *distc,*dt;
         Graph  *graph;
         PostGraph  *pst,*p;
         GraphHeader  hGraph,*gh=&hGraph;

         gh->size=0;
         gh->graph=NULL;
//检测输入的图中是否有负权值存在
         graph=h->graph;
         size=h->size;
         k=0;
         distc=(int *)malloc(sizeof(int)*(size+1));
         for(i=0;i<size;++i)
        {
               pst=graph[i].front;
               while( pst )
              {
                      if(pst->weight<0)
                     {
                            k=1;
                            goto label;
                      }
                      pst=pst->next;
               }
          }
    label:
//          printf("\n11111111111111111111111111\n");
//如果有负权值存在，就进行创建额外的图的算法
          if(  k  )
         {
//创建新的图
                 CreateOtherWeightGraph(h,gh);
                 printf("gh->size:%d\n",gh->size);
                 if(!bellman_ford(gh,distc,size))
                {
                         printf("这个图中包含负权值的回路!\n");
//下面的步骤是释放原来所占据的内存
                         for(i=0;i<gh->size;++i)
                        {
                                pst=gh->graph[i].front;
                                while( pst )
                               {
                                       p=pst;
                                       pst=pst->next;
                                       free(p);
                                }
                          }
                         free(gh->graph);
                 }
                 else
                {
//对所有的边进行重新赋予新的权值
                         for(i=0;i<size;++i)
                              printf("%d--->%d\n",i,distc[i]);
                            
                         graph=gh->graph;
                         size=gh->size;
                         for(i=0;i<size;++i)
                        {
                                pst=graph[i].front;
                                while(  pst  )
                               {
//注意下面的这一步，它很重要，这一步保证了所有的边的权值都为正数
                                       pst->weight+=(distc[pst->vp]-distc[pst->vertex]);
                                       pst=pst->next;
                                }
                          }
//对于以上生成的新的权值图，对其中 的每个定点分别作用 Dijkstra算法
                          dt=(int *)malloc(sizeof(int)*size);
                          for(i=0;i<size;++i)
                         {
                                dijkstra_shortest_path(gh,dt,i);
                                for(j=0;j<size;++j)
                                      path[i][j]=dt[j]+distc[j]-distc[i];
                          }
//下面的步骤是释放原来所占据的内存
                         for(i=0;i<gh->size;++i)
                        {
                                pst=gh->graph[i].front;
                                while( pst )
                               {
                                       p=pst;
                                       pst=pst->next;
                                       free(p);
                                }
                          }
                         free(gh->graph);
                         free(dt);
                  }
       }
       else
      {
//对原来的图上的每个定点作用迪杰斯特拉算法
                  for(i=0;i<size;++i)
                 {
                         dijkstra_shortest_path(h,distc,i);
                         dt=path[i];
                         for(j=0;j<size;++j)
                              dt[j]=distc[j];
                  }
       }
       free(distc);
  }
//***********************************************************
  int  main(int argc,char *argv[]) 
 {
       int  i,j,k;
       PostGraph   *pst,*p;
       GraphHeader  hGraph,*h=&hGraph;
       CreateGraph(h);

       printf("\n*****************开始计算最短路径*****************\n");
       johnson_all_pairs_shortest_paths(h,paths);
       printf("\n计算完毕!\n");
       printf("\n");
       k=h->size;
       for(i=0;i<k;++i)
      {
              for(j=0;j<k;++j)
                    printf("%d      ",paths[i][j]);
              printf("\n");
       }
//释放已经申请的内存     
       for(i=0;i<h->size;++i)
      {
              pst=h->graph[i].front;
              while( pst )
             {
                   p=pst;
                   pst=p->next;
                   free(p);
              }
        }
        return 0;
  }      