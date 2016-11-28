/*
  *@aim:图的拓扑排序最短路径算法
  *@date:2014-11-3 12:37:58
  *@author:狄建彬
  */
//
  #include"CGHeap.h"
  #include"Array.h"
  #include"CGraph.h"
  #include<stdio.h>
  #include<stdlib.h>
  #define    infine      0x3FFFFFFF
/*
  *@func:topologic_shortest_path
  *@request:图中不能存在环
  *@param:g图的邻接表表示
  *@param:d存储各个顶点到源点s的最短路径 
  *@param:parent各个顶点的前驱顶点记录，若没有前驱，记为-1
  *@request:size of d and parent >=g->getSize()
  */
   bool       topologic_shortest_path(CGraph    *g,int  s,int    *d,int    *parent)
  {
           int       size=g->getVertexCount();
           int       *vertex=(int *)malloc(sizeof(int)*size);
           int       i,e;
           CSequela     *q;
//判断是否有环
           if( g->topologicSort(vertex) <=0)
          {
                     free(vertex);
                     return   false;
           }
//按已经排序的顶点对各个边进行松弛
//松弛前的准备
          for( i=0;i<size;++i)
         {
                   d[i]=infine;
                   parent[i]=-1;
          }
          d[s]=0;
          for( i=0    ;i<size;++i )
         {
//此处复用了数据s
                        s=vertex[i];
                        q = g->getSequelaVertex( s );
                        while(  q  )
                       {
                                 e=d[ s] + q->weight;
                                 if( d[q->vertex_tag] > e )
                                {
                                        d[q->vertex_tag] = e;
                                        parent[q->vertex_tag]=s;
                                 }
                                 q = q->next;
                       }
          }
          free(vertex);
          return   true;
  }
//
   int     main(int   argc,char    *argv[])
  {
           int    adj[5][5]={
                                       {0,1,20,0,3},
                                       {0,0,0,50,0},
                                       {0,0,0,7,0},
                                       {0,0,0,0,0},
                                       {0,0,5,100,0}
                                 };
           int      size=5;
           int      i,j;
           int      d[6];
           int      parent[6];
           Array      garray(size,size),*y=&garray;
           for(i=0;i<size;++i)
                 for(j=0;j<size;++j)
                          y->set(i,j,adj[i][j]);
//设置无效值
          y->setInvalideValue(0);
//建立图的临街表表示
          CGraph     graph(y);
          if( topologic_shortest_path( &graph,0,d,parent) )
         {
                   printf("We have solved the shortest path:\n");
                   for( i=0;i<size;++i)
                  {
                         printf("0------->%d: %d  ,path is:  ",i,d[i]);
                         j=i;
                         while(j>=0  )
                        {
                                 printf("%d ",j);
                                 j=parent[j];
                         }
                         putchar('\n');
                   }
         }
         else
        {
                   printf("there is  some  cycle in the graph !\n");
         }
          return  0;
  }
