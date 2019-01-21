/*
  *@aim:Bellman-Ford算法实现
  *@date:2014-11-3 12:00:11
  *@author:狄建彬
  */
  #include<stdio.h>
  #include"CGraph.h"
  #include"Array.h"
  #ifndef     infinite     
      #define    infinite  0x3FFFFFFF
  #endif

/*
  *@func:bellman_ford算法
  *@param:g代表图的临街表表示,d表示各个点的最短路径，parent代表最短路径中个顶点的前驱
  *@param:s为原点
  *@output:若返回false代表这个图中存在负权回路,true表示计算成功
  *@request:size of d or parent >=g->getVertexCount()
  *@note:如果某一个顶点v没有前驱，则相应的parent[v]=-1
  */
   bool      bellman_ford(CGraph   *g,int  s,int    *d,int   *parent)
  {
            int                 i,j,e;
            CSequela      *p;
            int                size=g->getVertexCount();
//初始，将数据填充
            for(i=0;i<size;++i)
           {
                     d[i]=infinite;
                     parent[i]=-1;
            }
            d[s]=0;
//边以每次一条地伸展,任何两个顶点之间最多有size-1条边
            for( i=0;i<size-1;++i)
           {
                    for(j=0;j<size;++j)
                   {
                              p = g->getSequelaVertex(j );
                              while( p )
                             {
//j是p->vertex_tag的前驱
                                       e = d[j] + p->weight;
                                       if(  d[p->vertex_tag] > e )
                                      {
                                                d[p->vertex_tag]=e;
                                                parent[p->vertex_tag]=j;
                                       }
                                       p=p->next;
                              }
                    }
            }
//检测，是否存在负权回路
            for(i=0;i<size;++i)
           {
                       p=g->getSequelaVertex(i);
                       while( p )
                      {
//如果在最短路径伸展到了最多size-1条之后，再次检测最短路径时，然而仍然有不满足最短路径的点存在
//说明此时存在负权回路
                                 if(  d[p->vertex_tag] > d[i] + p->weight )
                                          return   false;
                                 p=p->next;
                       }
            }
            return    true;
   }
//测试
    int     main(int    argc,char   *argv[])
   {
           int    adj[5][5]={
                                       {0,1,20,0,3},
                                       {0,0,0,50,0},
                                       {0,0,0,7,0},
                                       {-200,0,0,0,0},
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
          if( bellman_ford( &graph,0,d,parent) )
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
                   printf("there is  some negative cycle in the graph !\n");
         }
          return  0;
    }
