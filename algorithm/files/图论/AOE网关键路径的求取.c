//2012/12/17/14:33
//求取边活动网络的关键路径
//毛泽东，周恩来同志
  #include<stdio.h>
  #include<stdlib.h>
/*******************************************/
//数据结构的定义，这里不同于AOV网,因为它需要一个逆邻接表
  typedef  struct  _PostGraph
 {
         int                  vertex;
         int                  vp;
         int                  weight;
//计算关键路径时要用到的数据域
         struct   _PostGraph  *next;
  }PostGraph;
//图顶点的定义
  typedef  struct  _Graph
 {
//对邻接表顶点的出度进行计数
         int                 ocount;
//对邻接表顶点的入度进行计数
         int                 icount;
//指向后继顶点的链表指针
         struct  _PostGraph  *ofront;
//指向前驱顶点的链表指针
         struct  _PostGraph  *ifront;
  }Graph;
//记录和图的内容相关的信息头
  typedef  struct  _GraphHeader
 {
//记录图中所包含的顶点的数目
         int           size;
//指向图的指针
         struct  _Graph    *graph;
  }GraphHeader;
/***************************************************************/
  void  CreateMatrix(int (*p)[10],int *);
//同时创建邻接表和逆邻接表
  void  CreateRAdjGraph(GraphHeader *,int (*p)[10],int);
//计算关键路径
  int  artical_path(GraphHeader  *);
//内部方法,拓扑排序的变种,求取earliest数组的值
  static  int  modified_toplog_sort(GraphHeader *,int *,int *);
//拓扑排序的变种，求取latest数组的值
  static  int  modified_toplog_sort_r(GraphHeader *,int *,int);
//删除边的操作
  static  void  remove_edge(GraphHeader *,int,PostGraph *);
/*******************************************************************/
  static  int  matrix[10][10];
  void  CreateMatrix(int (*matx)[10],int *size)
 {
        int  i,j,n,weight;
        do
       { 
                n=-1;
                printf("请输入图的顶点数目(>=2 && <=10):\n");
                scanf("%d",&n);
        }while(n>=10 || n<2);
        
        *size=n;
        for(i=0;i<n;++i)
           for(j=0;j<n;++j)
                matx[i][j]=0;
        printf("请输入有向图的顶点和顶点之间的权值,-1 -1 -1  表示退出!\n");
        do
       {
              printf("请输入顶点与顶点之间的权值:\n");
              i=-1,j=-1,weight=-1;
              scanf("%d %d %d",&i,&j,&weight);
              if(i==-1 && j==-1)
                    break;
              if(i<0 || i>=n || j<0 || j>=n || i==j || weight<0)
             {
                     printf("非法的输入!\n");
                     continue;
              }
              printf("%d and %d -->%d\n",i,j,weight);
              matx[i][j]=weight;
        }while( 1 );
  }
//创建邻接和逆邻接邻接表
  void  CreateRAdjGraph(GraphHeader *h,int (*matx)[10],int n)
 {
       int  i,j;
       Graph  *graph,*rgraph;
       PostGraph   *pst;

       graph=(Graph *)malloc(sizeof(Graph)*n);
       h->graph=graph;
       h->size=n;
//初始化,邻接表的顶点数组
       for(i=0;i<n;++i,++graph)
      {
             graph->ocount=0;
             graph->icount=0;
             graph->ofront=NULL;
             graph->ifront=NULL;
       }
       graph=h->graph;
       rgraph=graph;
       for(i=0;i<n;++i,++graph)
      {
            for(j=0;j<n;++j)
           {
                 if(matx[i][j])
                {
//先创建邻接表
                       pst=(PostGraph *)malloc(sizeof(PostGraph));
                       pst->vertex=j;
                       pst->vp=i;
                       pst->weight=matx[i][j];
                       pst->next=graph->ofront;
                       graph->ofront=pst;
//增加顶点j的入度
                       ++rgraph[j].icount;
//增加顶点i的出度
                       ++graph->ocount;
//创建逆邻接表
                       pst=(PostGraph *)malloc(sizeof(PostGraph));
                       pst->vertex=i;
                       pst->vp=j;
                       pst->weight=matx[i][j];
                       pst->next=rgraph[j].ifront;
                       rgraph[j].ifront=pst;
                  }
             }
        }
  }
//计算关键路径,在计算的过程中，将会删除掉图h中的一些边
  int  artical_path(GraphHeader *h)
 {
         int      *earliest,*latest,*stack;
         int      i,j,n,early,late;
         Graph    *graph;
         PostGraph  *pst,*p;
         
         n=h->size;
         earliest=(int *)malloc(sizeof(int)*n); 
         latest=(int *)malloc(sizeof(int)*n);
         stack=(int *)malloc(sizeof(int)*n);
//先调用正拓扑排序，如果失败，则直接返回
         if(!modified_toplog_sort(h,earliest,stack))
                 return 0;
//检测是否有不可到达的顶点
         for(i=0,j=0;i<n;++i)
        {
               if(!earliest[i])
                   ++j;
         }
         if(j>1)
        {
               printf("图中有不可到达的顶点，求取关键路径失败!\n");
               return 0;
         }
         if(!modified_toplog_sort_r(h,latest,earliest[stack[n-1]]))//注意最后一个参数
                  return 0;
//下面开始求取关键路径
         graph=h->graph;
         for(i=0;i<n;++i)
        {
              j=stack[i];
              pst=graph[j].ofront;
              while( pst )
             {
//先计算边的early,late值，如果边的early和late的值不同，则从邻接表中删除这条边
                   early=earliest[j];
                   late=latest[pst->vertex]-pst->weight;
                   if(early!=late)
                  {
                        p=pst->next;
                        remove_edge(h,j,pst);
                        pst=p;
                   }
                   else
                        pst=pst->next;
              }
        }
//将逆邻接表所占据的内存释放掉
       for(i=0;i<n;++i)
      {
             pst=graph[i].ifront;
             while( pst )
            {
                 p=pst;
                 pst=pst->next;
                 free(p);
             }
       }
       free(stack);
       free(earliest);
       free(latest);
       return 1;
  }
//删除图的一条边
  static  void  remove_edge(GraphHeader *h,int v,PostGraph  *pst)
 {
       Graph  *graph=h->graph;
       PostGraph   *p,*q=NULL;
       
       p=graph[v].ofront;
       while(p && p->vertex!=pst->vertex)
      {
            q=p;
            p=p->next;
       }
       if(! q)
            graph[v].ofront=pst->next;
       else
            q->next=pst->next;
       free(pst);
  }
          
//拓扑排序的变种，求取early的值，若成功，则返回1 否则返回0（通常情况下是优于图存在环路)
  static  int  modified_toplog_sort(GraphHeader *h,int *early,int *stack)
 {
         int      i,j,top,k,m=0;
         int      n=h->size;
         Graph    *graph=h->graph;
         PostGraph   *pst;
        
         top=-1;
         for(i=0;i<n;++i)
        {
               if(!graph[i].icount)
              {
                    graph[i].icount=top;
                    top=i;
               }
               early[i]=0;
               stack[i]=0;
         }
//计算顶点的early值
         for(i=0;i<n;++i)
        {
               if(top==-1)
              {
                      printf("给定的图存在环，求关键路径失败!\n");
                      return 0;
               }
               else
              {
                      stack[m++]=top;
                      k=top;
                      pst=graph[top].ofront;
                      top=graph[top].icount;
                      for(    ;pst;pst=pst->next)
                     {
                           j=pst->vertex;
                           --graph[j].icount;
                           if(!graph[j].icount)
                          {
                                graph[j].icount=top;
                                top=j;
                           }
                           if(early[j]<early[k]+pst->weight)
                                   early[j]=early[k]+pst->weight;
                      }
               }
         }
/*
       printf("earliest的值:\n");
       for(i=0;i<n;++i)
      {
            printf("vertex:%d-->earliest:%d    \n",i,early[i]);
       }
*/
        return 1;
  }
//拓扑排序逆运算的变种，求取latest的值，若成功，则返回1，否则返回0,在调用这个函数的前已经假设，
//latest的最后一个值已经被初始化
  static  int  modified_toplog_sort_r(GraphHeader *h,int  *latest,int iv)
 {
       int  i,j,k,top;
       int  n=h->size;
       Graph   *graph=h->graph;
       PostGraph  *pst;

       top=-1;
       for(i=0;i<n;++i)
      {
            if(!graph[i].ocount)
           {
                  graph[i].ocount=top;
                  top=i;
            }
//注意这一步很重要
            latest[i]=iv;
       }
       if(top==-1)
      {
            printf("这个图存在环，计算错误!\n"); 
            return 0;
       }
//       printf("top:%d-->iv:%d....\n",top,iv);
//       latest[top]=iv;
       for(i=0;i<n;++i)
      {
            if(top==-1)
           {
                 printf("这个图存在环，调用失败!\n");
                 return 0;
            }
            else
           {
                 k=top;
                 pst=graph[top].ifront;
                 top=graph[top].ocount;
                 for(  ;pst ;pst=pst->next)
                {
                       j=pst->vertex;
                       --graph[j].ocount;
                       if(!graph[j].ocount)
                      {
                            graph[j].ocount=top;
                            top=j;
                       }
                       if(latest[j]>latest[k]-pst->weight)
                              latest[j]=latest[k]-pst->weight;
                }
            } 
       }
/*
       printf("latest值:\n");
       for(i=0;i<n;++i)
            printf("vertex:%d->latest:%d   \n",i,latest[i]);
*/
    return 1;
  }
//*****************************************************************
  int  main(int argc,char *argv[])
 {
       GraphHeader  hg,*h;
       int          i,size;
       PostGraph    *pst,*p;
       Graph        *graph;

       h=&hg;
       printf("创建邻接矩阵......\n");
       CreateMatrix(matrix,&size);
       
       printf("创建图的邻接表和逆邻接表表示....\n");
       CreateRAdjGraph(h,matrix,size);
   
       printf("计算图的关键路径....\n");
       if(!artical_path(h))
      {
            printf("计算失败...\n");
            return 1;
       }

       graph=h->graph;
       for(i=0;i<size;++i)
      {
             pst=graph[i].ofront;
             if(pst)
            {
                  printf("顶点%d-->",i);
                  while( pst )
                 {
                        printf(":->:(vertex:%d,weight:%d)",pst->vertex,pst->weight);
                        pst=pst->next;
                  }
                  printf("\n");
            }
      }
      printf("释放内存.....\n");
      for(i=0;i<size;++i)
     {
           pst=graph[i].ofront;
           while( pst )
          {
                p=pst;
                pst=pst->next;
                free(p );
           }
     }
     return 0;
  }