//2013年3月6日18:52:34
//最大流问题
  #include<stdio.h>
  #include<stdlib.h>
  #include"有关图的数据结构.h"
  #include"图的遍历_栈和队列.c"
//函数的声明
  static  int  dfvs(GraphHeader  *,StackHeader *,int ,int);
  void    ford_fulkerson_most_flow(GraphHeader *,int (*p)[10],int ,int);
  static  void  process_argument_path(GraphHeader *,StackHeader *,Stack *,int (*p)[10]);
  static  void  remove_edge(Graph *,PostGraph *);
  static  void  add_edge(Graph *,PostGraph *);

  int  flows[10][10];
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
             graph->v=0;
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
//对图进行深度优先搜索,当搜索到目标顶点时就退出，但是保留搜索的路径
  static  int  dfvs(GraphHeader  *h,StackHeader *sh,int start,int  end)
 {
       Graph       *graph;
       PostGraph   *pst;
       int         i,flag=0,size=h->size;

       sh->size=0;
       sh->front=NULL;
//首先清除所有顶点的被访问过的痕迹
        graph=h->graph;
        for(i=0;i<size;++i,++graph)
              graph->v=0;
//下一步开始进行深度优先搜索
        graph=h->graph;
        pst=graph[start].front;
//如果已经没有任何路径，则直接退出
        if(! pst )
            return 0;
//下面的循环，之多进行 size 次
        graph[start].v=1;   //注意这一步很重要
        push(sh,pst);
        graph[pst->vertex].v=1;

        while( sh->size )
       {
//获取栈的顶部保存的元素，以判断循环是否要终止
              pst=sh->front->pst;
              if(pst->vertex==end)
             {
                    flag=1;
                    break;
              }
//寻找下一个目标顶点
              pst=graph[pst->vertex].front;
              while( pst )
             {
                     if(!graph[pst->vertex].v)
                            break;
                     pst=pst->next;
              }
//如果没有找到，则执行退栈操作
              if(! pst )
                     pop(sh,&pst);
//否则，直接入栈
              else
             {
                     push(sh,pst);
                     graph[pst->vertex].v=1;
              }
         }
//如果没有查找到目标路径，由循环的条件，栈已经为空，可以直接退出了
         return flag;
  }
//Ford-Fulkerson算法/start为源点，end为汇点,函数将计算结果写入flow矩阵中
  void  ford_fulkerson_most_flow(GraphHeader  *h,int (*flow)[10],int start,int end)
 {
        int          i,j,size;
        PostGraph    *pst;
        StackHeader  shStack,*sh=&shStack;
        Stack        *st,*it;
        Graph        *graph;
//对数据进行一些初始化操作
        graph=h->graph;
        size=h->size;
//开始计算/首先最矩阵进行清零操作
        for(i=0;i<size;++i)
            for(j=0;j<size;++j)
                  flow[i][j]=0;

        while( dfvs(h,sh,start,end) )
       {
//查找最小权值边
               st=sh->front;
               it=st;
               while( st )
              {
                    if(it->pst->weight>st->pst->weight)
                          it=st;
                    st=st->next;
               }
//下面根据已经查找到的边 对图中已经存在的边进行操作
               process_argument_path(h,sh,it,flow);
//对所有的增广路径上的边的权值进行更新 && 释放动态栈所占据的内存
               for(st=sh->front; st ;)
              {
                      it=st;
                      pst=st->pst;
                      st=st->next;
                      free(it);
               }
        }
  }
//集中处理增广路径,并更新矩阵
  static  void  process_argument_path(GraphHeader  *h,StackHeader *sh,Stack *low,int (*flow)[10])
 {
        Stack       *it;
        PostGraph   *pst,pgc,*pg=&pgc;
        Graph       *graph;
        int         weight=low->pst->weight;

        graph=h->graph;
        pg->weight=weight;
        for(it=sh->front; it ;it=it->next)
       {
//建立反向边
              pst=it->pst;
              pg->vp=pst->vertex;
              pg->vertex=pst->vp;
//更新矩阵
              flow[pst->vp][pst->vertex]+=weight;
//如果不是最小边
              if(pst->weight>weight)
//先对已经存在的边的权值减少 weight，再增加边
                   pst->weight-=weight;
//否则先删除再添加
              else  
                   remove_edge(graph,pst);
              add_edge(graph,pg);
         }
  }
//删除给定的边
  static  void  remove_edge(Graph  *graph,PostGraph  *pst)
 {
        PostGraph  *prev=NULL,*p;

        for(p=graph[pst->vp].front; p ;p=p->next)
       {
               if(p==pst)
                   break;
               else
                   prev=p;
        }
//如果这个条边不是和这个顶点相关联的
        if(!  p)
             return;

         --graph[pst->vp].count;
        if(! prev)
               graph[pst->vp].front=pst->next;
        else
               prev->next=pst->next;
        free(pst);
  }
//向图中对应的顶点增加一条边，如果这条边已经存在，就合并这条边
//注意，这里不能释放pst，因为它不是图中的已经建立好的边，而是后来动态生成的/这一点和上面的有所不同
  static  void  add_edge(Graph  *graph,PostGraph  *pst)
 {
        PostGraph  *p;
        
        for(p=graph[pst->vp].front; p ;p=p->next)
                if( p->vp==pst->vp  &&  p->vertex==pst->vertex )
                      break;
//如果给定的边不存在
        if(! p )
       {
              p=(PostGraph *)malloc(sizeof(PostGraph));
              p->vp=pst->vp;
              p->vertex=pst->vertex;
              p->weight=pst->weight;
              p->next=graph[pst->vp].front;
              graph[pst->vp].front=p;
        }
        else
              p->weight+=pst->weight;
        ++graph[pst->vp].count;
  }
//
  int  main(int  argc,char  *argv[])
 {
        GraphHeader  hGraph,*h=&hGraph;
        int          i,j,size;

         printf("\n******************创建图的邻接表表示********************\n");
         CreateGraph(h);
         printf("求这个图的最大流\n");
         ford_fulkerson_most_flow(h,flows,0,h->size-1);
         printf("以下是输出结果........................\n");
         for(i=0,size=h->size;i<size;++i)
        {
                for(j=0;j<size;++j)
                      printf("%d      ",flows[i][j]);
                printf("\n");
         }
         return 0;
  }