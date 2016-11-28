//2013/1/20/18:20
//深度优先搜索的变种、附带时间戳,.注意，这里主要针对的是有向图
  #include<stdio.h>
  #include<stdlib.h>
  #include"有关图的数据结构.h"
  #include"图的遍历_栈和队列.c"
//图的深度搜索
  static  void  deep_visit(GraphHeader *,int ,int *);
//求给定的邻接表的逆邻接表表示
  void  reverse_adj_list(GraphHeader  *h,GraphHeader  *rh);

  void  deep_visit_first(GraphHeader  *h)
 {
        int          i,j,time;
        Graph        *g;
//初始化数据结构,将图中的标示清除掉
       j=h->size;
       for(g=h->graph,i=0;i<j;++i,++g)
              g->v=0;
//全局时间戳
       time=0;
       for(g=h->graph,i=0;i<j;++g,++i)
      {
//如果还没有被访问，则开始对他进行深度搜索
            if(! g->v)
                 deep_visit(h,i,&time);
       }
  }
  static  void  deep_visit(GraphHeader *h,int  start,int *time)
 {
      Graph  *graph;
      PostGraph  *pst;
      StackHeader  hStack,*hsk=&hStack;
      int  *vertex,index,i,count=*time;
//初始化数据结构
      hsk->size=0;
      hsk->front=NULL;
      pst=NULL;
      graph=h->graph;

      vertex=(int *)malloc(sizeof(int)*h->size);
      index=0;
//开始进行深度搜索
      graph[start].v=1;
      ++count;
      pst=graph[start].front;
      vertex[index++]=start;
      while( pst )
     {
             if(! graph[pst->vertex].v)
            {
                  graph[pst->vertex].v=1;
                  push(hsk,pst);
             }
             pst=pst->next;
      }
//进入循环查找
      while( hsk->size )
     {
             ++count;
             pop(hsk,&pst);
             vertex[index++]=pst->vertex;
             pst=graph[pst->vertex].front;
//注意，在深度搜索算法中，不能采用广度搜索的策略
             for(  ;pst ;pst=pst->next)
            {
                    if(! graph[pst->vertex].v)
                   {
                          graph[pst->vertex].v=1;
                          push(hsk,pst);
                    }
             }
      }
//整理时间戳
     if(index>h->size)
           printf("数组越界.....%d\n",index);

     for(i=index-1;i>=0;--i)
           graph[vertex[i]].finish=++count;
//输出时间戳
     for(i=0;i<index;++i)
           printf("顶点%d--->时间:  %d \n",vertex[i],graph[vertex[i]].finish);
     *time=count;
     free(vertex);
     printf("\n******************$$$$$$$$$$$$$$$$$$$$$$$**************************\n");
  }
//创建图的邻接表表示
  void  CreateGraph(GraphHeader  *h)
 {
       int         size,i,j;
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
             scanf("%d %d",&i,&j);
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
             pst->next=graph[i].front;
             graph[i].front=pst;
             ++graph[i].count;
             printf("%d----->%d\n",i,j);
       }while(i!=-1 && j!=-1);
  }
//求一个图的邻接表表示的 逆邻接表
  void  reverse_adj_list(GraphHeader  *h,GraphHeader  *rh)
 {
       int         i,size;
       PostGraph   *pst,*p;
       Graph       *graph,*g;
//初始化数据
       size=h->size;
       g=(Graph *)malloc(sizeof(Graph)*size);
       rh->graph=g;
       rh->size=size;
       graph=h->graph;
//清零
       for(i=0;i<size;++i,++g)
      {
             g->count=0;
             g->v=0;
             g->finish=0;
             g->front=NULL;
       }
       g=rh->graph;
//开始计算逆邻接表
      for(i=0;i<size;++i)
     {
             pst=graph[i].front;
             while(  pst )
            {
                    p=(PostGraph *)malloc(sizeof(Graph));
                    p->vertex=pst->vp;
                    p->vp=pst->vertex;
                    p->next=g[pst->vertex].front;
                    g[pst->vertex].front=p;
                    ++g[pst->vertex].count;
          
                    pst=pst->next;
             }
      }
  }
//输出邻接表
  void  print_graph(GraphHeader  *h)
 {
      PostGraph  *pst;
      Graph  *graph=h->graph;
      int         i=0;
      for(   ;i<h->size;++i,++graph)
     {
             printf("顶点%d -->",i);
             pst=graph->front;

             while(  pst )
            {
                     printf("  %d   ",pst->vertex);
                     pst=pst->next;
             }
             printf("\n");
      }
  }
      
  int  main(int argc,char *argv[])
 {
       GraphHeader  hStack,*h=&hStack;
       GraphHeader  rhStack,*rh=&rhStack;
       
       h->size=0;
       h->graph=NULL;
       rh->size=0;
       rh->graph=NULL;

       printf("创建邻接表........\n");
       CreateGraph(h);
       printf("输出创建的邻接表...........\n");
       print_graph(h);

       printf("\n***************创建逆邻接表*****************\n");
       reverse_adj_list(h,rh);
       printf("输出逆邻接表.......\n");
       print_graph(rh);

       printf("\n****************************对邻接表进行深度优先搜索**********************\n");
       deep_visit_first(h);
       printf("\n*****************************对逆邻接表进行深度优先搜索*****************\n");
       deep_visit_first(rh);
       exit(0);
  }
 